# Arquitetura de Checklists — ponta a ponta e decisão de fonte (asset vs Worker)

Data: 2026-06-27
Branch: `fix/onda0-rede-seguranca`
Base verificada nos commits `393ef25` / `4539e83` / `7659712`.
Modo: read-only sobre código; cada afirmação aterrada em arquivo:linha.

Objetivo: mapear como visibilidade, perfis, grupos, entidades, categorias, condições
e submissão de checklists se conectam de ponta a ponta, e decidir conscientemente a
fonte do catálogo (asset embarcado vs Worker runtime), respeitando
`.claude/rules/no-hardcode-glpi.md`.

---

## 1. Cadeia de dados ponta a ponta

```
GLPI SIS (FormCreator + RuleTickets)
   │  (1) build-time, read-only, --live
   ▼
tool/checklists/build_sis_checklists_catalog.mjs
   │  deriva escopo dos forms 48-52; NÃO hardcoda targets
   ▼
3 artefatos gerados (mesmo conteúdo):
   • assets/sis_checklists_catalog.json            (app)
   • test/fixtures/sis_checklists_catalog.json     (testes)
   • tool/external-access/workers-vpc/src/checklist_catalog.js (Worker)
   │
   ├─(2A) app carrega ASSET embarcado  ──► AppState (HOJE)
   └─(2B) Worker serve /metadata/mobile/sis/checklists ──► SisChecklistMetadataClient (PRONTO, NÃO LIGADO)
   │
   ▼  (3) gate de visibilidade por perfil OU grupo
SisChecklistCatalogScreen  ──► SisChecklistFormScreen
   │  (4) render dinâmico via engine (show_rule / show_condition / show_logic)
   ▼  (5) submissão
checklist_submission.toTicketInput()  ──► POST /Ticket (via Worker allowlist)
   ▼  (6) GLPI RuleTickets disparam server-side
entidade + categoria → atribuição de grupo (CC-MANUTENCAO 22 assigned, 49 observer)
```

---

## 2. Estrutura do catálogo (verificada)

Chaves top-level: `schema_version`, `generated_at`, `source_mode`,
`source_snapshot_sha256`, `active_form_ids`, `active_target_ids`, `source_counts`,
`forms`, `sections`, `questions`, `conditions`, `targets`, `categories`.

**Form** (gate de acesso):
```json
{ "id": 48, "name": "CHECKLIST REFRIGERAÇÃO", "is_active": true, "is_visible": true,
  "helpdesk_home": true, "profile_ids": [4], "group_ids": [22] }
```

**Target** (contrato de submissão — "local de aplicação"):
```json
{ "id": 369, "form_id": 50, "name": "HIDRÁULICO 951",
  "destination_entity_value": 58, "category_rule": 2, "category_id": 151,
  "location_rule": 2, "location_question": 83, "urgency_rule": 1, "type_rule": 1,
  "show_rule": 2 }
```

**Category** (classificação ITIL):
```json
{ "id": 147, "name": "Checklist", "completename": "Manutenção > Checklist",
  "parent_id": 104, "level": 2 }
```

---

## 3. Permissões, grupos e entidades — como cada peça se conecta

| Dimensão | Campo no catálogo | Fonte GLPI | Onde é decidido | Arquivo:linha |
| --- | --- | --- | --- | --- |
| **Quem vê o checklist** | `form.profile_ids`, `form.group_ids` | `formcreator_forms_profiles` + `PluginFormcreatorForm_Group` (`access_rights=2`) | App casa contra perfil ativo OU grupos da sessão | `checklist_catalog.dart:194-195` |
| **Quais checklists no form** | `targets[]` (`form_id`) | `PluginFormcreatorTargetTicket` filtrado por form ativo | Derivado dinamicamente | `build_...mjs:334` |
| **Onde o ticket cai (entidade)** | `target.destination_entity_value` = 58 (DMCPP) | TargetTicket | Fail-closed se ≤0 | `checklist_submission.dart:158-159,188` |
| **Classificação (categoria)** | `target.category_id` (147-152) | `category_question`/`category_rule` | Fail-closed se ≤0 | `checklist_submission.dart:153-155,187` |
| **Render dinâmico** | `conditions[]` `show_rule`/`show_condition`/`show_logic` | Condition + Section/Question/Target | Engine de visibilidade | `checklist_condition_engine.dart` |
| **Quem recebe (atribuição)** | — (NÃO no payload) | `RuleTickets` server-side | **GLPI**, por entidade+categoria | (não há código de atribuição no app) |

### 3.1 Visibilidade (gate)

`SisChecklistCatalogScreen.build` → `catalog.formsVisibleToUser(activeProfileId, userGroupIds)`
(`sis_checklist_catalog_screen.dart:47`).

`formsVisibleToUser` (`checklist_catalog.dart:111-120`): form aparece sse
`isVisibleToUser(...)` **E** `targetsForForm(form.id).isNotEmpty`.

`isVisibleToUser` (`checklist_catalog.dart:194-195`) — **OR semântico**:
```dart
if (profileId != null && profileIds.contains(profileId)) return true; // perfil
return userGroupIds.any(groupIds.contains);                            // OU grupo
```

- `activeProfileId` vem de `getFullSession.glpiactiveprofile`.
- `userGroupIds` vem de `glpigroups` da sessão.
- `profileIds`/`groupIds` vêm do **catálogo gerado do GLPI** — não são cravados no app.

> **Conformidade com a regra anti-hardcode:** o gate decide por dados de
> `access_rights` que o GLPI atribui ao form (perfis/grupos do FormCreator), lidos
> da sessão real. Isso É a fonte correta para **visibilidade de formulário**. NÃO se
> usa string-match de nome de perfil nem ID de grupo cravado em lógica Dart. O
> `[4]`/`[22]` que aparecem hoje são **dado derivado**, regeneráveis; se o GLPI
> reatribuir o form a outro perfil/grupo, basta regenerar o catálogo. (Distinto do
> bitmask de **direitos de ticket** em `getFullSession`, que governa operações de
> ticket, não visibilidade de form.)

### 3.2 Entidade e categoria (submissão)

`checklist_submission.dart`:
- `toTicketInput` (`:92-110`) monta `entities_id = entityId`,
  `itilcategories_id = categoryId`.
- `prepare`/factory (`:139-188`) deriva `categoryId = target.categoryId` e
  `entityId = target.destinationEntityValue`, com **validação fail-closed**: lança se
  o target não existe, não pertence ao form, tem `category_id ≤ 0` ou
  `destination_entity_value ≤ 0`. (Bom padrão; é o oposto do fail-open do resolver
  governado normal — ver dossiê P2.)

### 3.3 Atribuição de grupo — feita pelo GLPI, não pelo app

O payload do ticket **não** contém grupo atribuído. Quem atribui é o motor
`RuleTickets` do GLPI, server-side, com base em **entidade + categoria**. Validado
em produção (tickets 8852, 9817, 9840, 9853): entidade 58 + categoria 148-152
disparam CC-MANUTENCAO (22) como `assigned` e grupo 49 como `observer`.

> Implicação de arquitetura: a "regra de negócio de quem atende" mora no GLPI, não
> no app. O app só precisa entregar **entidade + categoria corretas**. Isso reduz a
> superfície de hardcode no cliente e é coerente com a regra do projeto.

### 3.4 Submissão e Worker

- `AppState.submitChecklist` → `submitChecklistAsTicket` → `POST /Ticket`.
- Worker (`index.js`): `POST /Ticket` passa pela allowlist normal
  (`:178-191`). A submissão **FormCreator nativa**
  (`POST /PluginFormcreatorFormAnswer`) fica **bloqueada** salvo
  `ALLOW_FORMCREATOR_SUBMISSION=true` (`:186-191`) — por isso o pivot para `POST
  /Ticket` (Phase 9). Endpoint de catálogo é read-only: 405 em método ≠ GET/HEAD
  (`:208-209`).

---

## 4. As duas (na verdade três) fontes de catálogo

A "dinamicidade" tem três níveis possíveis. Hoje estamos no nível 1; o nível 2 está
construído mas desligado; o nível 3 não existe.

### Nível 1 — Asset embarcado (ESTADO ATUAL)

`AppState` carrega `assets/sis_checklists_catalog.json` via
`rootBundle.loadString` (`app_state.dart:72,85`).

- **Refresh** = rodar builder `--live` → **rebuildar APK** → **redistribuir**.
- **Prós:** funciona 100% offline; launch rápido; determinístico; zero exposição do
  GLPI em runtime; nenhuma dependência de rede.
- **Contras:** fica **stale** até novo APK. O incidente do target 369 É exatamente
  esse modo de falha — o GLPI ganhou um checklist e o app não viu até regenerar.
  Qualquer mudança no GLPI (novo target, reatribuição de perfil/grupo, nova
  categoria) é invisível até subir APK novo.

### Nível 2 — Worker serve snapshot (CONSTRUÍDO, NÃO LIGADO)

Infra que JÁ existe:
- Worker: `GET /metadata/mobile/sis/checklists` serve `SIS_CHECKLIST_CATALOG`
  (= `checklist_catalog.js`, gerado pelo mesmo builder) com ETag
  (`source_snapshot_sha256`), `304` em `If-None-Match` (`index.js:207-235`).
- Flutter: `SisChecklistMetadataClient.loadChecklistCatalog(catalogUrl)`
  (`checklist_metadata_client.dart:32-63`): fetch com `If-None-Match`, cache em
  `SharedPreferences`, **fail-safe** (nunca lança para a UI; cai no cache; cache
  vazio → null). Flag `SIS_CHECKLISTS_METADATA_URL` em `.env.example`.

> ⚠️ Nuance honesta: o que o Worker serve **também é um snapshot gerado**, não um
> passthrough ao GLPI vivo. Logo o nível 2 ainda exige rodar o builder para
> atualizar — **mas só precisa redeploy do Worker, não rebuild do APK**. Isso
> **desacopla o refresh do catálogo do ciclo de release do app**.

- **Refresh** = builder `--live` → **redeploy do Worker** (sem APK).
- **Prós:** corrige o stale sem nova distribuição; mantém offline (fallback asset +
  cache `SharedPreferences`); ETag economiza banda; infra pronta.
- **Contras:** ainda depende de alguém rodar o builder; requer ligar o cliente no
  `AppState` com fallback para o asset; precisa endpoint acessível (Worker
  `workers.dev` + VPC, já a estratégia de acesso externo do projeto).

### Nível 3 — Worker projeta GLPI ao vivo (NÃO EXISTE)

Worker consultaria FormCreator ao vivo e projetaria o catálogo sob demanda.

- **Refresh** = automático.
- **Contras:** trabalho grande; exige resolver o contrato `show_tree_depth`/condições
  (dossiê P5) e o risco de o Worker virar "renderizador FormCreator" — a auditoria
  alerta que o metadata normal hoje é `2.0-readonly-draft` com
  `formcreator_conditions=0`. Só faz sentido depois de P5 e de um contrato
  produtor/consumidor fechado.

---

## 5. Recomendação

**Adotar o Nível 2 (ligar o `SisChecklistMetadataClient` com fallback para o asset),
mantendo o asset como rede de segurança offline.** Justificativa:

1. Resolve a causa raiz do incidente 369 (catálogo stale acoplado ao release).
2. A infraestrutura já existe e é fail-safe por design.
3. Preserva offline e determinismo (fallback asset + cache).
4. Não viola a regra anti-hardcode — perfis/grupos/entidade/categoria continuam vindo
   do GLPI via builder; o app só troca a **origem** do mesmo catálogo.
5. Não compromete o futuro Nível 3, que depende de P5 ainda não feito.

### Esboço de implementação (futuro dossiê — NÃO implementado aqui)

- `AppState._loadChecklistCatalog()`: tentar
  `SisChecklistMetadataClient.loadChecklistCatalog(url: SIS_CHECKLISTS_METADATA_URL)`;
  em null/erro, cair para `rootBundle.loadString(_checklistAssetPath)`.
- Precedência: Worker (fresco) → cache `SharedPreferences` → asset embarcado.
- Gate de visibilidade e submissão **não mudam** — só a origem do `SisChecklistCatalog`.
- Testes: URL ok → usa Worker; URL vazia/erro/timeout → usa asset; `304` → usa cache.
- Operacional: documentar que atualizar checklists = rodar builder `--live` + redeploy
  do Worker; APK só muda quando muda código.

### Decisão tomada (2026-06-27) — papel do asset

Premissa confirmada pelo dono do produto: **o técnico sempre tem sinal pelo menos
uma vez antes de ir a campo.** Logo o cache (`SharedPreferences`) sempre esquenta na
primeira abertura e cobre todo o uso offline de campo.

Decisão:

- **Não** construir tela "fail-loud / conecte-se uma vez" — seria necessária só se o
  técnico pudesse cair em campo sem nunca ter sincronizado, o que não é o caso.
- **Manter o asset embarcado**, porém **repaginado como semente de instalação**, não
  como fallback offline. Razão: o "sempre tem sinal" elimina o cenário de
  *dispositivo sem rede*, mas NÃO elimina a *primeira busca falhar por outro motivo*
  (URL mal configurada, janela de deploy, bug de parse/ETag). A semente garante que o
  app nunca fica sem catálogo desde o minuto zero; custo zero, sem UI nova.
- Precedência final: **Worker fresco → cache → asset (semente)**.

### Limite remanescente (honesto)

`activeFormIds = {48,49,50,51,52}` e `checklistCategoryIds = {147..152}` no builder
seguem sendo fronteira de escopo. Um 6º form de checklist (ex.: id 53) **não** entra
sozinho — alguém precisa ampliar `activeFormIds`. É fronteira de produto, não dado;
mas vale registrar como teto da dinamicidade atual (candidato a derivar de
`PluginFormcreatorCategory`/categoria-pai "Checklist" no futuro).

---

## 6. Relação com os dossiês P1-P5

- A decisão asset↔Worker é o **item E** da auditoria (`AUDITORIA_FORMCREATOR_RUNTIME`).
- É **independente** de P1 (offline governado do fluxo genérico `GlpiTicket`, que não
  é o fluxo de checklist) e P2 (resolver governado normal). Pode ser feita antes ou
  depois.
- **Depende de P5** apenas se quiser evoluir para o Nível 3 (projeção live).
- O fail-closed do `checklist_submission` (entidade/categoria) já é o comportamento
  correto que P2 quer levar ao resolver governado normal — bom modelo de referência.
