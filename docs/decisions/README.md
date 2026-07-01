# docs/decisions/

Registro curto e datado de decisões arquiteturais/estratégicas ("por que decidimos
X"), no estilo ADR-lite. Cada arquivo é imutável depois de aceito: se a decisão mudar,
cria-se um novo arquivo que supersede o anterior — não se edita o registro histórico
para apagar o que foi decidido antes.

Formato de cada arquivo: Status, Data, Contexto (1 parágrafo), Decisão, Consequências,
Referências (para o documento operacional detalhado que sustenta a decisão — o ADR não
duplica esse detalhe, só registra o "porquê" e a data).

Isto existe porque a memória do harness (ver `AGENTS.md`/`CLAUDE.md`) é vinculada a
usuário/ambiente, não ao repositório: uma decisão registrada só em memória numa sessão
não tem garantia de sobreviver a uma sessão futura rodando em outra modalidade de
ambiente (ex.: host WSL local vs. sessão cloud efêmera). Decisão relevante sempre
também vira arquivo aqui.

## Decisões registradas

- `2026-07-01-manter-monorepo-sis-dtic.md`
- `2026-07-01-estrategia-acesso-externo.md`
- `2026-07-01-padronizacao-sis-dtic.md`
