# Modelo Local para Control Plane

## Objetivo

Explicar como este repositorio deve ser representado pelo ecossistema de CLIs e pelo control plane local, sem portar cegamente a modelagem de outro repo.

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
- `flutter analyze`
- `flutter test`

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

## Uso do Cerebro Central

Repositorio:

- `C:\Users\jonathan-moletta\code\inteligencia-md-local\cerebro_central`

Papel aqui:

- busca semantica de padroes
- descoberta de docs analogos
- corroboracao historica cross-project
- apoio obrigatorio de discovery antes de criar governanca nova, docs estruturantes ou modelagem local para CLIs

Limite:

- o Cerebro nao substitui a leitura do repo atual
- o Cerebro nao autoriza criar config local sem aderencia real a este projeto

## Acao recomendada quando o control plane apontar para este repo

1. ler `AGENTS.md`
2. ler `BOOTSTRAP.md`
3. abrir `README.md`
4. abrir `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
5. escolher os docs operacionais especializados conforme a mudanca
