# Modelo Conceitual GLPI — Extração do SIS Mobile para o App DTIC

**Produzido em:** 2026-06-26
**Escopo:** Análise completa do SIS Mobile Flutter para documentar o
modelo mental construído na integração com o GLPI e servir de base permanente para
o desenvolvimento do aplicativo DTIC.

---

## Sumário

1. [Modelo Conceitual](#1-modelo-conceitual)
2. [Fluxo de Estados](#2-fluxo-de-estados)
3. [Motor de Regras](#3-motor-de-regras)
4. [Integração — Endpoints GLPI](#4-integração--endpoints-glpi)
5. [Hardcodes — Inventário e Classificação](#5-hardcodes--inventário-e-classificação)
6. [Princípios Reutilizáveis para o App DTIC](#6-princípios-reutilizáveis-para-o-app-dtic)

---

## 1. Modelo Conceitual

### O GLPI como Motor de Regras

O SIS Mobile não foi construído como um formulário que envia dados para um banco.
Ele foi construído como um **intérprete de um servidor de regras**.

O GLPI define:
- quem pode fazer o quê (permissões por perfil);
- o que pode acontecer após cada estado (transições);
- quem vai receber o ticket (RuleTicket de atribuição);
- o que é terminal (status 6 = Fechado);
- quem é o requerente e quem é o técnico (relações Ticket_User);

O app apenas **lê** esses contratos e **age** de acordo. Quando o GLPI diz que não
pode, o app não tenta contornar — ele exibe erro e interrompe.

### Camadas de Abstração

O modelo foi construído em três camadas conceituais:

```
[ GLPI REST API ]
       ↓
[ SessionContext — identidade do usuário logado ]
       ↓
[ OperationalRole — papel calculado da sessão ]
       ↓
[ TicketDomain — domínio do ticket, derivado dos dados dele ]
       ↓
[ TicketPermissionDecision — o que esse usuário pode fazer nesse ticket ]
       ↓
[ UI — exibe apenas o que a decisão permite ]
```

Cada camada lê apenas a camada imediatamente anterior. A UI nunca acessa dados
brutos da API diretamente.

### O que a Sessão diz ao App

Ao fazer login (`GET /initSession` + `GET /getFullSession`), o app recebe:

| Campo GLPI | Significado operacional |
|---|---|
| `glpiID` | ID numérico do usuário logado |
| `glpiname` | Login (username) |
| `glpiactiveprofile.name` | Nome do perfil ativo (ex.: "Solicitante", "Tecnico Manutenção e Conservação") |
| `glpiactiveprofile.id` | ID numérico do perfil ativo |
| `glpiactiveprofile.entities` | Entidades onde esse perfil está ativo |
| `glpiactive_entity` | Entidade ativa no momento |
| `glpigroups` | Grupos do usuário (ex.: CC-CONSERVAÇÃO, CC-MANUTENÇÃO, GG-CONSERVAÇÃO) |
| `glpidefault_entity` | Entidade padrão do usuário |

Tudo isso é capturado em `SessionContext` (`lib/models/session_context.dart`) e
propagado para o `AppState`.

### Papel Operacional — OperationalRole

O papel não é salvo nem configurado no app. Ele é **calculado em tempo de execução**
a partir da sessão:

- `OperationalRoleResolver.resolve()` recebe: perfil ativo + grupos.
- Retorna: `standardRequester`, `conservationTechnician`, `maintenanceTechnician`,
  `ggConservationRequester`, `hybrid`, `supervisor`, `admin`, `ineligible`, `unknown`.

A lógica atual usa dois critérios:
1. **Nome do perfil** (normalizado, sem acentos, minúsculo) — identifica se é
   solicitante, técnico, supervisor, admin.
2. **IDs dos grupos** — identifica se é conservação (21), manutenção (22), GG (49).

### Domínio do Ticket — TicketDomain

O domínio não vem do usuário — vem dos **dados do ticket**:

- `TicketDomainResolver.resolve()` recebe: categoria (texto completo), grupos
  atribuídos, grupos observadores.
- Resolve: `maintenance`, `conservation`, `ggConservationObserver`, `dtic`, `unknown`.

A lógica usa:
1. Texto da categoria (prefixo "manutencao" ou "conservacao" no nome completo).
2. ID do grupo atribuído (21 → conservação, 22 → manutenção).

### Decisão de Permissão — TicketPermissionDecision

`PermissionService.evaluate()` cruza:

| Entrada | Tipo |
|---|---|
| `OperationalRole` | Papel do usuário |
| `TicketDomain` | Domínio do ticket |
| `loggedUserId` vs `requesterUserId` | É o requerente? |
| `status` | Estado atual do ticket |
| `assignedGroups`, `observerGroups` | Grupos do ticket |

Retorna um objeto com flags booleanas:

| Flag | Significado |
|---|---|
| `canView` | Pode ver o ticket |
| `canOpenConversation` | Pode abrir a tela de conversa |
| `canSendFollowup` | Pode enviar mensagem |
| `canAttachFile` | Pode anexar arquivo |
| `canAssignToSelf` | Pode se atribuir |
| `canChangeStatus` | Pode mudar status |
| `canProposeSolution` | Pode propor solução |
| `canValidateSolution` | Pode aprovar/recusar solução |
| `canViewTechnicalQueue` | Pode ver a fila técnica |
| `canViewGgSharedQueue` | Pode ver fila compartilhada GG |

A UI usa esses flags — não avalia condições diretamente.

### Filas de Ticket — TicketQueueType

Um mesmo ticket pode pertencer a múltiplas filas simultaneamente:

- `requestedByMe` — usuário é o requerente
- `assignedToMe` — ticket atribuído ao usuário
- `maintenanceQueue` — fila técnica de manutenção
- `conservationQueue` — fila técnica de conservação
- `ggConservationShared` — demanda compartilhada GG Conservação
- `pendingValidation` — ticket solucionado aguardando aprovação do requerente
- `supervision` — visão de supervisor
- `allAdmin` — visão ampla de admin

A fila primária segue uma ordem de prioridade:
`assignedToMe > pendingValidation > maintenanceQueue > conservationQueue > ggConservationShared > requestedByMe > supervision > allAdmin`

---

## 2. Fluxo de Estados

### Diagrama de Ciclo de Vida

```
[Offline] ──────────────────────────────────→ [Novo (1)]
                          POST /Ticket
                               |
         ┌─────────────────────┼──────────────┐
         ↓                     ↓              ↓
  [Em Atendimento (2)]  [Planejado (3)]  [Pendente (4)]
         ↑  ↓                  ↑  ↓          ↑  ↓
         └──┘                  └──┘          └──┘
         (técnico muda status livremente entre 1,2,3,4)
                               |
                               ↓ (técnico propõe solução)
                        [Solucionado (5)]
                          /          \
             (requerente aprova)   (requerente recusa)
                    ↓                     ↓
             [Fechado (6)]          [Novo (1)]  ← por design GLPI
              TERMINAL
```

### Quem controla cada transição

| Transição | Quem controla | Como |
|---|---|---|
| Novo → Em Atendimento | Técnico | `PUT /Ticket {status: 2}` |
| Qualquer → Qualquer (1-4) | Técnico | `PUT /Ticket {status: N}` |
| Em Atendimento → Solucionado | Técnico | `POST /ITILSolution` |
| Solucionado → Fechado | Requerente | `POST /TicketFollowup {add_close: 1}` |
| Solucionado → Novo | Requerente | `POST /TicketFollowup {add_reopen: 1}` |
| Offline → Novo | App (sincronização) | `POST /Ticket` |

### Regra do Solucionado — Semi-terminal

`status=5` não é terminal no GLPI, mas é tratado como **semi-terminal** no app:

- Bloqueia ações técnicas comuns (mudar status por botões).
- Bloqueia mensagem comum e anexo comum.
- Habilita o fluxo de validação de solução (aprovar/recusar).
- O requerente **não** usa `PUT /Ticket` — usa `POST /TicketFollowup` com
  `add_close` ou `add_reopen`.

Razão: o perfil Solicitante tem o direito de followup, mas **não** tem UPDATE em
Ticket. A descoberta disso aconteceu ao vivo: até `{name, content}` falhava porque
faltava o bit CREATE (não UPDATE) para criar; já para validar solução o
`PUT /Ticket {status}` falhava porque faltava UPDATE. O followup resolveu ambos.

### Regra do Fechado — Terminal

`status=6` é terminal operacional completo:
- Nenhuma ação operacional é executada pelo app.
- A tela de conversa pode ser aberta para leitura do histórico.
- O composer fica desabilitado.
- Toda ação crítica (mudar status, enviar mensagem, etc.) reconsulta o estado
  remoto antes de executar — se vier Fechado, a ação é abortada antes de qualquer
  mutação.

### Recusa volta para Novo — Por Design

Quando o requerente recusa a solução (`add_reopen`), o GLPI reabre o chamado para
`Novo (1)`, não para `Em Atendimento`. Isso é design do GLPI 10.0.2 e foi
confirmado pela existência da RuleTicket #178 "Chamados recusados voltam para
novos" na instância SIS. O app está alinhado: não presume nem força outro status.

### Como Descobrir Transições Dinamicamente

O `GlpiRulesClient` carrega `assets/glpi_rules_sis.json` (gerado por script a
partir de dump read-only da API). Contém, por perfil:

```json
"transitions_by_profile": {
  "9": {
    "name": "Solicitante",
    "transitions": { "5": [6], ... }
  }
}
```

Isso permite descobrir dinamicamente quais status um perfil pode atingir a partir
do status atual — sem hardcode na lógica de UI.

O asset é estático (snapshot de build), mas pode ser regenerado periodicamente.
Para o app DTIC, o ideal seria consultar as transições via API em tempo real,
pois a configuração do GLPI pode diferir entre instâncias.

---

## 3. Motor de Regras

### R-1: Status — Interpretação Flexível

**Arquivo:** `lib/models/glpi_status.dart`
**Origem:** GLPI define 1-6 no core.

`GlpiStatusMapper.tryParse()` aceita int, string numérica ou string normalizada
("novo", "em atendimento", "fechado"). Isso permite interpretar respostas da API
que às vezes retornam label em vez de código numérico.

Funções derivadas:
- `isClosed()` — status 6
- `isSolved()` — status 5
- `isOpenForInteraction()` — status 1,2,3,4 ou offline (bloqueia em 5 e 6)
- `canValidateSolution()` — apenas status 5

**Pode ser dinâmico?** Parcialmente. Os códigos 1-6 são fixos no GLPI core (não
mudam entre instâncias). Os rótulos podem ser obtidos de `getFullSession` ou do
JSON de regras. A lógica semântica (o que é terminal, o que bloqueia ação) é
institucional e pode ficar no app.

---

### R-2: Papel Operacional — Derivado da Sessão

**Arquivo:** `lib/models/operational_role.dart`
**Origem:** Nome do perfil ativo + IDs dos grupos da sessão.

```dart
static OperationalRole resolve({
  required GlpiProfileRef? activeProfile,
  required List<GlpiGroupRef> groups,
})
```

A lógica normaliza o nome do perfil e verifica IDs de grupos específicos da
instância SIS:

| Grupo ID | Nome SIS |
|---|---|
| 21 | CC-CONSERVAÇÃO |
| 22 | CC-MANUTENÇÃO |
| 49 | GG-CONSERVAÇÃO |

**Pode ser dinâmico?** Sim. Em vez de hardcode de IDs, o app poderia:
1. Buscar os grupos do usuário via `GET /Group_User` ou da sessão.
2. Comparar com grupos configurados em uma chave de configuração ou .env.
3. Para o app DTIC, os grupos relevantes serão diferentes — esse mecanismo
   precisa ser reescrito.

---

### R-3: Domínio do Ticket — Derivado dos Dados

**Arquivo:** `lib/models/ticket_domain.dart`

Resolve o domínio a partir da categoria (texto normalizado) e do grupo atribuído.
Usa os mesmos IDs hardcoded (21, 22, 49).

O texto da categoria é normalizado (sem acentos) e verificado por prefixo:
- começa com "manutencao" ou contém "> manutencao" → manutenção
- começa com "conservacao" ou contém "> conservacao" → conservação

**Pode ser dinâmico?** Sim. O GLPI tem a categoria completa no campo
`itilcategories_id` com `expand_dropdowns=true`. O app poderia configurar
externamente quais prefixos de categoria mapeiam para quais domínios.
Para o DTIC, o conceito de "domínio" pode ser completamente diferente ou
não existir — esse mapeamento deve ser específico por instância.

---

### R-4: Permissão — Cruzamento de Papel, Domínio e Status

**Arquivo:** `lib/policy/permission_service.dart`

Lógica institucional que não tende a mudar frequentemente. Nota explícita no
código (linha 11): "Regras de permissão são institucionais e raramente mudam.
Decisão: MANTER HARDCODED por pragmatismo/MVP."

A regra crítica descoberta em produção:
- **Solicitante que é técnico**: se o usuário logado é o requerente do ticket,
  ele **não** recebe ações técnicas naquele ticket, mesmo que seu perfil seja
  técnico. Isso evita que um técnico feche o próprio chamado.

**Pode ser dinâmico?** Parcialmente. A lógica de "requerente prevalece" é
comportamento GLPI documentado. As permissões por perfil poderiam ser lidas via
`ProfileRight` em tempo de execução, mas isso tem alto custo e raramente muda.
Recomenda-se manter a lógica no app mas externalizá-la em configuração de
instância para o DTIC.

---

### R-5: Visibilidade da Fila — Derivada da Permissão

**Arquivo:** `lib/policy/ticket_queue_filter.dart`

A visibilidade de cada fila de tickets é completamente derivada de
`PermissionService.evaluate()`. A fila de tickets que o usuário vê no GLPI
(escopo `OWN_ONLY`, `GROUP_OR_ASSIGNED`, `ALL_IN_ENTITY`) é documentada no JSON
de regras:

```json
"visibility": {
  "9": { "scope": "OWN_ONLY", "read_bits": ["READMY"] },
  "11": { "scope": "GROUP_OR_ASSIGNED", "read_bits": ["READ", "READGROUP"] }
}
```

O `GlpiRulesClient` expõe `visibilityScope(profileId)` para consulta dinâmica.

---

### R-6: Criação de Ticket — Contrato Mínimo

**Arquivo:** `lib/services/glpi_ticket_support.dart`

A regra mais importante descoberta em produção (custo: semanas de debugging):

**O perfil Solicitante pode criar ticket via API REST SOMENTE se tiver o bit
CREATE (4) no direito `ticket`.**

Isso é diferente da interface web helpdesk, que cria ticket sem esse bit. A API
REST sempre verifica `haveRight('ticket', CREATE)`.

O app envia payload mínimo:
- `name`, `content`, `status=1`, `requesttypes_id=1`
- `entities_id`, `itilcategories_id`, `locations_id` (quando disponível)
- `_users_id_requester`, `_users_id_observer` (apenas IDs de pessoas)

O app **nunca** envia:
- `_groups_id_assign` — Solicitante pode criar mas não atribuir
- `_groups_id_requester` — desnecessário
- `_groups_id_observer` — desnecessário
- `_users_id_assign` — Solicitante não tem direito de atribuição

A atribuição de grupo é feita pelo servidor via RuleTicket, disparada pela
combinação de categoria + entidade no payload.

---

### R-7: Read-back Governado — Verificação Pós-criação

**Arquivo:** `lib/catalog/governed_service_catalog.dart` (`GovernedReadbackExpectation`)

Após criar o ticket, o app lê o ticket criado e verifica:
1. O grupo atribuído corresponde ao esperado pela RuleTicket?
2. O domínio foi corretamente resolvido?
3. Os templates de tarefa foram gerados (FormCreator)?

Divergências viram **avisos**, não bloqueios — o app não cancela o ticket criado
por discrepância de read-back.

---

### R-8: Caching de Nomes — Resolução Preguiçosa

**Arquivo:** `lib/services/glpi_client.dart` (`_userDisplayNameCache`)

IDs numéricos de usuário são resolvidos sob demanda via `GET /User/{id}` e
cacheados em memória por sessão. O fallback é um label descritivo ("Técnico 2039")
para nunca exibir ID cru.

Invariante I-6: quando o nome pode ser resolvido, o ID não aparece na UI.

---

## 4. Integração — Endpoints GLPI

### Autenticação e Sessão

| Endpoint | Método | Finalidade |
|---|---|---|
| `/initSession` | GET | Login com Authorization Basic (base64 user:pass). Retorna `session_token`. |
| `/getFullSession` | GET | Contexto completo da sessão: userId, perfil, grupos, entidades, entidade ativa. **Base de tudo.** |
| `/killSession` | GET | Encerrar sessão. |
| `/changeActiveProfile` | POST | Mudar perfil ativo da sessão (só via GLPI direto; Worker não expõe). |

**Nota crítica:** o Worker SIS não expõe `/changeActiveProfile`. Para simular
papéis em testes, o acesso ao GLPI direto (rede interna/VPN) é necessário.

---

### Tickets

| Endpoint | Método | Finalidade |
|---|---|---|
| `/search/Ticket` | GET | Busca com critérios (campos de ator, status, requerente). Retorna rows com IDs de SearchOption. |
| `/Ticket` | GET | Lista tickets (fallback sem filtro de requerente). |
| `/Ticket/{id}?expand_dropdowns=true&with_documents=true` | GET | Detalhe completo com labels expandidos e documentos. |
| `/Ticket/{id}/Ticket_User` | GET | Relações usuário-ticket: `type=1` (requerente), `type=2` (técnico). |
| `/Ticket/{id}/Group_Ticket` | GET | Grupos do ticket: `type=1` (atribuído), `type=3` (observador). |
| `/Ticket` | POST | Criar ticket. Payload mínimo. Requer bit CREATE no perfil. |
| `/Ticket/{id}` | PUT | Atualizar status (requer bit UPDATE no perfil). |
| `/Ticket/{id}/Document` | POST multipart | Anexar arquivo. Funciona sem direito `document` genérico — vincular ao próprio ticket não exige. |

**SearchOptions relevantes:**

| ID | Campo |
|---|---|
| 1 | Título (name) |
| 2 | ID do ticket |
| 4 | Requerente (users_id_recipient) |
| 7 | Categoria (itilcategories_id) |
| 8 | Grupo atribuído |
| 12 | Status |
| 15 | Data de modificação |
| 22 | Autor (users_id_lastupdater) |
| 66 | Observador usuário |
| 80 | Entidade |

---

### Mensagens e Soluções

| Endpoint | Método | Finalidade |
|---|---|---|
| `/TicketFollowup` | POST | Enviar mensagem ao ticket. Também aprova (`add_close: 1`) ou recusa (`add_reopen: 1`) solução. **Único caminho para o Solicitante validar solução.** |
| `/ITILSolution` | POST | Propor solução (requer `maySolve`). Disponível para técnico. |
| `/ITILFollowup` | POST | Alternativa ao TicketFollowup (não exposta no Worker SIS). |

**Nota crítica:** para aprovação/recusa de solução pelo Solicitante:
- `PUT /Ticket {status}` → falha (sem UPDATE)
- `PUT /ITILSolution` → falha (sem maySolve)
- `POST /TicketFollowup {add_close: 1}` → **funciona** (usa direito de followup)

---

### Usuários e Grupos

| Endpoint | Método | Finalidade |
|---|---|---|
| `/User/{id}` | GET | Resolver nome real de usuário. Elevado via Worker (Solicitante não tem direito de leitura de User). |
| `/User?searchText[name]=X` | GET | Buscar usuários por login ou nome. Elevado via Worker. |
| `/User?searchText[realname]=X` | GET | Buscar por sobrenome. |
| `/User?searchText[firstname]=X` | GET | Buscar por primeiro nome. |

**Nota:** a busca é feita em paralelo nos três campos e os resultados são
deduplicados por ID.

---

### Checklists (FormCreator)

| Endpoint | Método | Finalidade |
|---|---|---|
| `GET /PluginFormcreatorForm` | GET | Listar formulários disponíveis (apenas SIS com Worker específico). |
| `POST /PluginFormcreatorFormAnswer` | POST | Submeter resposta de formulário (modo FormCreator nativo). |

O app SIS tem checklists em modo read-only por padrão, protegidos por flag:
`SIS_ENABLE_CHECKLISTS_SUBMISSION=true` (build) + `ALLOW_FORMCREATOR_SUBMISSION=true`
(Worker).

---

### Worker SIS — Allowlist e Comportamento

O Worker injeta o `App-Token` server-side e aplica uma allowlist de rotas. Rotas
que **passam** pelo Worker SIS:
- `/initSession`, `/killSession`, `/getFullSession`
- `/Ticket`, `/Ticket/{id}`, `/search/Ticket`
- `/Ticket/{id}/Ticket_User`, `/Ticket/{id}/Group_Ticket`
- `/Ticket/{id}/Document`
- `/TicketFollowup`
- `/ITILSolution`
- `/User`, `/User/{id}`, `/search/User` (elevados com sessão de serviço para GET)

Rotas que **não passam** (exigem GLPI direto):
- `/changeActiveProfile`
- `/ITILFollowup`
- `Profile_User`, `ProfileRight` (administração de perfis)

---

## 5. Hardcodes — Inventário e Classificação

### Legenda
- **Obrigatório:** valor definido pelo GLPI core; não muda entre instâncias.
- **Institucional:** faz sentido para a SIS/DETIC mas poderia vir de configuração.
- **Removível:** pode ser substituído por descoberta dinâmica ou configuração.
- **Legado:** existe por histórico; deveria ser revisto para o app DTIC.

---

### H-1: Códigos de Status (1-6)

| Arquivo | Valor | Classificação |
|---|---|---|
| `lib/models/glpi_status.dart` | `GlpiStatus.novo(1)` .. `fechado(6)` | **Obrigatório** |

**Por quê é obrigatório:** o GLPI core define esses valores. Não mudam entre
instâncias. O enum `GlpiStatus` é correto; o que pode variar são os rótulos
exibidos (que o asset `glpi_rules_sis.json` já fornece dinamicamente).

---

### H-2: IDs de Grupos SIS

| Arquivo | Valor | Classificação |
|---|---|---|
| `lib/models/operational_role.dart` | `conservationGroupId = 21` | **Institucional → Removível** |
| `lib/models/operational_role.dart` | `maintenanceGroupId = 22` | **Institucional → Removível** |
| `lib/models/operational_role.dart` | `ggConservationGroupId = 49` | **Institucional → Removível** |
| `lib/models/ticket_domain.dart` | mesmos IDs | **Institucional → Removível** |
| `lib/policy/permission_service.dart` | `ggConservationGroupId = 49` | **Institucional → Removível** |

**Como tornar dinâmico:** adicionar variáveis de configuração (`.env` ou JSON de
instância) com os IDs dos grupos relevantes por domínio. O app DTIC terá IDs
diferentes — esse é o primeiro passo para ser instância-agnóstico.

**Para o DTIC:** substituir esses IDs por configuração no `.env`:
```
GLPI_GROUP_CONSERVATION=21
GLPI_GROUP_MAINTENANCE=22
GLPI_GROUP_GG_CONSERVATION=49
```

---

### H-3: Nomes de Perfil (Matches por Substring)

| Arquivo | Valor | Classificação |
|---|---|---|
| `lib/models/operational_role.dart` | `'solicitante'`, `'tecnico'`, `'manutencao e conservacao'` | **Institucional → Removível** |
| `lib/state/app_state_ticket_support.dart` | `'solicitante'`, `'tecnico'`, `'super-admin'` | **Institucional → Removível** |

**Risco:** se o perfil for renomeado no GLPI, a lógica falha silenciosamente.

**Como tornar dinâmico:** comparar por ID de perfil (`activeProfileId`) contra uma
lista configurável, em vez de comparar o nome normalizado. O GLPI já fornece o ID
do perfil na sessão.

---

### H-4: Enums Específicos da SIS

| Enum | Onde | Classificação |
|---|---|---|
| `OperationalRole` | `lib/models/operational_role.dart` | **Legado** |
| `TicketDomain` | `lib/models/ticket_domain.dart` | **Legado** |
| `TicketQueueType` | `lib/models/ticket_queue_type.dart` | **Legado** |

**Por quê é legado:** reflete a estrutura organizacional da SIS (Conservação,
Manutenção, GG-Conservação). O app DTIC tem estrutura diferente — precisará de
enums ou configuração própria.

**Recomendação para o DTIC:** não copiar esses enums. Em vez disso, modelar:
- `OperationalRole`: substituir por perfil ativo + grupos configuráveis.
- `TicketDomain`: substituir por configuração de mapeamento categoria→domínio.
- `TicketQueueType`: adaptar às filas relevantes para o DTIC.

---

### H-5: Catálogo Estático de Categorias

| Arquivo | Valor | Classificação |
|---|---|---|
| `lib/data/service_data.dart` | `ServiceCategory` com `categoryId` fixo | **Legado** |
| `GlpiTicketSupport.getCategoryId()` | Chama `resolveServiceCategoryId()` | **Legado** |

**Por quê é legado:** o mapa de categoria → ID foi construído manualmente para a
SIS. O GLPI expõe `GET /ITILCategory` que poderia alimentar esse catálogo
dinamicamente.

**Para o DTIC:** nunca construir catálogo estático. O catálogo vem sempre do
FormCreator via API (`PluginFormcreatorForm`), como já foi arquitetado.

---

### H-6: Asset JSON de Regras (Semi-dinâmico)

| Arquivo | Classificação |
|---|---|
| `assets/glpi_rules_sis.json` | **Institucional — snapshot de build** |

O arquivo é gerado por script (`glpi-arch-investigation/bin/build_app_contract.py`)
a partir de dumps read-only da API. Contém transições de status por perfil,
escopos de visibilidade e catálogo FormCreator.

**Vantagem:** funciona offline; não exige chamada de rede na inicialização.
**Desvantagem:** fica desatualizado se a configuração do GLPI mudar.

**Para o DTIC:** o ideal seria buscar as regras relevantes em runtime (login ou
boot) e usar o asset apenas como fallback/cache.

---

### H-7: Urgência e Tipo — Mapeamento por Label

| Arquivo | Valor | Classificação |
|---|---|---|
| `GlpiTicketSupport.mapUrgency()` | "Baixa"=2, "Média"=3, "Alta"=4 | **Obrigatório (GLPI core)** |
| `GlpiTicketSupport.mapType()` | "Incidente"=1, "Solicitação"=2 | **Obrigatório (GLPI core)** |

Esses valores são definidos pelo GLPI core e não mudam entre instâncias. O mapeamento
label→código é correto — o único risco é se o label no formulário mudar.

---

## 6. Princípios Reutilizáveis para o App DTIC

### P-1: Sessão como Única Fonte de Identidade

Nunca salvar userId, perfil ou grupos como configuração. Extrair sempre de
`GET /getFullSession` após login. A sessão é a verdade; tudo derivado dela é
calculado em runtime.

```dart
// Correto: derivar do GLPI
final userId = session['glpiID'];
final profileName = session['glpiactiveprofile']['name'];
final groups = session['glpigroups'];

// Errado: hardcoded ou salvo no app
final userId = 2373; // ← nunca
```

---

### P-2: GLPI Sempre Vence

Quando o estado local (snapshot em memória ou storage) divergir do estado remoto
do GLPI, o GLPI prevalece. O app nunca age sobre estado local stale para ações
críticas.

**Implementação:** antes de toda mutação crítica (mudar status, aprovar/recusar,
enviar mensagem), buscar o estado atual do ticket via `GET /Ticket/{id}` e validar.

---

### P-3: Guarda Antes de Mutar

Toda ação que muda estado no GLPI deve:
1. Verificar autenticação local.
2. Buscar estado remoto atual do ticket.
3. Validar que o estado permite a ação.
4. Executar a mutação.
5. Propagar erro se a mutação falhar — nunca fingir sucesso local.

```dart
// Padrão correto
final currentTicket = await api.getTicketById(ticketId, token);
if (!GlpiStatusMapper.isOpenForInteraction(currentTicket['status'])) {
  return {'success': false, 'error': 'Ticket não está em estado interativo.'};
}
await api.putUpdate(...);
```

---

### P-4: Papel Calculado, Nunca Salvo

`OperationalRole` é calculado por `OperationalRoleResolver.resolve()` a cada
acesso — não é persistido. Se o usuário muda de perfil no GLPI (ex.: via
`changeActiveProfile`), o próximo `getFullSession` reflete isso.

**Para o DTIC:** o conceito de papel pode ser mais simples (ex.: `requester` vs
`technician` vs `admin`), mas o princípio é o mesmo: derivar da sessão.

---

### P-5: Domínio Derivado do Ticket, Não do Usuário

O domínio (conservação, manutenção, DTIC) é uma propriedade do **ticket**, não
do usuário. O mesmo usuário pode ser técnico de conservação para um ticket e
requerente em outro.

**Para o DTIC:** o conceito de "domínio" pode ser substituído por "categoria pai"
ou "grupo atribuído" — a princípio, o domínio é derivável dos dados que o GLPI
já retorna.

---

### P-6: Solicitante Sempre Prevalece sobre Perfil Técnico

Se o usuário é o requerente do ticket, ele **não** recebe ações técnicas naquele
ticket, mesmo que seu perfil ativo seja técnico. Isso impede conflitos de papel
(técnico fechando o próprio chamado).

**Implementação:** comparar `loggedUserId` com o `requesterUserId` extraído das
relações `Ticket_User` do ticket. Se iguais → tratar como solicitante para esse
ticket.

---

### P-7: Payload Mínimo — Nunca Assumir Permissão

Enviar ao GLPI apenas os campos que o perfil tem direito de definir. Se o perfil
pode criar mas não atribuir, não enviar `_groups_id_assign`. O GLPI rejeitará
(`ERROR_GLPI_ADD`) a criação inteira se um campo proibido for incluído.

**Descoberta em produção:** o FormCreator envia `_groups_id_assign` via plugin com
privilégios próprios. A API REST direta segue os direitos do usuário logado.

---

### P-8: RuleTicket Atribui o Grupo — O App Não

A atribuição de grupo é responsabilidade das RuleTicket configuradas no GLPI.
O app apenas garante que a **categoria** e a **entidade** corretas estão no payload
— esses são os gatilhos das regras server-side.

Após criar, verificar via read-back se o grupo esperado foi atribuído (aviso, não
bloqueio).

---

### P-9: Followup para Validar Solução, Não PUT de Status

O requerente aprova/recusa a solução via `POST /TicketFollowup`:
- `add_close: 1` → aprovação (ticket fecha)
- `add_reopen: 1` → recusa (ticket volta para Novo)

`PUT /Ticket {status}` exige UPDATE — direito que o Solicitante não tem.
`PUT /ITILSolution` exige `maySolve` — direito que o Solicitante não tem.

**Para o DTIC:** validar se o perfil Solicitante DTIC tem o mesmo padrão de
direitos. Se sim, usar o mesmo mecanismo.

---

### P-10: Worker como Proxy Transparente, Não como Autoridade

O Worker injeta `App-Token` e aplica allowlist. Ele não verifica permissões de
negócio — isso é responsabilidade do GLPI. O perfil do usuário logado via Worker
é o mesmo que via direto: mesmos direitos, mesmo comportamento.

**Implicação:** testar comportamento diretamente no GLPI (sem Worker) é suficiente
para validar a lógica de negócio. O Worker é apenas infraestrutura de acesso
externo.

---

### P-11: Nome Humano Sempre Resolve

Nunca exibir `"Usuário 2039"` ou `"Técnico 2039"` quando o nome pode ser obtido.
Usar `GET /User/{id}` sob demanda com cache em memória. O fallback descritivo
(`"Técnico 2039"`) é preferível ao ID cru.

**Para o DTIC:** manter esse princípio. O GLPI retorna os IDs — o app é
responsável por resolver os nomes.

---

### P-12: Estado Offline é Local, Não GLPI

Tickets criados offline têm um estado próprio (`"Pendente (Offline)"`) que existe
apenas no app. Quando sincronizados, o estado GLPI prevalece imediatamente. A UI
deve distinguir claramente estado local de estado remoto.

---

### P-13: Catálogo de Serviços Vem do GLPI — Não do App

O catálogo de serviços (formulários, categorias, localizações) deve vir do GLPI
(FormCreator, `ITILCategory`, `Location`). Um catálogo estático no app é sempre
legado — funciona para o MVP mas torna o app frágil a mudanças de configuração.

**Para o DTIC:** o catálogo já foi arquitetado para vir do FormCreator via API.
Este é o modelo correto e deve ser mantido.

---

### P-14: Regras de Visibilidade de Ticket vêm do GLPI

O escopo de visibilidade (`OWN_ONLY`, `GROUP_OR_ASSIGNED`, `ALL_IN_ENTITY`) é
definido pelo perfil no GLPI (`ProfileRight` com bits de leitura). O app deve
descobrir esse escopo — não assumir qual é.

`GlpiRulesClient.visibilityScope(profileId)` já oferece essa consulta a partir do
asset JSON. Para o DTIC, o ideal seria consultar via `GET /ProfileRight` em runtime.

---

### P-15: Transições de Status vêm do GLPI

As transições permitidas por perfil são configuráveis no GLPI (Configurar >
Perfis > aba Assistência > transições). O asset `glpi_rules_sis.json` captura isso
em build time. O ideal para o DTIC seria descobrir em runtime.

`GlpiRulesClient.allowedStatusTransitions(profileId, current)` já oferece essa
API. O app usa para renderizar apenas os botões de status válidos para o perfil
atual.

---

## Síntese para o App DTIC

### O que reutilizar diretamente

- `GlpiStatus` e `GlpiStatusMapper` — os códigos 1-6 são universais.
- Padrão de `SessionContext` — extrair identidade do `getFullSession`.
- Padrão de `TicketPermissionDecision` — flags booleanas derivadas, não condições na UI.
- `GlpiRulesClient` e o mecanismo de asset JSON (com atualização mais frequente).
- Guardas de execução antes de mutação (P-3).
- Resolução de nomes humanos com cache (P-11).
- Mecanismo de followup para validar solução (P-9).
- Payload mínimo sem campos de atribuição não autorizados (P-7).

### O que reescrever para o DTIC

Os componentes a seguir refletem a estrutura organizacional específica da SIS e precisam ser completamente redesenhados para o DTIC:

- `OperationalRole` — papéis DTIC têm estrutura diferente de SIS.
- `TicketDomain` — domínios DTIC podem ser completamente diferentes.
- `TicketQueueType` — filas DTIC refletem sua estrutura de tickets.
- `OperationalRoleResolver` — IDs de grupos DTIC precisam ser descobertos dinamicamente ou via configuração.
- `TicketDomainResolver` — categorias DTIC podem não seguir o padrão SIS (manutencao/conservacao).
- Catálogo de serviços — sempre dinâmico via API (FormCreator), nunca estático no app.

### O que nunca repetir

- Hardcode de IDs de grupos de outra instância.
- Catálogo estático de categorias com IDs fixos.
- Comparação de permissões por nome de perfil (usar ID).
- Assumir que o perfil tem UPDATE de ticket sem verificar (levou semanas de debugging).
- Enviar `_groups_id_assign` sem confirmar que o perfil tem direito de atribuição.

---

*Este documento representa o conhecimento acumulado durante o desenvolvimento do
SIS Mobile. Cada princípio aqui listado tem origem em um incidente real, uma
descoberta de API ou uma decisão arquitetural documentada nas autópsias e
invariantes do projeto.*
