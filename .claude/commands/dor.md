---
description: Materializa o checklist de Definition of Ready (docs/quality/DOR.md) para a tarefa atual antes de implementar
---

Leia `docs/quality/DOR.md` e a lista de gatilhos de DOR referenciada em `AGENTS.md`.

Aplique o checklist à tarefa descrita em $ARGUMENTS (ou, se vazio, à tarefa em
discussão nesta conversa). Reporte de forma explícita:

1. Se a tarefa bate algum gatilho de DOR (fluxo, status, permissão, cache, offline,
   acesso externo, build/Android, opção de FormCreator, superfície compartilhada
   SIS/DTIC). Se nenhum gatilho bater, diga isso e recomende seguir direto sem Plan
   Mode.
2. Para cada critério do DOR aplicável: atendido / não atendido / não se aplica, com
   justificativa curta.
3. Se a tarefa envolve regra GLPI (permissão, FormCreator, categoria/status): que
   evidência viva ou já documentada (`docs/discovery/glpi-live/`) sustenta a decisão —
   nunca suposição, conforme `.claude/rules/no-hardcode-glpi.md`.
4. O que falta resolver antes de a tarefa estar pronta para implementação.

Não implemente nada neste comando — a saída é o checklist preenchido, não código.
