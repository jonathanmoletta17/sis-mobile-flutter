# docs/audits/

Evidência histórica e pontual: auditorias, relatórios de execução, certificações e
notas de entrega, cada um datado e amarrado ao estado do projeto naquele momento.

**Nada aqui é normativo.** Se um destes documentos e um documento normativo (ex.:
`docs/RUNTIME_CANONICO_E_VALIDACAO.md`, `AGENTS.md`, `docs/quality/DOR.md`)
divergirem, o normativo vence — o conteúdo desta pasta é prova de que algo foi
validado numa data, não permissão permanente para repetir a mesma ação sem nova
validação.

Ver `docs/README.md` → "Fonte de verdade" para a hierarquia completa, e
`docs/decisions/` para as decisões arquiteturais que estes relatórios eventualmente
embasaram.

## Conteúdo

- `AUDITORIA_OPERACIONAL_TECNICOS_APK_PWA_ANEXOS_2026-06-25.md` — auditoria funcional do fluxo de técnicos, consistência APK/PWA, fila, atribuição/status, anexos.
- `ACOPLAMENTO_SIS_DTIC_2026-06-27.md` — incidente de IDs de grupo SIS hardcoded vazando para lógica também usada por DTIC, e a correção aplicada.
- `RELATORIO_DTIC_MOBILE_EXECUCAO_SEGURA_2026-05-18.md` — relatório de execução segura do MVP DTIC Mobile.
- `RELATORIO_SIS_MOBILE_E2E_MUTAVEL_CONTROLADO_2026-05-18.md` — relatório de teste end-to-end mutável controlado do SIS Mobile.
- `REVISAO_REGRAS_STATUS_TELA_ACAO_2026-05-18.md` — revisão de regras de status/tela/ação.
- `AUDITORIA_ATRIBUICOES_REAIS_2026-06-28.md` — auditoria de atribuições reais de perfil/grupo.
- `CERTIFICACAO_PERFIS_REGRAS_2026-06-28.md` — matriz mestre de certificação de perfis e regras.
- `RELATORIO_CERTIFICACAO_2026-06-28.md` — resultados de certificação (regras R1/R2).
- `AUDITORIA_FORMCREATOR_RUNTIME_2026-06-27.md` — auditoria preparatória do runtime FormCreator (ver nota de complemento live no próprio arquivo).
- `VALIDACAO_GLPI_LIVE_2026-06-27.md` — validação direta Web/Admin + API contra GLPI vivo.
- `VALIDACAO_ONDA0_REDE_SEGURANCA_2026-06-27.md` — validação de onda 0 / rede de segurança dos Workers SIS e DTIC.
- `ENTREGA_2026-04-30.md`, `NOTA_2026-04-30.md`, `POS_FERIAS.md` — registros operacionais pontuais de entrega/retomada.
