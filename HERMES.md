# HERMES

Contexto de projeto para Hermes neste repositorio.

## Papel do Hermes aqui

- Hermes pode usar este repo como workspace de execucao e tambem como alvo de contexto documental.
- O uso mais valioso de Hermes aqui e combinar o contexto local do repo com o Cerebro Central para descoberta orientada por evidencia.
- Este arquivo e somente project-scope.

## O que consultar antes de mudar algo

1. `AGENTS.md`
2. `BOOTSTRAP.md`
3. `README.md`
4. `docs/README.md`
5. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
6. `docs/CONTROL_PLANE_LOCAL.md`

## Relacao com o Cerebro Central

- O Cerebro Central esta em `C:\Users\jonathan-moletta\code\inteligencia-md-local\cerebro_central`.
- Use o Cerebro para:
  - encontrar padroes de governanca
  - localizar docs analogos em outros repos
  - corroborar decisoes com historico institucional
- Neste repo, esse uso deve acontecer cedo, antes de fechar plano ou idealizacao de mudanca relevante.
- Nao use o Cerebro para substituir os contratos locais do projeto atual.

## Artefatos relevantes para Hermes

- `HERMES.md`
- `AGENTS.md`
- `BOOTSTRAP.md`
- `docs/*.md`

Arquivos de user-scope do Hermes NAO pertencem a este repo:

- `~/.hermes/config.yaml`
- `~/.hermes/SOUL.md`
- `~/.hermes/memories/*`
- `~/.hermes/sessions/*`

## Validacao recomendada

- Mudanca documental: revisar a cadeia `AGENTS.md` -> `BOOTSTRAP.md` -> `docs/*.md`.
- Mudanca de codigo: `flutter analyze` e `flutter test`.
- Mudanca operacional: revalidar os scripts de `tool/android/` e a estrategia descrita em `docs/ACESSO_EXTERNO_CONTROLADO.md`.

## Regras locais

- Nao materialize memorias, sessoes ou configs globais do Hermes dentro do repo.
- Se o objetivo for preparar este projeto para command center ou control plane, use `docs/CONTROL_PLANE_LOCAL.md` como mapa local de superficies.
- Nao trate bridge USB/LAN, `adb reverse` ou proxy local de notebook como superficie operacional suportada.
