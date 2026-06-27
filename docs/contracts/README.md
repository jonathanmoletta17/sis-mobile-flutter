# Contratos SIS Mobile

## Status

**ACCEPTED (design-only) em 2026-06-27.**

Estes contratos encerram a Fase 2 documental, mas ainda nao estao implementados
no Flutter ou no Worker e nao descrevem o runtime atual como se ja existisse.
O status nao autoriza mutacoes no GLPI real nem inicio de producao sem os gates
da Fase 3.

## Arquivos

- `sis-mobile-api-v1.yaml`: contrato OpenAPI 3.1 entre Flutter, Worker SIS e
  GLPI.
- `outbox-v1.sql`: referencia de schema SQLite para a futura outbox Drift.

Os planos de validacao relacionados estao em:

- `../testing/worker-do-test-plan.md`
- `../testing/flutter-outbox-test-plan.md`
- `../testing/phase3-homologation.md`

## Regras

1. `X-Operation-Id` e um UUID v4 criado e persistido pelo App antes da primeira
   tentativa. Ele e a identidade idempotente e a chave da outbox.
2. Repetir uma operacao exige o mesmo `X-Operation-Id` e o mesmo digest de
   payload. Reutilizacao com payload divergente e conflito terminal.
3. Depois do dispatch ao GLPI, timeout, conexao perdida ou resposta ambigua
   levam a `UNKNOWN`. Esse estado nunca dispara uma nova mutacao.
4. Reconciliacao de `UNKNOWN` e read-only, autenticada e limitada a mesma
   operacao.
5. Sem marcador unico comprovado no GLPI, busca por titulo, conteudo, usuario
   ou data nao confirma criacao de ticket/followup.
6. O App nao armazena `GLPI_APP_TOKEN`; o Worker continua sendo o dono desse
   secret.
7. Capabilities orientam a UI, mas toda mutacao revalida ticket, perfil,
   entidade, vinculos e precondicao remota.
8. O Worker deve provar a cadeia
   `Ticket -> ITILFollowup/ITILSolution -> Document_Item -> Document` antes de
   servir ou vincular um anexo.
9. Anexos offline no PWA permanecem bloqueados ate validacao real de storage.
10. As regras de dominio em `../domain/ticket/` e o GLPI remoto continuam sendo
    fontes de verdade. O OpenAPI governa a superficie HTTP, nao substitui o
    dominio.

## Validacao

Validar sem chamar o GLPI:

```bash
npx --yes @redocly/cli lint docs/contracts/sis-mobile-api-v1.yaml
sqlite3 :memory: < docs/contracts/outbox-v1.sql
```

O SQL e referencia contratual. A implementacao Drift deve ser validada em
scratch project antes de integrar dependencias ao App.

Validacoes executadas para aceitar o baseline:

- Redocly CLI: OpenAPI valido, sem erros ou warnings;
- 10 paths e 139 referencias, sem `$ref` ausente;
- SQLite em memoria: DDL aceito com foreign keys habilitadas;
- scratch Drift `2.34.0`/`drift_dev 2.34.1+1`: codegen concluido;
- `dart analyze` no scratch Drift: sem problemas;
- markdownlint nos quatro arquivos Markdown: zero erros.
