# HERMES

Contexto de projeto para Hermes neste repositorio.

## Papel do Hermes aqui

- Hermes pode usar este repo como workspace de execucao e tambem como alvo de contexto documental.
- O uso mais valioso de Hermes aqui e partir do contexto local do repo e, quando existir, combinar com fontes cross-project realmente acessiveis.
- Este arquivo e somente project-scope.

## Constituicao local

- Raiz canonica de codigo-fonte: `/home/jonathan/projects/work/mobile/sis-mobile-flutter` em WSL/ext4.
- Caminhos `C:\Users\...` e `/mnt/c/...` sao camada host, runtime, ferramenta ou historico operacional; nao sao raiz de fonte deste workspace.
- WSL e a camada de desenvolvimento de codigo, `analyze`, `test`, web local e Widgetbook por comandos Flutter Linux.
- Windows host e a camada preferencial para Android SDK, emulator, dispositivo fisico, `adb`, `flutter run -d android` e build Android.
- Flutter SDK, Android SDK e PowerShell podem ser dependencias de execucao/build da camada correspondente, mas nao pertencem a modelagem de fonte do repo.
- Ausencia de PowerShell ou Android SDK dentro da WSL nao deve ser tratada como projeto quebrado.
- Runtime local do app usa `.env` na raiz; `.env.example` e o exemplo versionado.
- GLPI real direto depende de rede interna ou VPN; acesso externo mobile para usuarios finais deve usar endpoint externo controlado, preferencialmente Worker `workers.dev` + Workers VPC + Tunnel na primeira fase sem dominio proprio.

## O que consultar antes de mudar algo

1. `AGENTS.md`
2. `BOOTSTRAP.md`
3. `README.md`
4. `docs/README.md`
5. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
6. `docs/CONTROL_PLANE_LOCAL.md`

## Relacao com contexto externo

- Nao ha Cerebro Central canonico disponivel neste workspace WSL.
- Nao assuma existencia de repos em `C:\Users\...` ou `/mnt/c/...` para governar este projeto.
- Se uma fonte cross-project local existir no filesystem atual, use apenas para:
  - encontrar padroes de governanca
  - localizar docs analogos em outros repos
  - corroborar decisoes com historico institucional
- Nao use contexto externo para substituir os contratos locais do projeto atual.

## Artefatos relevantes para Hermes

- `HERMES.md`
- `AGENTS.md`
- `BOOTSTRAP.md`
- `docs/*.md`
- `/home/jonathan/design/docs/96-docker-storage-stabilization-2026-05-17.md`

## Incidente operacional Docker - 2026-05-17

- Docker Desktop parou por exaustao de espaco no SSD `C:`.
- `C:` e SSD NVMe; `D:` e HDD SATA. Docker/WSL/builds devem permanecer preferencialmente no SSD; o HDD deve receber artefatos frios, como modelos locais.
- `/mnt/c/models` foi migrado para `/mnt/d/models` e preservado por junction `C:\models -> D:\models`.
- Docker voltou a operar apos limpeza de sockets runtime obsoletos e inicializacao do Docker Desktop com ambiente Windows saneado.
- O runbook completo, evidencias, comandos e pendencias estao em `/home/jonathan/design/docs/96-docker-storage-stabilization-2026-05-17.md`.
- Estado atual conhecido: Docker operacional, `docker-desktop` rodando, 14 containers ativos; `C:` ainda precisa de margem maior, alvo recomendado `60-100 GB` livres.

Arquivos de user-scope do Hermes NAO pertencem a este repo:

- `~/.hermes/config.yaml`
- `~/.hermes/SOUL.md`
- `~/.hermes/memories/*`
- `~/.hermes/sessions/*`

## Validacao recomendada

- Mudanca documental: revisar a cadeia `AGENTS.md` -> `BOOTSTRAP.md` -> `docs/*.md`.
- Mudanca de codigo: `/opt/flutter/bin/flutter analyze` e `/opt/flutter/bin/flutter test` na WSL.
- Mudanca operacional Android: revalidar os scripts de `tool/android/` no Windows host e a estrategia descrita em `docs/ACESSO_EXTERNO_CONTROLADO.md`.

## Regras locais

- Nao materialize memorias, sessoes ou configs globais do Hermes dentro do repo.
- Se o objetivo for preparar este projeto para command center ou control plane, use `docs/CONTROL_PLANE_LOCAL.md` como mapa local de superficies.
- Nao trate bridge USB/LAN, `adb reverse` ou proxy local de notebook como superficie operacional suportada.
- Regras de seguranca GLPI, nao-versionamento de secrets e proibicoes de mutacao: ver secao "Regras de seguranca GLPI para agentes (fonte unica)" em `AGENTS.md` — nao duplicadas aqui.
- qualquer orquestracao de validacao mutavel precisa confirmar ambiente nao-producao e alvo sintetico antes da execucao
