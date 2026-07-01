# Metodologia de Descoberta de Regras do GLPI

> **O que este documento é:** o *modo de pensar* canônico para descobrir **onde mora
> qualquer regra ou configuração** do GLPI e decidir **como o app deve consumi-la**.
> É genérico e reaplicável a qualquer instância (SIS, DTIC e os próximos), não específico
> de uma instalação.
>
> **O que este documento NÃO é:** um inventário de regras (isso é o
> [`MAPA_FONTE_DA_VERDADE_GLPI.md`](MAPA_FONTE_DA_VERDADE_GLPI.md)) nem um plano de
> refatoração de código.

---

## 1. A ideia-âncora: protocolo × configuração-de-instância

Antes de qualquer investigação, toda informação do GLPI cai em **uma de duas classes**.
Confundir as duas é a causa-raiz de meses de retrabalho neste projeto.

| | **Protocolo / esquema** | **Configuração de instância** |
|---|---|---|
| O que é | O contrato da API/modelo de dados do GLPI | Os dados que um admin configura na web |
| Estabilidade | Estável por **versão** do GLPI | Muda por **instalação** e **a qualquer momento** |
| Exemplos | nomes de itemtype (`Ticket`, `Profile`); nomes e bits dos *rights* (`Ticket::READMY=1`); field-IDs de search; formato de `getFullSession` | *quais* perfis existem; *quais* rights cada perfil tem; categorias, status, localizações, grupos, templates, formulários; RuleTicket; "limitar sub-níveis" |
| Pode ser constante no código? | **Sim** — é contrato, não config do cliente | **Nunca** — tem que ser **buscado de um endpoint e projetado** |

**Regra de ouro:** se o valor pode ser diferente em outro GLPI **ou** mudar quando um
admin mexe na web, ele é **configuração de instância** e o app **não pode** hardcodá-lo.

### O erro histórico do SIS Mobile (exemplo concreto)
O app trata configuração-de-instância como se fosse protocolo:
- `OperationalRole` decide o papel por *string-matching* no **nome** do perfil
  (`lib/models/operational_role.dart`) — mas o nome do perfil é configuração de instância.
- Permissões saem de **IDs de grupo cravados** (21, 22, 49) em
  `lib/policy/permission_service.dart` e `lib/models/ticket_domain.dart` — IDs de grupo
  são configuração de instância.
- Os *rights* reais (`Ticket::READMY`/`READGROUP`/`READALL`...), que **são** o protocolo
  que decide visibilidade, **nunca são lidos** de `getFullSession`.

Resultado: cada GLPI novo tem nomes e IDs diferentes → o palpite quebra → re-hardcoda.
A metodologia abaixo existe para **nunca mais** cair nisso.

---

## 2. A cadeia de 7 perguntas

Para **qualquer** comportamento observado no GLPI, percorra esta cadeia. Não pule etapas:
cada uma elimina uma hipótese e aproxima da fonte da verdade.

| # | Pergunta | Por que importa |
|---|----------|-----------------|
| 1 | **O que eu observo?** | Descreva o *sintoma* puro, sem teoria. Ex.: "o técnico vê os tickets dele como requerente". Separe fato de interpretação. |
| 2 | **Onde isso se configura na web?** | A tela em **Administração** ou **Configuração** é a fonte da verdade *para humanos*. Achar a tela já nomeia o domínio. (Inventário no doc do mapa.) |
| 3 | **Que conceito de domínio governa isso?** | O GLPI tem um conjunto **finito** de domínios: Profile, Entity, Rule engine, Template, ITILCategory, FormCreator, Notification, SLA/OLA, Dropdown. Classificar aqui é metade da batalha. |
| 4 | **Onde está persistido (BD)?** | A tabela é a fonte da verdade *última* e desambigua quando a UI engana. Ex.: `glpi_profilerights(name, rights)`. |
| 5 | **Está exposto na API REST?** | Três caminhos (ver §3). Se sim, é isto que o app consome. Se só BD, registre como limitação explícita. |
| 6 | **É derivado-da-sessão ou config global?** | Define a estratégia de cache: buscar a cada login (sessão) vs. buscar uma vez com invalidação (global). |
| 7 | **Qual o contrato do app?** | Classifique (protocolo vs. instância) e defina: *o app busca do endpoint X e projeta; nunca hardcoda o valor de instância*. |

---

## 3. Os três caminhos da API REST do GLPI

A API REST (`apirest.php`) expõe quase toda configuração por **três mecanismos**.
Saber qual usar é o coração da pergunta 5.

1. **Sessão (estado derivado do perfil/entidade ativos)**
   - `GET /getFullSession` → o `$_SESSION` inteiro, incluindo
     `session.glpiactiveprofile` (com os **rights** do perfil ativo por itemtype),
     `glpiactive_entity`, `glpigroups`, `glpiID`, `glpiname`.
   - `GET /getActiveProfile`, `GET /getActiveEntities`.
   - `GET /getMyProfiles`, `GET /getMyEntities` → o que o usuário **pode** assumir.
   - `POST /changeActiveProfile`, `POST /changeActiveEntities` → trocar contexto
     (é o que o **seletor de perfil** do GLPI web faz).
   - `GET /getGlpiConfig` → `$CFG_GLPI` global (faixas, defaults globais).
   - **Use para:** "o que este usuário, neste perfil, neste momento, pode ver/fazer".

2. **Itemtype genérico (qualquer registro `CommonDBTM`)**
   - `GET /:itemtype/:id` e `GET /:itemtype` (com `expand_dropdowns`, `get_hateoas`).
   - `GET /:itemtype/:id/:sub_itemtype` para relações.
   - **Use para:** ler a configuração em si (um `Profile`, uma `ITILCategory`, uma
     `PluginFormcreatorQuestion`, uma `Rule`). Praticamente **todo** registro de config
     é um itemtype e portanto legível por aqui.

3. **Search (consulta com critérios)**
   - `GET /search/:itemtype` + `GET /listSearchOptions/:itemtype` (descobre os field-IDs).
   - **Use para:** listar/filtrar muitos registros (ex.: "tickets onde sou requerente").

> **Caveat crítico (não esquecer):** não presuma que o servidor reaplica toda a lógica da
> web num `POST` via API. Há **relato não confirmado** de que **templates** de categoria
> não são aplicados ao criar via API
> ([GLPI issue #15225](https://github.com/glpi-project/glpi/issues/15225) — fechado como
> *stale*; **não cobre RuleTicket**). O comportamento de **RuleTicket** via API deve ser
> **confirmado empiricamente** na instância, **não** presumido a partir desse issue. Em
> qualquer caso, o app precisa **buscar e projetar** essas regras (campos obrigatórios,
> atribuição esperada) e **validar o read-back** do ticket criado.

---

## 4. Exemplo resolvido ponta-a-ponta

**Caso real do SIS:** *"o técnico vê os próprios tickets dele como requerente"* —
exatamente a confusão que originou esta investigação.

| # | Pergunta | Resposta |
|---|----------|----------|
| 1 | Observo | Logado como técnico, a fila mostra tickets em que ele é o **requerente**, não só os que ele atende. |
| 2 | Tela web | **Administração → Perfis → [Perfil] → aba Assistência** (opções de visibilidade de tickets do perfil). |
| 3 | Conceito | **Profile rights** — o bitmask do itemtype `Ticket` dentro do perfil. |
| 4 | BD | `glpi_profilerights`, linha `profiles_id=<perfil>`, `name='ticket'`, coluna `rights`=bitmask. |
| 5 | API | **Sim.** Os rights chegam em `GET /getFullSession` → `session.glpiactiveprofile['ticket']`, e em `GET /getActiveProfile`. A definição estática também via `GET /Profile/:id`. |
| 6 | Sessão/global | **Derivado da sessão** — depende do perfil ativo; recarregar a cada login e a cada `changeActiveProfile`. |
| 7 | Contrato do app | Ler o **bitmask** e decidir a visibilidade a partir dele (ver tabela abaixo). **Nunca** decidir por `glpiactiveprofile.name == "tecnico"`. |

### O protocolo por trás (rights do Ticket — GLPI 10, `src/Ticket.php`)
Estes valores são **protocolo** (estáveis por versão) e *podem* ser constantes no app,
desde que rotulados como tal e verificados contra a versão do GLPI:

| Constante | Valor | Significado |
|-----------|------:|-------------|
| `READMY` | 1 | Ver tickets onde sou requerente/observador/criador |
| `READALL` | 1024 | Ver **todos** os tickets (da entidade) |
| `READGROUP` | 2048 | Ver tickets dos meus grupos |
| `READASSIGN` | 4096 | Ver tickets atribuídos a mim/meu grupo |
| `ASSIGN` | 8192 | Atribuir tickets |
| `STEAL` | 16384 | Roubar atribuição |
| `OWN` | 32768 | Tornar-se responsável |
| `CHANGEPRIORITY` | 65536 | Alterar prioridade |
| `SURVEY` | 131072 | Responder pesquisa de satisfação |

> Assim, "técnico vê os próprios como requerente" **não é um bug e não é uma regra a
> codar**: é simplesmente o bit `READMY` ligado no perfil. O app só precisa **ler o
> bitmask** e montar o filtro de visibilidade correspondente. A "regra" mora 100% no
> GLPI; o app é um projetor.

---

## 5. Template em branco (preencher a cada regra nova)

Copie esta tabela ao investigar qualquer nova regra e arquive o resultado no
[`MAPA_FONTE_DA_VERDADE_GLPI.md`](MAPA_FONTE_DA_VERDADE_GLPI.md).

```
Regra/observação: ____________________________________________

1. Observo (fato puro): _______________________________________
2. Tela web (Administração/Configuração → ...): _______________
3. Conceito/itemtype GLPI: ____________________________________
4. Tabela(s) no BD: ___________________________________________
5. Endpoint(s) API: ___________________________________________
   [ ] sessão  [ ] itemtype  [ ] search  [ ] só BD (justificar): _____
6. Sessão (por login) ou global (cacheável)?: _________________
7. Classe: [ ] protocolo (pode ser constante)  [ ] instância (proibido hardcodar)
   Contrato do app (buscar de ___ e projetar ___): ____________
```

**Registro obrigatório:** toda descoberta vira uma linha no mapa; toda validação contra o
GLPI real é **read-only** por padrão (ver `CLAUDE.md`).

---

## 6. Como esta metodologia conversa com o que já existe

- [`docs/MODELO_CONCEITUAL_GLPI_SIS_PARA_DTIC.md`](../MODELO_CONCEITUAL_GLPI_SIS_PARA_DTIC.md)
  descreve as 8 camadas "GLPI como motor de regras" — esta metodologia é o **procedimento
  operacional** para preencher aquele modelo com fatos verificáveis.
- [`docs/domain/ticket/SOURCES_OF_TRUTH.md`](../domain/ticket/SOURCES_OF_TRUTH.md) mapeia
  origem de dado **por superfície de UI**; aqui mapeamos **por regra/configuração**.
- [`docs/checklists/HERMES_MISSAO_MAPEAMENTO_CHECKLISTS.md`](../checklists/HERMES_MISSAO_MAPEAMENTO_CHECKLISTS.md)
  já aplica este padrão para RuleTicket via `GET /Rule|/RuleAction|/RuleCriteria` — é um
  caso resolvido de referência.
