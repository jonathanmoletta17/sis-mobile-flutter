---
description: Gera um dossiê de handoff para o Codex a partir do template em docs/AGENT_DIVISION_OF_LABOR.md
---

Leia `docs/AGENT_DIVISION_OF_LABOR.md` por inteiro, em especial o "Template de dossiê
de handoff (Claude → Codex)".

Com base no diagnóstico/causa-raiz já estabelecido nesta conversa (tema em
$ARGUMENTS, se informado), escreva um dossiê fechado seguindo exatamente esse
template — nunca partindo de suposição, só do que já foi validado nesta sessão.

Salve o arquivo em `docs/handoff/<AAAA-MM-DD>-<tema-curto>.md` (data de hoje,
`<tema-curto>` em kebab-case) e relate o caminho criado.

Regras obrigatórias do dossiê:

- Seção "Leia primeiro" deve sempre incluir `AGENTS.md` (seção "Regras compartilhadas
  de consumo do GLPI") e qualquer doc específico do domínio tocado.
- Escopo da implementação deve nomear arquivos e a mudança esperada exatamente —
  nada de "melhorar X" sem escopo fechado.
- Critério de aceite deve ser verificável (`flutter analyze` limpo, `flutter test`
  passa, comportamento observável concreto, sem hardcode de regra GLPI).
- A seção "O que DEIXAR para o Claude" deve sempre listar validação ao vivo contra
  GLPI, validação visual no app e o commit final — nunca delegar isso ao Codex.

Não implemente a mudança neste comando — a saída é o dossiê, não código.
