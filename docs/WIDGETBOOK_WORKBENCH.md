# Widgetbook Workbench

## Objetivo

Este documento registra o laboratorio Flutter separado do runtime principal do SIS Mobile.

O workbench existe para:

- idealizar componentes e pequenas superficies fora do app principal
- revisar estados sem depender do fluxo completo do GLPI
- manter a guarda visual local antes da prova de runtime Android

## Localizacao

- app do laboratorio: `widgetbook/`

## Stack

- Flutter app separado
- dependencia local via `path` para `sis_mobile_flutter`
- Widgetbook como catalogo de componentes e use cases
- Alchemist para baseline visual local do laboratorio

## Superficies iniciais implementadas

- `LoginSurface`
- `ServiceCatalogSurface`
- `SisStatusChip`
- `SisEmptyState`
- `SisLoadingState`
- `SisSectionHeader`
- `ServiceCard`
- shell inicial com `SisPageScaffold`
- preview de `Meus Chamados`
- preview de `Conversas`
- preview de `Detalhe do chamado`
- preview de `Conversa do chamado`
- preview de `Formulario base`
- preview de `Fila offline`

## Comandos

Gate canonico a partir da raiz do repo:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1
```

Atualizacao intencional de baseline visual:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1 -UpdateGoldens
```

Execucao interativa do laboratorio:

```powershell
cd widgetbook
& 'C:\Users\jonathan-moletta\code\tools\flutter\bin\flutter.bat' run -d chrome
```

## Regras

- o workbench nao substitui o runtime principal
- nenhuma mudanca visual importante deve nascer direto em `lib/` sem passar pelo laboratorio
- o workbench deve refletir componentes e superficies reais do produto, nao demos genricas
- use cases devem representar estados relevantes, nao apenas o happy path
- alteracao de baseline deve usar `-UpdateGoldens` e ser tratada como decisao explicita

## Proximo passo

Depois desta base inicial, a sequencia correta e:

1. revisar diffs de golden antes de aceitar alteracoes visuais
2. escolher a proxima superficie do app principal a convergir com o laboratorio
3. levar a prova de runtime Android apenas depois do gate local passar
