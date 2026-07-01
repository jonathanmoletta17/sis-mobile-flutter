# BOOTSTRAP

Mapa operacional inicial deste repositorio para agentes e CLIs.

## O que este repo e

- App Flutter da SIS para operacao de chamados GLPI.
- Raiz canonica de codigo-fonte neste host: `/home/jonathan/projects/work/mobile/sis-mobile-flutter`.
- Caminhos `C:\Users\...` ou `/mnt/c/...` aparecem apenas como camada host, ferramenta ou historico; nao sao raiz de fonte deste workspace.
- O codigo principal vive em `lib/`.
- SIS e DTIC existem hoje como linhas de produto no mesmo Flutter; a DTIC usa
  `lib/main_dtic.dart`, `lib/dtic/`, flavor Android e Worker proprios.
- Os testes vivem em `test/`.
- O laboratorio visual Flutter vive em `widgetbook/`.
- Os scripts operacionais vivem em `tool/android/`.
- Os scripts de validacao frontend vivem em `tool/frontend/`.
- A documentacao operacional vive em `docs/`.

## Ordem minima de leitura

1. `AGENTS.md`
2. `BOOTSTRAP.md`
3. `README.md`
4. `docs/README.md`
5. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`

Antes de planejar mudanca nao trivial, use primeiro os docs deste repo.
Nao assuma Cerebro Central ou repo cross-project externo em Windows: esse tipo de fonte nao e parte deste workspace WSL e nao deve ser tratado como dependencia disponivel.

Leia tambem quando aplicavel:

- `docs/entity-governance-and-android-testing.md` para entidade e testes Android
- `docs/validation-and-testing-guide.md` para historico de validacao
- `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md` para contrato de produto, UI e componentes Flutter
- `docs/FRONTEND_PROFISSIONAL_FLUTTER.md` para a doutrina de frontend profissional, design lab, workbench e guarda visual
- `docs/PLANO_LABORATORIO_E_GUARDA_VISUAL_FLUTTER.md` para a stack escolhida, o roadmap e os artefatos do laboratorio Flutter
- `docs/FRONTEND_SURFACE_DISCOVERY_FLUTTER.md` para o inventario real das superficies Flutter e a ordem recomendada de trabalho visual
- `docs/FRONTEND_SKILLS_FLUTTER.md` para os contratos planejados de skills de frontend Flutter sem instalar configuracao global
- `docs/WIDGETBOOK_WORKBENCH.md` para a operacao do workbench separado e os comandos canonicos dessa trilha
- `docs/ACESSO_EXTERNO_CONTROLADO.md` para estrategia de acesso externo real
- `docs/android-distribution-playbook.md` para release e distribuicao
- `docs/web-mobile-fallback-plan.md` para iniciativa futura de fallback web
- `docs/CONTROL_PLANE_LOCAL.md` para mapeamento deste repo no control plane
- `docs/MOBILE_WORKSPACE_ORGANIZATION.md` para governanca da organizacao SIS e
  DTIC em `/home/jonathan/projects/work/mobile`

## Runtime canonico

- Configuracao via `.env` na raiz.
- Endpoint principal esperado: `GLPI_BASE_URL=http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php`
- Flutter SDK e Android SDK sao dependencias de execucao/build; nao movem a fonte canonica para Windows.
- Arquitetura operacional hibrida:
  - WSL: edicao de codigo, `pub get`, `analyze`, `test`, web local e Widgetbook quando o Flutter Linux estiver disponivel
  - Windows: Android SDK, emulator, dispositivo fisico, `adb`, `flutter run -d android` e build release Android
- Fluxos suportados hoje:
  - web local na WSL: `/opt/flutter/bin/flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083`
  - Android local no Windows host: `flutter run -d android`
  - release Android no Windows host: `.\tool\android\build_release.ps1`

Para uso externo em celular fora da intranet, nao trate VPN por aparelho como primeira fase quando o requisito for distribuicao ampla com "somente o APK".
O caminho preferencial sem dominio proprio e Cloudflare Worker em `workers.dev` + Workers VPC + Tunnel, descrito em `docs/ACESSO_EXTERNO_WORKERS_VPC.md`.
O repo nao suporta bridge USB/LAN, `adb reverse` nem proxy de notebook como estrategia operacional.

## Resolucao do Flutter nesta maquina

- Na WSL atual, `flutter` pode nao estar no `PATH`; use `/opt/flutter/bin/flutter` quando necessario.
- Flutter Windows esta configurado no host em `C:\Users\jonathan-moletta\tools\flutter`.
- Android SDK Windows esta configurado em `C:\Users\jonathan-moletta\Android\Sdk`.
- JDK Windows esta configurado em `C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot`.
- Nao use o caminho antigo `C:\Users\jonathan-moletta\code\tools\flutter\bin\flutter.bat`; ele nao e requisito deste workspace.
- Para Android, mantenha o Flutter Windows no `PATH` do Windows ou em `FLUTTER_ROOT`; o script `tool/android/build_release.ps1` resolve os fallbacks que existirem no host.
- `android/local.properties` e artefato local ignorado e pode ser regravado pelo Flutter de cada camada. O lado que executar Android build/run precisa apontar para seus caminhos reais de Flutter e Android SDK.

## Fluxo hibrido WSL + Windows

Modelo A, preferido para estabilidade:

- manter a fonte canonica na WSL em `/home/jonathan/projects/work/mobile/sis-mobile-flutter`
- rodar na WSL:
  - `/opt/flutter/bin/flutter pub get`
  - `/opt/flutter/bin/flutter analyze`
  - `/opt/flutter/bin/flutter test`
  - `cd widgetbook && /opt/flutter/bin/flutter pub get && /opt/flutter/bin/flutter analyze && /opt/flutter/bin/flutter test && /opt/flutter/bin/flutter build web`
- rodar no Windows host, a partir do caminho UNC `\\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter`:
  - `where flutter`
  - `where adb`
  - `adb devices`
  - `flutter doctor -v`
  - `flutter devices`
  - `flutter run -d android`
  - `.\tool\android\build_release.ps1`
- se Gradle/Java falhar operando direto no caminho UNC, gere um espelho operacional Windows temporario em `C:\Users\jonathan-moletta\build-mirrors\sis-mobile-flutter` a partir da fonte WSL, excluindo `.git`, caches, outputs, `android/key.properties`, keystores e secrets. Esse espelho nao e raiz canonica e nao deve receber edicoes de fonte.

Modelo B, avancado e nao padrao:

- expor `adb` do Windows para a WSL so ajuda a listar/conectar dispositivos
- `adb` sozinho nao substitui Android SDK/build-tools para compilar APK/AAB com Flutter Linux
- se a WSL nao tiver Android SDK Linux compativel, build/run Android deve continuar no Windows host

## Comandos-base

- WSL pub get: `/opt/flutter/bin/flutter pub get`
- WSL analyze: `/opt/flutter/bin/flutter analyze`
- WSL test: `/opt/flutter/bin/flutter test`
- WSL run web: `/opt/flutter/bin/flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083`
- WSL gate visual Widgetbook: `cd widgetbook && /opt/flutter/bin/flutter pub get && /opt/flutter/bin/flutter analyze && /opt/flutter/bin/flutter test && /opt/flutter/bin/flutter build web`
- Windows run Android: `flutter run -d android`
- Windows build release: `.\tool\android\build_release.ps1`
- Windows gate visual Widgetbook, quando preferir usar o script PowerShell: `powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1`

## Politica de validacao

- Mudanca documental: nao exige build, mas exige coerencia com a operacao real.
- Mudanca visual relevante: passar por `widgetbook/` e `tool/frontend/validate_widgetbook.ps1` antes da prova de runtime.
- Mudanca intencional de baseline visual: usar `tool/frontend/validate_widgetbook.ps1 -UpdateGoldens` e revisar o diff gerado.
- Mudanca em `lib/` ou `test/`: rodar `analyze` e `test`.
- Mudanca em `tool/android/`: rodar pelo menos o script de build correspondente no Windows host.
- Mudanca em `tool/frontend/` ou `widgetbook/`: rodar o gate visual Widgetbook.
- Mudanca no contrato de rede ou acesso externo: revisar `docs/ACESSO_EXTERNO_CONTROLADO.md` e revalidar o fluxo descrito.

## Regras locais

- O GLPI da SIS e interno. Teste direto contra o endpoint interno depende de rede interna ou VPN.
- Acesso externo em celular para usuarios finais deve usar endpoint externo controlado; a primeira fase sem dominio proprio e Worker `workers.dev` + Workers VPC + Tunnel.
- APKs em `Downloads` e logs XML/PNG/TXT sao evidencia operacional, nao fonte normativa.
- O fallback web mobile-first existe como plano exploratorio; nao e o runtime canonico atual.
- O Widgetbook e a baseline Alchemist sao a guarda local para UI; Android continua sendo prova final, nao laboratorio de primeira tentativa.
- Contexto cross-project externo so deve ser usado se existir no filesystem atual e for explicitamente relevante.
- Se esse contexto externo nao existir, registre a indisponibilidade e siga pelos contratos locais deste repo.
- Regras de seguranca GLPI, nao-versionamento de secrets e proibicoes de mutacao: ver secao "Regras de seguranca GLPI para agentes (fonte unica)" em `AGENTS.md` — nao duplicadas aqui.
