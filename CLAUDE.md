# CLAUDE

**Constituicao objetiva:** este repositorio e a interface Flutter multiplataforma do ecossistema SIS para chamados GLPI. A fonte canonica nesta maquina fica em `/home/jonathan/projects/work/mobile/sis-mobile-flutter`; referencias `C:\Users\...` nos docs existem como camada host ou historico operacional, nao como raiz de codigo-fonte para este workspace.

## Papel do Claude aqui

- Operar este repo como agente de codigo, documentacao e consolidacao local.
- Respeitar `AGENTS.md`, `BOOTSTRAP.md`, `HERMES.md` e `.claude.json` como contexto de governanca do projeto.
- Tratar configuracao persistente do Claude como user-scope, salvo necessidade comprovada dentro deste repo.

## O que consultar antes de mudar algo

1. `AGENTS.md`
2. `BOOTSTRAP.md`
3. `README.md`
4. `docs/README.md`
5. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
6. `docs/CONTROL_PLANE_LOCAL.md`

## Constituicao operacional do projeto

- Produto: app Flutter da SIS para operacao de chamados GLPI.
- Runtime local: configuracao via `.env` na raiz.
- Superficies principais: `lib/`, `test/`, `widgetbook/`, `tool/android/`, `tool/frontend/`.
- Integracoes: GLPI real interno; acesso direto depende de rede interna ou VPN, mas distribuicao externa para usuarios finais deve usar endpoint controlado.
- Fronteira local: codigo-fonte na raiz WSL; WSL roda desenvolvimento, `analyze`, `test`, web local e Widgetbook por comandos Flutter Linux.
- Camada Android: Windows host concentra Android SDK, emulator, dispositivo fisico, `adb`, `flutter run -d android` e build release. PowerShell nao precisa existir dentro da WSL.
- Acesso externo mobile: para "somente o APK", preferir Worker `workers.dev` + Workers VPC + Tunnel; VPN por aparelho fica para desenvolvimento, suporte ou grupos controlados. Nao usar bridge USB/LAN, `adb reverse` ou proxy de notebook como estrategia suportada.
- Hermes/Antigravity: trate `HERMES.md` como contrato de orquestracao e contexto; nao replique runtime Hermes nem control plane dentro deste repo.

## Artefatos relevantes para agentes

- `AGENTS.md`
- `BOOTSTRAP.md`
- `CLAUDE.md`
- `HERMES.md`
- `docs/*.md`

Artefatos que nao devem ser criados sem caso de uso concreto:

- `.claude/settings.json`
- `.claude/settings.local.json`
- `.mcp.json`

## Validacao recomendada

- Mudanca documental: revisar consistencia entre os docs principais.
- Mudanca de codigo: `/opt/flutter/bin/flutter analyze` e `/opt/flutter/bin/flutter test` na WSL, ou `flutter analyze`/`flutter test` quando o PATH estiver configurado.
- Mudanca visual relevante: revalidar `widgetbook/` por comandos Flutter na WSL ou pelo script PowerShell no Windows host.
- Mudanca de build ou distribuicao Android: usar os scripts oficiais em `tool/android/` no Windows host com Flutter/Android SDK/adb configurados.

## Regras locais

- Nao trate logs, dumps XML, screenshots ou caches de build como fonte normativa.
- Nao versionar `.env`, variantes locais de `.env`, `android/key.properties`, keystores, secrets, caches, build outputs ou runtime artifacts.
- Nao promova configuracao global do Claude para dentro do repo sem necessidade real.
- O projeto depende de rede interna, VPN ou endpoint externo controlado para validacao plena contra o GLPI real.
- Use este arquivo como contexto de projeto; trate qualquer configuracao persistente do Claude como user-scope.
- preservar funcionalidades reais de producao do app; nao remover capacidades funcionais por causa de riscos de validacao
- Claude/agentes nao devem executar validacoes mutaveis contra tickets reais de usuarios, nem usar Worker SIS pass-through para metodo destrutivo, `DELETE /Ticket`, purge ou cleanup automatizado sem aprovacao humana explicita e ambiente isolado
- usar validacoes read-only por padrao quando houver GLPI real no caminho
