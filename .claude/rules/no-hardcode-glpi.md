---
paths:
  - "lib/policy/**"
  - "lib/models/operational_role.dart"
  - "lib/models/ticket_domain.dart"
  - "lib/checklists/**"
  - "lib/state/app_state_ticket_support.dart"
  - "lib/dtic/models/dtic_formcreator_models.dart"
  - "lib/catalog/**"
  - "lib/formcreator/**"
  - "lib/screens/form_template.dart"
---

# Regra: nunca hardcodar o que o GLPI já expõe

Você está editando um arquivo que decide **visibilidade / permissão / classificação / render
de formulário**. Antes de introduzir OU manter qualquer constante ligada a
perfil/grupo/categoria/status/regra, classifique-a (protocolo vs. configuração de instância —
ver `docs/glpi/METODOLOGIA_DESCOBERTA_REGRAS_GLPI.md`). Config de instância é **proibido**
hardcodar.

Fontes corretas (validadas ao vivo — `docs/discovery/glpi-live/COBERTURA_VALIDADA_GLPI_SIS.md`):

- **Permissão / visibilidade** → bitmask de rights em
  `getFullSession.session.glpiactiveprofile['ticket']`. **NUNCA** decidir por nome de perfil
  (string-match) nem por IDs de grupo cravados (21/22/49). Bits do `Ticket` (fonte
  `src/Ticket.php`, conferido): `READMY=1, READALL=1024, READGROUP=2048, READASSIGN=4096,
  ASSIGN=8192, STEAL=16384, OWN=32768, CHANGEPRIORITY=65536, SURVEY=131072`.
- **Domínio de grupo** → `GET /Group`. **Perfis disponíveis / troca** → `getMyProfiles` +
  `changeActiveProfile`.
- **Config de questão FormCreator** (ex.: "limitar sub-níveis") → campo `values` (JSON):
  `show_tree_depth`, `show_tree_root`, `selectable_tree_root`, `entity_restrict`.
- **Opções de árvore (categoria/tipo/localização)** → oferecer **apenas folhas
  selecionáveis**. O nó raiz (`id == root_id`) não é opção quando
  `selectable_tree_root="0"`; nós intermédios (ancestrais de outra opção via
  `full_label` "X > …") são cabeçalhos, não opções. Usar
  `GovernedQuestion.selectableOptions` (`lib/catalog/governed_service_catalog.dart`) —
  **nunca** mapear `options`/`options_sample` cru. **Fonte runtime = catálogo
  governado pré-resolvido**, NÃO chamada live a `/ITILCategory`: perfis
  Solicitante/GG recebem `ERROR_RIGHT_MISSING` ao ler ITILCategory (validado ao
  vivo 2026-06-28). Matching de serviço/sub-serviço deve tratar hífen↔espaço como
  equivalentes (`_normalizeGoverned`).
- **Condições FormCreator** → `show_condition` tem **9 operadores** (1=igual … 9=regex), não
  só igualdade; `show_logic` 1=AND/2=OR; `show_rule` também na **seção**.

Regra de ouro: toda decisão aqui precisa de **evidência** (JSON real em
`docs/discovery/glpi-live/evidence/` ou validação ao vivo via `tool/glpi-discovery/`), nunca
"eu acho que o GLPI faz X". Em dúvida, rodar a descoberta — não supor.
