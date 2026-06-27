# Mapa da Fonte da Verdade do GLPI (GLPI 10 + FormCreator)

> **O que é:** o inventário mestre de **onde mora cada domínio de configuração** do GLPI
> e **como o app deve consumi-lo**. Cada domínio é mapeado em: tela web ↔ conceito/itemtype
> ↔ tabela do BD ↔ endpoint da API ↔ sessão/global ↔ classe (protocolo/instância) ↔
> contrato do app.
>
> **Como usar:** ao descobrir uma regra com a
> [`METODOLOGIA_DESCOBERTA_REGRAS_GLPI.md`](METODOLOGIA_DESCOBERTA_REGRAS_GLPI.md),
> registre o resultado aqui. Alvo: GLPI 10.x com plugin **FormCreator**. Outras versões
> divergem (notas ao fim).

**Convenção de classe:** **P** = protocolo (estável por versão; pode ser constante no
código). **I** = configuração de instância (muda por instalação/web; **proibido**
hardcodar — buscar de endpoint e projetar).

> **✅ Validado ao vivo (2026-06-27, SIS 10.0.2):** todos os domínios abaixo foram batidos na
> API real (read-only) e confirmados legíveis dinamicamente — exceto `DisplayPreference` (403).
> Régua = schema oficial (390 tabelas). Relatório + evidência + scripts reauditáveis:
> `docs/discovery/glpi-live/` e `tool/glpi-discovery/`. **Achado central:** a visibilidade é
> 100% controlada pelo **rights do perfil ativo** — com perfil técnico (id 11) tudo dá
> `403 ERROR_RIGHT_MISSING`; com Super-Admin (id 4) tudo abre. Prova de que o app deve **ler
> rights**, não codar regras.

---

## 0. Inventário de telas a varrer

A configuração relevante ao app concentra-se em dois menus do GLPI web:

- **Administração:** Usuários, Grupos, **Entidades**, **Perfis**, **Regras**
  (Dicionários, RuleTicket, RuleRight...), Filas, Logs, **Formulários** (FormCreator).
- **Configuração:** Notificações, **SLM (SLA/OLA)**, **Categorias ITIL**, Estados,
  **Geral**, Listas suspensas (dropdowns: Localização, Tipos de requisição, etc.).

Tudo abaixo é uma fatia desse inventário.

---

## 1. Perfis & Rights — *o coração da visibilidade*

| Campo | Valor |
|---|---|
| **Tela web** | Administração → Perfis → [Perfil] → abas (Geral, **Assistência**, Ferramentas...) |
| **Conceito/itemtype** | `Profile`, `ProfileRight` |
| **Tabela BD** | `glpi_profiles` (campos diretos: `interface`, `helpdesk_*`, `tickettemplates_id`...), `glpi_profilerights` (`profiles_id`, `name`, `rights` bitmask) |
| **API** | **Sessão:** `GET /getFullSession` → `session.glpiactiveprofile[<name>]` (rights do perfil ativo) e `GET /getActiveProfile`. **Estático:** `GET /Profile/:id`, `GET /getMyProfiles`. **Troca:** `POST /changeActiveProfile`. |
| **Sessão/global** | Sessão (depende do perfil ativo) |
| **Classe** | rights **bitmask** = P (valores por versão); *quais perfis/quais bits ligados* = **I** |
| **Contrato do app** | Ler o bitmask de `getFullSession`; derivar visibilidade/ações a partir dos bits. **Nunca** decidir por nome de perfil. Expor troca de perfil via `getMyProfiles`+`changeActiveProfile` (o "seletor" do canto superior direito). |

**Bitmask de rights do `Ticket` (GLPI 10, `src/Ticket.php`) — classe P:**
`READMY=1`, `READALL=1024`, `READGROUP=2048`, `READASSIGN=4096`, `ASSIGN=8192`,
`STEAL=16384`, `OWN=32768`, `CHANGEPRIORITY=65536`, `SURVEY=131072`. Os rights genéricos
(`READ=1`, `UPDATE=2`, `CREATE=4`, `DELETE=8`, `PURGE=16`...) aplicam-se a outros itemtypes.
Verificar valores contra a versão exata do GLPI da instância antes de tratar como fixos.

**Validado ao vivo (SIS 10.0.2):** `Profile`=11, `ProfileRight`=**1166**, `Profile_User`=1445,
`Entity`=85, `Rule`=171 (Criteria=262, Action=297). Com Super-Admin todos retornam 206;
com perfil técnico (11), 403. A conta de teste tem os perfis 4/6/9/11/28 (ator universal).

---

## 2. Entidades

| Campo | Valor |
|---|---|
| **Tela web** | Administração → Entidades → [Entidade] → abas (Assistência, Ativos...) |
| **Conceito/itemtype** | `Entity` |
| **Tabela BD** | `glpi_entities` (árvore + dezenas de campos de helpdesk herdados: `autoclose_delay`, `calendars_id`, `tickettemplates_id`, `anonymize_support_agents`, categorias/SLA padrão...) |
| **API** | **Sessão:** `GET /getActiveEntities`, `GET /getMyEntities`. **Estático:** `GET /Entity/:id`. |
| **Sessão/global** | Sessão (entidade ativa) + estático (config da entidade) |
| **Classe** | árvore e configs = **I** |
| **Contrato do app** | Ler entidade ativa da sessão; ler config de helpdesk da `Entity` quando precisar (defaults, autoclose). Herança: valor `-1`/`inherit` sobe na árvore. |

---

## 3. Motor de Regras (RuleTicket, RuleRight, Dicionários)

| Campo | Valor |
|---|---|
| **Tela web** | Administração → Regras → (Regras de negócio para tickets; Regras de atribuição de habilitações; Dicionários) |
| **Conceito/itemtype** | `Rule`, `RuleCriteria`, `RuleAction` (subtipo via campo `sub_type`, ex.: `RuleTicket`) |
| **Tabela BD** | `glpi_rules`, `glpi_rulecriterias`, `glpi_ruleactions` |
| **API** | `GET /Rule?searchText[sub_type]=RuleTicket&range=0-999`, depois `GET /RuleCriteria?searchText[rules_id]=<id>` e `GET /RuleAction?searchText[rules_id]=<id>` |
| **Sessão/global** | Global (cacheável; invalidar quando regras mudam) |
| **Classe** | **I** |
| **Contrato do app** | Buscar e **projetar** (ex.: prever que categoria X → grupo Y). **Caveat:** confirmar **empiricamente** se a RuleTicket é reaplicada num `POST /Ticket` via API — não presumir (o #15225 trata de *templates*, não de regras, e está *stale*) → sempre **validar read-back** do ticket criado. Padrão de descoberta já documentado em `docs/checklists/HERMES_MISSAO_MAPEAMENTO_CHECKLISTS.md`. |

Exemplos reais do SIS (instância — não codar): RuleTicket que mapeia categoria
"Manutenção"→grupo, "Conservação"→grupo, entidade→observador. IDs concretos pertencem à
instância e são descobertos, não fixados.

---

## 4. Templates de Ticket (campos obrigatórios/predefinidos/ocultos)

| Campo | Valor |
|---|---|
| **Tela web** | Configuração → ... → Modelos de tickets (e por categoria em Categorias ITIL) |
| **Conceito/itemtype** | `TicketTemplate` / `ITILTemplate` + campos mandatórios/predefinidos/ocultos |
| **Tabela BD** | `glpi_tickettemplates`, `glpi_tickettemplatemandatoryfields`, `glpi_tickettemplatepredefinedfields`, `glpi_tickettemplatehiddenfields` |
| **API** | `GET /TicketTemplate/:id` e os sub-itemtypes de campos (mandatory/predefined/hidden) via itemtype genérico |
| **Sessão/global** | Global por template; template **efetivo** depende de categoria/entidade/perfil |
| **Classe** | **I** |
| **Contrato do app** | Resolver o template da categoria/entidade selecionada e **projetar** quais campos exigir/pré-preencher/ocultar no formulário. É a fonte correta de "quais campos são obrigatórios" — não uma lista fixa no app. |

---

## 5. Categorias ITIL

| Campo | Valor |
|---|---|
| **Tela web** | Configuração → Categorias ITIL → [Categoria] |
| **Conceito/itemtype** | `ITILCategory` |
| **Tabela BD** | `glpi_itilcategories` (`is_helpdeskvisible`, `tickettemplates_id`, `groups_id`, `users_id`, árvore `completename`...) |
| **API** | `GET /ITILCategory` (+ `expand_dropdowns`) |
| **Sessão/global** | Global |
| **Classe** | **I** |
| **Contrato do app** | Buscar a árvore; respeitar `is_helpdeskvisible`; usar `completename` para hierarquia. **Não** manter lista fixa de categorias/IDs no app. |

---

## 6. FormCreator (GLPI 10) — *onde mora "limitar sub-níveis"*

| Campo | Valor |
|---|---|
| **Tela web** | Administração → Formulários → [Formulário] → Seções → Questões |
| **Conceito/itemtype** | `PluginFormcreatorForm`, `...Section`, `...Question`, `...Condition`, `...TargetTicket`, `...Form_Profile` |
| **Tabela BD** | `glpi_plugin_formcreator_forms`, `..._sections`, `..._questions` (config da questão em colunas + JSON), `..._conditions`, `..._targettickets`, `..._forms_profiles` |
| **API** | `GET /PluginFormcreatorForm`, `.../PluginFormcreatorSection`, `.../PluginFormcreatorQuestion/:id`, `.../PluginFormcreatorCondition`, `.../PluginFormcreatorTargetTicket`, `.../PluginFormcreatorForm_Profile` (todos via itemtype genérico) |
| **Sessão/global** | Global; **visibilidade do formulário por perfil** via `Form_Profile` (cruzar com perfil ativo) |
| **Classe** | **I** |
| **Contrato do app** | Buscar catálogo por API e renderizar dinamicamente (é o que `lib/dtic/services/dtic_glpi_client.dart` já faz — **o padrão certo**). Aplicar `Condition` para visibilidade condicional; `TargetTicket` para mapear form→categoria/entidade. |

**"Limitar sub-níveis" (a evidência que originou a investigação) — VALIDADO AO VIVO
(2026-06-27, SIS 10.0.2):** numa questão `fieldtype="dropdown"` do itemtype `Location`,
os parâmetros ficam no campo **`values` (JSON)** da questão, em
`glpi_plugin_formcreator_questions`. Confirmado pela API com dados reais:

| Questão | `show_tree_depth` | `show_tree_root` | `selectable_tree_root` | `entity_restrict` |
|---|---|---|---|---|
| id=3  "Localização" | **2** | 70 | 0 | 2 |
| id=20 "Localização" | 0  | 36 | 0 | 2 |
| id=29 "Localização" | **-3** | 27 | 0 | 2 |
| id=37/46 "Localização" | 2 | 70 | 0 | 2 |

`show_tree_depth=2` é exatamente o "Limitar Sub níveis = 2" da UI; `selectable_tree_root=0`
= "Raiz selecionável: Não"; `entity_restrict=2` = "Restrição de entidade: Formulário".
**Valores variam por formulário** (2, 0, -3...) — é a causa raiz dos **formulários
duplicados por perfil**: mesma pergunta, regra de poda da árvore diferente.

- **Leitura:** usar **listagem** `GET /PluginFormcreatorQuestion?searchText[name]=...` (ou por
  seção). **NÃO** usar `GET /PluginFormcreatorQuestion/:id` para dropdown/glpiselect — retorna
  HTTP 500 (bug FormCreator [#3400](https://github.com/pluginsGLPI/formcreator/issues/3400)).
- **Contrato do app:** parsear `values` e aplicar `show_tree_depth`/`show_tree_root` ao podar a
  árvore de `Location`. **Hoje o app descarta esse JSON** — débito técnico registrado.
  Evidência: `docs/discovery/glpi-live/COBERTURA_VALIDADA_GLPI_SIS.md`.

---

## 7. Dropdowns de protocolo e estados

| Campo | Valor |
|---|---|
| **Tela web** | Configuração → Listas suspensas / Estados; Configuração → Geral (faixas) |
| **Conceito/itemtype** | `RequestType`, `SolutionType`, `TaskCategory`, `Location`, status de ticket (1–6), urgência/impacto/prioridade |
| **Tabela BD** | `glpi_requesttypes`, `glpi_solutiontypes`, `glpi_locations`, ... (status são constantes do core) |
| **API** | itemtypes correspondentes; `GET /getGlpiConfig` para faixas/defaults globais (`$CFG_GLPI`) |
| **Sessão/global** | Global |
| **Classe** | status (1–6) e os **enums** = P; *quais* localizações/tipos existem = **I** |
| **Contrato do app** | Os 6 status e os enums de urgência/prioridade são protocolo (podem ser constantes rotuladas). Listas de localização/tipos/etc. = buscar por itemtype. |

Status do ticket (P): `1 Novo`, `2 Em atendimento (processando)`, `3 Planejado`,
`4 Pendente`, `5 Solucionado`, `6 Fechado`. Já modelado em `docs/domain/ticket/STATES.md`.

---

## 8. Notificações / SLA-OLA / Grupos & Usuários

| Domínio | itemtype | Tabela | API | Classe |
|---|---|---|---|---|
| Notificações | `Notification`, `NotificationTemplate` | `glpi_notifications`, `glpi_notificationtemplates` | itemtype | I |
| SLA/OLA | `SLA`, `OLA`, `SLM` | `glpi_slas`, `glpi_olas`, `glpi_slms` | itemtype | I |
| Grupos | `Group` | `glpi_groups` | `GET /Group`, `GET /Group/:id` | I |
| Usuários | `User` | `glpi_users` | `GET /User`, `GET /User/:id` | I |

Consumo pelo app hoje é menor, mas entram no mapa para completude e para os próximos GLPIs.

---

## 9. Cobertura e lacunas

- Toda linha acima tem endpoint de API **exceto** detalhes internos de algumas tabelas de
  config que não têm itemtype exposto (raro; quando ocorrer, registrar como "só BD" e
  decidir entre `getGlpiConfig` ou aceitar a limitação).
- Itens **não** cobertos por serem fora do escopo atual do app: inventário de ativos,
  software, financeiro. Adicionar sob demanda.

## 10. Notas de versão

- **GLPI 9.5:** FormCreator com schema de questões mais antigo (parâmetros como colunas);
  rights podem ter constantes diferentes — reverificar `src/Ticket.php`.
- **GLPI 11:** **Forms é nativo do core** (itemtype `Glpi\Form\Form` / `Question`),
  FormCreator deixa de ser a fonte — a seção 6 muda inteira. Os demais domínios
  (Perfis, Regras, Templates, Categorias) permanecem conceitualmente válidos.
- Sempre confirmar a versão via `GET /getGlpiConfig` (campo de versão) ou rodapé do GLPI
  web **antes** de tratar qualquer valor como protocolo.
