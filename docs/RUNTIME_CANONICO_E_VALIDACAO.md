# Runtime Canonico e Validacao

## Escopo

Este documento define o que hoje e considerado suportado e mantido neste repositorio para operacao local, validacao e distribuicao Android.

A organizacao futura de SIS Mobile e DTIC Mobile em pastas proprias dentro de
`/home/jonathan/projects/work/mobile` deve seguir
`MOBILE_WORKSPACE_ORGANIZATION.md`. O runtime atual continua sendo este repo
Flutter com linhas/flavors separados.

## Raiz e fronteira local

- Raiz canonica de codigo-fonte: `/home/jonathan/projects/work/mobile/sis-mobile-flutter`.
- A fonte vive em WSL/ext4; caminhos Windows (`C:\Users\...`) e `/mnt/c/...` sao referencias de host, ferramenta ou historico operacional.
- Flutter SDK e Android SDK sao dependencias de execucao/build, nao raizes de codigo-fonte.
- O ambiente operacional e hibrido: WSL para desenvolvimento e validacoes de codigo; Windows para Android SDK, emulator, dispositivo fisico, `adb`, run Android e build Android quando o SDK esta no host.
- Ausencia de PowerShell, Android SDK ou `ANDROID_HOME` dentro da WSL nao e falha critica por si so; e um sinal de que a etapa Android deve ser executada pela camada Windows ou por um modelo hibrido explicitamente configurado.

## Runtime suportado

O projeto suporta hoje um unico app Flutter com dois modos principais de execucao local:

- web local para desenvolvimento:
  - `/opt/flutter/bin/flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083`
- web local DTIC:
  - `/opt/flutter/bin/flutter run -t lib/main_dtic.dart -d web-server --web-hostname 127.0.0.1 --web-port 8084`
- Android local no Windows host:
  - `flutter run --flavor sis -t lib/main.dart -d android`
  - `flutter run --flavor dtic -t lib/main_dtic.dart -d android`

Configuracao de ambiente:

- arquivo: `.env`
- exemplo versionado: `.env.example`
- chaves esperadas:
  - `SIS_GLPI_BASE_URL` para a linha SIS
  - `DTIC_GLPI_BASE_URL` para a linha DTIC
  - `GLPI_BASE_URL` ainda aceito como fallback legado
  - `GLPI_DEBUG_LOGS`
  - `DTIC_ENABLE_TICKET_ACTIONS` apenas para a linha DTIC, default seguro `false`
  - `DTIC_ENABLE_FORM_SUBMISSION` apenas para a linha DTIC, default seguro `false`
- nao versionar `.env` real, variantes locais de ambiente, keystores, `android/key.properties`, secrets, caches, build outputs ou runtime artifacts

Endpoint operacional SIS principal hoje:

- `http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php`
- em `.env`, prefira `SIS_GLPI_BASE_URL`

Endpoint operacional DTIC:

- o app DTIC deve apontar para o Worker DTIC
- o Worker DTIC encaminha para `http://cau.ppiratini.intra.rs.gov.br/glpi/apirest.php`
- em `.env`, prefira `DTIC_GLPI_BASE_URL`
- o `App-Token` DTIC fica apenas no secret `GLPI_APP_TOKEN` do Worker
- acoes de ticket DTIC fora do dominio exigem `DTIC_ENABLE_TICKET_ACTIONS=true`
  no build e `ALLOW_TICKET_ACTIONS=true` no Worker
- submissao FormCreator DTIC continua separada e exige
  `DTIC_ENABLE_FORM_SUBMISSION=true` no build e
  `ALLOW_FORMCREATOR_SUBMISSION=true` no Worker

Contrato canonico de produto, UI e componentes:

- `SIS_MOBILE_PRODUTO_UI_CANONICO.md`

## Resolucao real do Flutter neste host

Evidencia atual:

- na WSL, `flutter` nao estava disponivel diretamente no `PATH` deste terminal
- `Flutter 3.41.7` respondeu corretamente em:
  - `/opt/flutter/bin/flutter`
- no Windows host, `Flutter 3.41.7` esta configurado em:
  - `C:\Users\jonathan-moletta\tools\flutter`
- Android SDK Windows esta configurado em:
  - `C:\Users\jonathan-moletta\Android\Sdk`
- JDK Windows esta configurado em:
  - `C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot`
- o caminho antigo `C:\Users\jonathan-moletta\code\tools\flutter\bin\flutter.bat` nao deve ser usado como fallback assumido

Implicacao operacional:

- comandos WSL podem usar `/opt/flutter/bin/flutter` explicitamente quando o `PATH` nao estiver preparado
- comandos Android devem ser executados no Windows host quando Android SDK/emulator/adb estiverem instalados no Windows
- o script `tool/android/build_release.ps1` ja implementa fallback automatico para localizacao do Flutter Windows, mas so pode resolver caminhos que existam no host

## Modelo hibrido WSL + Windows

### Modelo A, preferido

- WSL:
  - edicao de codigo
  - `/opt/flutter/bin/flutter pub get`
  - `/opt/flutter/bin/flutter analyze`
  - `/opt/flutter/bin/flutter test`
  - Widgetbook por comandos Flutter equivalentes dentro de `widgetbook/`
- Windows:
  - Android Studio, Android SDK, emulator e `adb`
  - `flutter doctor -v`
  - `adb devices`
  - `flutter devices`
  - `flutter run -d android`
  - `.\tool\android\build_release.ps1`

Use o caminho Windows do workspace WSL quando operar pelo host:

- `\\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter`

Para build Android, Gradle/Java pode falhar quando executado diretamente sobre UNC/interop WSL. Se isso acontecer, use um espelho operacional Windows temporario:

- `C:\Users\jonathan-moletta\build-mirrors\sis-mobile-flutter`

Esse espelho deve ser regenerado a partir da fonte WSL e excluir `.git`, caches, build outputs, `android/key.properties`, keystores e secrets. Ele nao substitui a raiz canonica e nao deve receber edicoes de codigo-fonte.

### Modelo B, avancado

- Integrar `adb.exe` do Windows na WSL pode ser util para descoberta de dispositivos ou fluxos de attach.
- Isso exige que o Windows tenha Android SDK instalado e que o caminho `platform-tools` real seja exposto.
- `adb` sozinho nao compila Android. Sem Android SDK/build-tools compativeis com Linux na WSL, `flutter build apk` e `flutter run -d android` devem permanecer no Windows host.
- Nao instale Android completo dentro da WSL como solucao principal sem necessidade comprovada.

## Scripts suportados

### Build Android

- `tool/android/build_release.ps1`
  - release APK
  - release AAB com `-Aab`
  - app/flavor com `-App sis` ou `-App dtic`
  - fallback de localizacao do Flutter
  - build com endpoint alternativo usando `-GlpiBaseUrl`
  - build a partir de arquivo de ambiente alternativo usando `-EnvFile`
  - deve ser executado no Windows host quando Android SDK e Flutter Windows forem a camada Android ativa

### Acesso externo controlado

Para uso em celular fora da intranet, o runtime suportado nao inclui:

- bridge USB/LAN
- `adb reverse`
- proxy local rodando em notebook de desenvolvimento
- APKs variantes apontando para `127.0.0.1`, IP de LAN local ou porta ad hoc

Quando for necessario uso externo real, a ordem correta e:

- para desenvolvimento, suporte ou grupos controlados, VPN institucional continua aceitavel
- para distribuicao "somente o APK", nao exigir VPN por aparelho
- usar Cloudflare Worker em `workers.dev` + Workers VPC + Tunnel como primeira fase sem dominio proprio
- quando houver dominio/hostname institucional, usar endpoint externo estavel e controlado
- exigir TLS, host sempre ligado e seguranca/observabilidade compativeis com expor acesso ao backend interno

O desenho canonico e detalhado esta em:

- `ACESSO_EXTERNO_CONTROLADO.md`
- `ACESSO_EXTERNO_WORKERS_VPC.md`

## Validacao suportada

### Estrutural

- `/opt/flutter/bin/flutter analyze` na WSL, ou `flutter analyze` quando o PATH estiver configurado
- `/opt/flutter/bin/flutter test` na WSL, ou `flutter test` quando o PATH estiver configurado

### Operacional

- login real
- catalogo
- meus chamados
- detalhe do chamado
- conversa e followup
- criacao de chamado
- anexo
- regra de entidade online e offline

Regra de seguranca:

- validacao operacional por agente contra GLPI real deve ser read-only por padrao
- nao usar tickets reais de usuarios para validar criacao, follow-up, anexo, solucao, status ou sincronizacao offline
- validacao mutavel exige aprovacao humana explicita, ambiente de homologacao/sandbox ou ticket sintetico isolado e criterio de parada
- o Worker SIS pass-through e superficie sensivel; nao usar para metodos destrutivos, `DELETE /Ticket`, purge ou cleanup automatizado sem aprovacao formal
- esta restricao nao remove funcionalidades de producao do app; ela limita apenas automacao de teste e execucao acidental por agentes

### Visual local

- Na WSL, comandos equivalentes dentro de `widgetbook/`:
  - `/opt/flutter/bin/flutter pub get`
  - `/opt/flutter/bin/flutter analyze`
  - `/opt/flutter/bin/flutter test`
  - `/opt/flutter/bin/flutter build web`
- No Windows host, `tool/frontend/validate_widgetbook.ps1`
  - roda `pub get`, `analyze`, `test` e `build web` no laboratorio `widgetbook/`
  - aceita `-UpdateGoldens` para atualizar baselines visuais de forma explicita
  - nao substitui prova de runtime Android

As consolidacoes atuais dessas evidencias estao em:

- `validation-and-testing-guide.md`
- `entity-governance-and-android-testing.md`
- `ACESSO_EXTERNO_CONTROLADO.md`

## Build e distribuicao

Fluxo suportado para distribuicao Android:

1. configurar `android/key.properties` quando houver assinatura release real
2. rodar `tool/android/build_release.ps1` no Windows host com Flutter/Android SDK/adb configurados
3. usar o playbook:
   - `android-distribution-playbook.md`

Artefatos em `Downloads` ou APKs produzidas em rodadas anteriores servem como evidencia operacional, nao como contrato normativo permanente.

## Limites conhecidos

- o backend GLPI e interno; validacao direta depende de rede interna ou VPN
- para uso externo sem VPN por aparelho, o caminho de primeira fase e Worker `workers.dev` + Workers VPC + Tunnel
- WSL sem PowerShell ou Android SDK nao e bloqueio estrutural do desenvolvimento; e apenas limite da camada Linux para a etapa Android
- Android SDK Windows ausente, `where adb` vazio ou `where flutter` vazio no Windows sao erros de configuracao do host e precisam ser corrigidos no Windows
- uso externo em celular depende de um endpoint publico controlado e estavel; notebook como relay nao e solucao suportada
- existem sinais de mojibake residual em comentarios e logs internos
- o fallback web mobile-first existe apenas como plano, nao como runtime canonico

## O que nao e runtime canonico hoje

- web mobile-first como produto paralelo
- configuracoes persistentes de CLI dentro do repo sem uso real
- APKs temporarias soltas fora do fluxo de build oficial
- bridge USB/LAN, `adb reverse` e proxy local de notebook para contornar a intranet

## Ordem de precedencia pratica

Quando houver duvida operacional, siga esta ordem:

1. codigo e scripts atuais em `lib/`, `test/` e `tool/`
2. `../README.md`
3. este documento
4. docs operacionais especializadas desta pasta
