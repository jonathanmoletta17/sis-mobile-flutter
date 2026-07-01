---
description: Executa o protocolo de autopsia completa (docs/AUTOPSIA_COMPLETA.md) para divergência entre UI/API/estado/permissões
---

Leia `docs/AUTOPSIA_COMPLETA.md` por inteiro e siga o protocolo investigativo
completo, sem pular etapas, para a divergência descrita em $ARGUMENTS (ou, se vazio,
o problema em discussão nesta conversa).

Use este comando para divergência entre UI, API, estado remoto, permissões ou
transições críticas de ticket (não para bug localizado simples — para esses use
`/autopsia-rapida`).

Quando a divergência tocar domínio de ticket, confronte também
`docs/domain/ticket/STATES.md`, `TRANSITIONS.md`, `INVARIANTS.md` e
`SOURCES_OF_TRUTH.md`. Quando tocar permissão/visibilidade/FormCreator, aplique a
regra de evidência de `.claude/rules/no-hardcode-glpi.md` — validação ao vivo
read-only antes de qualquer conclusão, nunca suposição.

A saída deve separar sempre: fato observado, hipóteses, evidência necessária, causa
raiz provável com nível de confiança explícito, correção mínima e aprendizado de
processo registrado.
