# SIS Mobile - Flutter

Aplicativo Flutter para operacao de chamados GLPI no contexto SIS.

## Escopo

- Contexto unico: SIS
- Login via GLPI (`initSession` com login/senha)
- Consulta de tickets, mensagens, solucoes e anexos
- Abertura e sincronizacao de tickets offline
- Linha DTIC isolada em `lib/main_dtic.dart`, com FormCreator e Worker proprio;
  veja `docs/DTIC_MOBILE_V1.md`
- SIS e DTIC sao linhas de produto no Flutter atual. A separacao fisica em
  pastas proprias deve seguir `docs/MOBILE_WORKSPACE_ORGANIZATION.md`.

## Requisitos

- Flutter SDK compativel com `environment.sdk: ^3.9.2` do `pubspec.yaml`
- Chrome (para execucao web)
- Android Studio + Android SDK no Windows host (para Android, emulator, dispositivo fisico e `adb`)

Este repo usa fluxo hibrido: a fonte canonica fica na WSL em `/home/jonathan/projects/work/mobile/sis-mobile-flutter`; a camada Android fica no Windows quando o SDK/emulador estao instalados no host.

Nesta maquina, a camada Android validada usa Flutter Windows em `C:\Users\jonathan-moletta\tools\flutter`, Android SDK em `C:\Users\jonathan-moletta\Android\Sdk` e JDK em `C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot`.

## Configuracao

1. Crie `.env` na raiz do projeto (ou copie de `.env.example`).
2. Preencha:

```env
SIS_GLPI_BASE_URL=http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php
GLPI_DEBUG_LOGS=false
```

`GLPI_BASE_URL` continua aceito por compatibilidade, mas `SIS_GLPI_BASE_URL` e
`DTIC_GLPI_BASE_URL` reduzem o risco de rodar um app apontando para o GLPI do
outro contexto.

## Execucao

```bash
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083
```

Execucao web da linha DTIC:

```bash
/opt/flutter/bin/flutter run -t lib/main_dtic.dart -d web-server --web-hostname 127.0.0.1 --web-port 8084
```

Antes de rodar a linha DTIC, o `.env` local precisa conter
`DTIC_GLPI_BASE_URL` apontando para o Worker DTIC ou para o endpoint DTIC
validado em rede interna.

Execucao SIS em Android no Windows host:

```powershell
cd \\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter
flutter doctor -v
adb devices
flutter devices
flutter run --flavor sis -t lib/main.dart -d android
```

Execucao DTIC em Android no Windows host:

```powershell
cd \\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter
flutter run --flavor dtic -t lib/main_dtic.dart -d android
```

Se Gradle/Java falhar ao operar diretamente sobre `\\wsl.localhost\...`, gere um espelho operacional Windows temporario para build em `C:\Users\jonathan-moletta\build-mirrors\sis-mobile-flutter`. Esse espelho nao e raiz canonica e nao deve receber edicoes de fonte.

## Qualidade

```bash
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
```

Para features e correcoes nao triviais de dominio, use tambem:

- `docs/quality/DOR.md` antes de implementar
- `docs/quality/DOD.md` antes de declarar pronto
- `docs/domain/ticket/` quando a mudanca tocar estados, transicoes, invariantes ou fonte de verdade de tickets

Laboratorio visual Flutter na WSL:

```bash
cd widgetbook
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
/opt/flutter/bin/flutter build web
```

Laboratorio visual Flutter no Windows host, quando usar o script PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1
```

Atualizacao intencional dos goldens do laboratorio:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1 -UpdateGoldens
```

## Distribuicao Android (piloto e producao)

- Playbook completo: `docs/android-distribution-playbook.md`
- Build release padronizado no Windows host:

```powershell
.\tool\android\build_release.ps1
```

Build release DTIC:

```powershell
.\tool\android\build_release.ps1 -App dtic -EnvFile .env.dtic.local
```

- Build release para piloto com endpoint publico:

```powershell
.\tool\android\build_release.ps1 -GlpiBaseUrl https://host-publico.exemplo/sis/apirest.php
```

- Build app bundle (Play):

```powershell
.\tool\android\build_release.ps1 -Aab
```

- Build app bundle DTIC (Play):

```powershell
.\tool\android\build_release.ps1 -App dtic -EnvFile .env.dtic.local -Aab
```

## Notas

- Este repositorio nao depende de `api_config.dart`; a configuracao oficial e via `.env`.
- A autenticacao usa apenas `login/senha` (`initSession`) e `Session-Token`.
- Se precisar trocar de ambiente SIS, prefira `SIS_GLPI_BASE_URL`.
- Para DTIC, prefira `DTIC_GLPI_BASE_URL` apontando para o Worker DTIC; nunca
  coloque `App-Token` no `.env`.
- Logs detalhados ficam ativos por padrao apenas em debug. Para forcar logs em outros ambientes, use `GLPI_DEBUG_LOGS=true`.
- O contrato canonico de produto, UI e componentes Flutter esta em `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md`.

Seguranca operacional:

- funcionalidades reais de producao permanecem preservadas para usuarios autorizados
- agentes nao devem executar validacao mutavel contra tickets reais de usuarios
- o Worker SIS pass-through deve ser tratado como superficie sensivel: nao usar para `DELETE /Ticket`, purge ou cleanup automatizado sem aprovacao humana explicita e ambiente isolado
- validacao assistida por agente contra GLPI real deve ser read-only por padrao
- A direcao de frontend profissional, design lab, workbench e guarda visual esta em `docs/FRONTEND_PROFISSIONAL_FLUTTER.md`.
- O plano operacional de laboratorio e guarda visual Flutter esta em `docs/PLANO_LABORATORIO_E_GUARDA_VISUAL_FLUTTER.md`.
- O blueprint de skills planejadas para o fluxo frontend Flutter esta em `docs/FRONTEND_SKILLS_FLUTTER.md`.
- O backend principal continua interno. Para distribuicao em celular fora da intranet sem VPN por aparelho, a primeira fase suportada e Cloudflare Worker em `workers.dev` + Workers VPC + Tunnel; veja `docs/ACESSO_EXTERNO_CONTROLADO.md` e `docs/ACESSO_EXTERNO_WORKERS_VPC.md`. Bridge USB/LAN e proxy de notebook nao fazem parte da estrategia.
