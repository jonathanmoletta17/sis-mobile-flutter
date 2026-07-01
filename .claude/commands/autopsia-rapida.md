---
description: Executa o protocolo de autopsia rápida (docs/AUTOPSIA_RAPIDA.md) para um bug localizado
---

Leia `docs/AUTOPSIA_RAPIDA.md` por inteiro e siga o protocolo exatamente, sem pular
etapas, para o bug descrito em $ARGUMENTS (ou, se vazio, o bug em discussão nesta
conversa).

Use este comando apenas para bugs localizados (não para divergência entre UI, API,
estado remoto, permissões ou transições — para esses casos use `/autopsia-completa`).

A saída deve incluir, conforme o protocolo: timebox declarado, fato observado
separado de hipótese, nível de confiança explícito (alta/média/baixa) para a causa
raiz, correção mínima proposta, e o aprendizado de processo obrigatório ao final.
