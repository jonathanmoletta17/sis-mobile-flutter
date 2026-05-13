# Modelo Local para Control Plane

## Objetivo

Explicar como este repositorio deve ser representado pelo ecossistema de CLIs e pelo control plane local, sem portar cegamente a modelagem de outro repo.

## Identidade local

- Projeto: `sis-mobile-flutter`.
- Raiz canonica: `/home/jonathan/projects/work/mobile/sis-mobile-flutter`.
- Classe de workspace: WSL/ext4.
- Ambiente operacional: hibrido WSL + Windows.
- WSL e a camada de desenvolvimento de codigo, `analyze`, `test`, web local e Widgetbook por comandos Flutter Linux.
- Windows e a camada preferencial de Android SDK, emulator, dispositivo fisico, `adb`, `flutter run -d android` e build Android.
- Flutter SDK, Android SDK e PowerShell entram como runtime/build da camada correspondente; nao como raiz de codigo-fonte.
- Ausencia de PowerShell ou Android SDK dentro da WSL nao deve ser classificada como falha do projeto.

## Superficies de projeto que existem hoje

### Contexto de projeto

- `../AGENTS.md`
- `../BOOTSTRAP.md`
- `../GEMINI.md`
- `../CLAUDE.md`
- `../HERMES.md`

### Documentos primarios e normativos

- `../README.md`
- `README.md`
- `RUNTIME_CANONICO_E_VALIDACAO.md`

### Documentos operacionais especializados

- `android-distribution-playbook.md`
- `ACESSO_EXTERNO_CONTROLADO.md`
- `entity-governance-and-android-testing.md`
- `validation-and-testing-guide.md`

### Configuracao e runtime do app

- `../pubspec.yaml`
- `../analysis_options.yaml`
- `../.env.example`
- `../tool/android/build_release.ps1`

### Validacao

- `../test/*.dart`
- `/opt/flutter/bin/flutter analyze` na WSL, ou `flutter analyze` quando o PATH estiver configurado
- `/opt/flutter/bin/flutter test` na WSL, ou `flutter test` quando o PATH estiver configurado
- `flutter doctor -v`, `adb devices`, `flutter devices` e `flutter run -d android` no Windows host para validacao Android

## Como modelar este repo no control plane

### Modulo context

Mapear para:

- `AGENTS.md`
- `BOOTSTRAP.md`
- `GEMINI.md`
- `CLAUDE.md`
- `HERMES.md`

### Modulo runtime

Mapear para:

- `README.md`
- `RUNTIME_CANONICO_E_VALIDACAO.md`
- `tool/android/build_release.ps1`
- `ACESSO_EXTERNO_CONTROLADO.md`

### Modulo validation

Mapear para:

- `validation-and-testing-guide.md`
- `entity-governance-and-android-testing.md`
- `flutter analyze`
- `flutter test`
- diagnostico Android no Windows host: `where flutter`, `where adb`, `adb devices`, `flutter devices`

### Modulo docs operacionais

Mapear para:

- `android-distribution-playbook.md`
- `ACESSO_EXTERNO_CONTROLADO.md`
- `web-mobile-fallback-plan.md`

## Escopo e precedencia

### Project-scope

Tudo o que esta versionado neste repo e project-scope.

Isso inclui:

- markdowns de contexto
- docs operacionais
- scripts de build
- configs Flutter e do app

### User-scope

Devem permanecer fora deste repo:

- settings globais de Codex
- settings globais de Gemini
- settings globais de Claude
- configs e memorias do Hermes
- tokens, credenciais e MCPs globais de usuario

## Artefatos deliberadamente NAO materializados aqui

Nao existe evidencia suficiente hoje para versionar neste projeto:

- `.codex/config.toml`
- `.codex/execpolicy.yaml`
- `.gemini/settings.json`
- `gemini-extension.json`
- `.gemini/commands/*.toml`
- `.gemini/skills/*`
- `.claude/settings.json`
- `.claude/settings.local.json`
- `.mcp.json`

Regra:

- so criar esses arquivos quando houver um caso de uso operacional real deste repo que exija comportamento local diferente do user-scope

## Uso de contexto externo

Nao ha Cerebro Central canonico disponivel neste workspace WSL.

Regra:

- nao modelar este repo como dependente de repo cross-project externo em Windows
- nao assumir `/mnt/c/...` ou outro repo externo que nao exista no filesystem atual
- contexto cross-project, quando existir de fato, e apenas consultivo

Limite:

- contexto externo nao substitui a leitura do repo atual
- contexto externo nao autoriza criar config local sem aderencia real a este projeto

## Acao recomendada quando o control plane apontar para este repo

1. ler `AGENTS.md`
2. ler `BOOTSTRAP.md`
3. abrir `README.md`
4. abrir `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
5. escolher os docs operacionais especializados conforme a mudanca
