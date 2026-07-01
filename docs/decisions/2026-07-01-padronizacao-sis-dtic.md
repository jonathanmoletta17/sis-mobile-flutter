# Decisão: SIS e DTIC compartilham fundação de UI, não regra de negócio

- **Status:** aceita
- **Data:** 2026-07-01 (formalização como ADR; decisão original documentada
  anteriormente em `docs/PADRONIZACAO_APPS_SIS_DTIC.md`)

## Contexto

SIS Mobile e DTIC Mobile precisavam de um contrato explícito sobre o que é
compartilhado entre as duas linhas de produto e o que é intencionalmente separado, para
evitar tanto duplicação desnecessária de UI quanto acoplamento indevido de regra de
negócio (este segundo risco já se materializou uma vez — ver
`docs/audits/ACOPLAMENTO_SIS_DTIC_2026-06-27.md`).

## Decisão

- SIS e DTIC compartilham a mesma fundação de app mobile operacional (tema visual,
  tokens de UI, componentes neutros como `SisPageScaffold`/`SisEmptyState`,
  formatadores de texto, enums de status GLPI), mas **não são tratados como a mesma
  aplicação com textos trocados**.
- Cada linha mantém entrypoint, estado (`AppState` vs. `DticAppState`), serviço HTTP
  (`GlpiClient` vs. `DticGlpiClient`), catálogo e configuração de `.env` próprios.
- Nenhuma regra de negócio, ID de grupo/categoria ou decisão de permissão de uma linha
  deve vazar para a outra por conveniência de reaproveitamento de código.

## Consequências

- Toda superfície nova compartilhada entre as linhas deve ser neutra por construção
  (sem dependência de `AppState` ou `DticAppState` específico) antes de ser
  reaproveitada.
- Mudança em `lib/dtic/` que importe diretamente algo de `lib/screens/`, `lib/state/`
  ou outro caminho SIS-específico fora do que é compartilhado por contrato deve ser
  tratada como possível regressão desta decisão.
- Recomenda-se formalizar a lista de diretórios "compartilhados por contrato"
  (`lib/theme/`, `lib/formcreator/`, `lib/widgets/ui/`) diretamente em
  `docs/PADRONIZACAO_APPS_SIS_DTIC.md`, e reforçar isso com a checagem automatizada
  descrita em `tool/check_sis_dtic_boundary.sh` (ver referência abaixo).

## Referências

- `docs/PADRONIZACAO_APPS_SIS_DTIC.md` — contrato completo de padronização.
- `docs/PLANO_DTIC_MOBILE_APROVEITAMENTO_SIS_MOBILE.md` — plano de reaproveitamento
  original.
- `docs/audits/ACOPLAMENTO_SIS_DTIC_2026-06-27.md` — incidente de acoplamento já
  ocorrido e corrigido.
- `tool/check_sis_dtic_boundary.sh` — checagem mecânica leve da fronteira
  SIS/DTIC (criada em 2026-07-01 como consequência direta desta decisão).
