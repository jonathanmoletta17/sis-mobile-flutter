# SIS Mobile - Flutter

Aplicativo Flutter para operacao de chamados GLPI no contexto SIS.

## Escopo

- Contexto unico: SIS
- Login via GLPI (`initSession` com login/senha)
- Consulta de tickets, mensagens, solucoes e anexos
- Abertura e sincronizacao de tickets offline

## Requisitos

- Flutter SDK 3.41.x (ou compativel com Dart 3.11.x)
- Chrome (para execucao web)
- Android Studio + Android SDK (para Android)

## Configuracao

1. Crie `.env` na raiz do projeto (ou copie de `.env.example`).
2. Preencha:

```env
GLPI_BASE_URL=http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php
GLPI_DEBUG_LOGS=false
```

## Execucao

```bash
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083
```

Execucao em Android:

```bash
flutter run -d android
```

## Qualidade

```bash
flutter analyze
flutter test
```

Laboratorio visual Flutter:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1
```

Atualizacao intencional dos goldens do laboratorio:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1 -UpdateGoldens
```

## Distribuicao Android (piloto e producao)

- Playbook completo: `docs/android-distribution-playbook.md`
- Build release padronizado:

```powershell
.\tool\android\build_release.ps1
```

- Build release para piloto com endpoint publico:

```powershell
.\tool\android\build_release.ps1 -GlpiBaseUrl https://host-publico.exemplo/sis/apirest.php
```

- Build app bundle (Play):

```powershell
.\tool\android\build_release.ps1 -Aab
```

## Notas

- Este repositorio nao depende de `api_config.dart`; a configuracao oficial e via `.env`.
- A autenticacao usa apenas `login/senha` (`initSession`) e `Session-Token`.
- Se precisar trocar de ambiente SIS, altere apenas `GLPI_BASE_URL`.
- Logs detalhados ficam ativos por padrao apenas em debug. Para forcar logs em outros ambientes, use `GLPI_DEBUG_LOGS=true`.
- O contrato canonico de produto, UI e componentes Flutter esta em `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md`.
- A direcao de frontend profissional, design lab, workbench e guarda visual esta em `docs/FRONTEND_PROFISSIONAL_FLUTTER.md`.
- O plano operacional de laboratorio e guarda visual Flutter esta em `docs/PLANO_LABORATORIO_E_GUARDA_VISUAL_FLUTTER.md`.
- O blueprint de skills planejadas para o fluxo frontend Flutter esta em `docs/FRONTEND_SKILLS_FLUTTER.md`.
- O backend principal continua interno. Para uso em celular fora da intranet, priorize VPN institucional mobile quando existir. Sem isso, o caminho suportado e um endpoint externo estavel e controlado. Bridge USB/LAN e proxy de notebook nao fazem parte da estrategia; veja `docs/ACESSO_EXTERNO_CONTROLADO.md`.
