# Plano de Laboratorio e Guarda Visual Flutter

## Objetivo

Este documento transforma a doutrina de frontend profissional em um plano operacional aplicavel ao SIS Mobile.

Ele responde a quatro perguntas:

1. onde vamos idealizar o novo frontend
2. onde vamos testar componentes e superficies sem depender do runtime
3. como vamos impedir regressao visual
4. como vamos provar o resultado no Android real

## Decisoes principais

### 1. Design lab

Direcao escolhida:

- Stitch e Figma para ideacao e exploracao visual
- Dev Mode como ponte entre design e implementacao

Motivo:

- o app principal nao deve ser o lugar onde nascem as primeiras tentativas visuais
- exploracao de direcao, hierarquia, composicao e linguagem precisa acontecer fora do runtime

### 2. Workbench de componentes

Direcao escolhida:

- Widgetbook como laboratorio principal de componentes e superficies Flutter

Motivo:

- o conceito de use case do Widgetbook encaixa diretamente no que precisamos
- addons e knobs ajudam a exercitar estados reais de componente
- o modelo de review por use case e mais proximo do que queremos do que review acoplado ao app inteiro

### 3. Guarda visual

Direcao escolhida:

- Alchemist como baseline de golden tests

Motivo:

- permite separar goldens locais e de CI
- tem boa ergonomia para temas, cenarios e grupos
- resolve melhor a necessidade de baseline visual do Flutter do que depender apenas de review manual

### 4. Runtime evidence

Direcao escolhida:

- `flutter analyze`
- `flutter test`
- `integration_test`
- Patrol em fase posterior

Motivo:

- primeiro precisamos da prova estrutural e visual
- depois endurecemos a prova de fluxos Android e interacoes nativas

## O que nao sera a trilha principal

### storybook_flutter

Pode existir como experimento, mas nao sera o caminho principal neste repo.

Motivo:

- para Flutter, Widgetbook hoje encaixa melhor como workbench dedicado
- queremos uma trilha mais proxima de use cases e review de estados do que uma traducao do fluxo web

### review manual no emulador como guarda principal

Nao e suficiente.

Motivo:

- detecta problemas tarde demais
- nao produz baseline
- nao protege contra regressao silenciosa

### redesign direto em `lib/`

Nao e o caminho.

Motivo:

- mistura exploracao com implementacao
- acelera incoerencia
- repete o modelo que estamos tentando abandonar

## Arquitetura do fluxo

### Etapa 1 - Discovery

Entradas:

- `BOOTSTRAP.md`
- `README.md`
- `docs/README.md`
- `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
- `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md`
- `docs/FRONTEND_PROFISSIONAL_FLUTTER.md`
- Cerebro Central

Saidas:

- tese visual
- superficies prioritarias
- inventario de componentes
- inventario de estados

### Etapa 2 - Design lab

Entradas:

- tese visual
- referencias
- regras de produto e conteudo

Saidas:

- exploracoes de tela
- direcoes alternativas
- decisao de linguagem visual

### Etapa 3 - Workbench

Entradas:

- componentes e superficies selecionados
- estados canonicos

Saidas:

- use cases isolados
- fixtures
- laboratorios de tema, densidade e conteudo

### Etapa 4 - Guarda visual

Entradas:

- componentes e superficies estabilizados no workbench

Saidas:

- goldens locais
- gate visual
- diff reprodutivel

### Etapa 5 - Runtime evidence

Entradas:

- implementacao em `lib/`
- baseline visual

Saidas:

- evidencia em Android
- prova de fluxo
- regressao funcional sob controle

## Estrutura recomendada

Esta e a estrutura recomendada para comecar sem contaminar o runtime principal:

```text
widgetbook/
  lib/
    main.dart
    widgetbook.dart
    use_cases/
      ui/
      screens/
      forms/
      chat/

test/
  goldens/
    components/
    screens/
  support/
    alchemist_config.dart

integration_test/
  smoke/
  critical_flows/

patrol_test/
  smoke/
  native/
```

## Workbench canonico

### Superficies iniciais

As primeiras superficies que devem entrar no laboratorio sao:

1. login
2. shell principal
3. service card
4. meus chamados
5. status chip
6. detalhe de chamado
7. conversa
8. formulario base

### Estados minimos por superficie

Cada superficie importante deve nascer com:

- loading
- empty
- error
- success
- disabled quando aplicavel
- offline quando aplicavel

### Variantes que importam

No workbench, os cenarios relevantes nao sao decorativos. Os mais importantes aqui sao:

- texto curto e texto longo
- status diferentes
- densidade baixa e alta
- sem anexo e com anexo
- sem rede e com rede
- perfil solicitante e perfil operacional, quando o fluxo divergir

## Guarda visual canonica

### Regra

Nenhuma mudanca visual relevante deve depender apenas de review manual.

### Camadas

1. golden de componente
2. golden de superficie
3. smoke runtime no Android

### Gate minimo

Antes de promover mudanca visual importante:

1. workbench revisado
2. golden atualizada ou aprovada
3. `powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1`
4. `flutter analyze` e `flutter test` no app principal quando a mudanca tocar `lib/` ou `test/`
5. prova em Android para a superficie afetada

Para atualizacao intencional de baseline, usar:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1 -UpdateGoldens
```

## Runtime evidence canonico

### Fase inicial

- manter `flutter analyze`
- manter `flutter test`
- manter teste manual/assistido no Android

### Fase seguinte

- introduzir `integration_test`
- manter foco em fluxos essenciais

### Fase madura

- introduzir Patrol para fluxos onde interacao nativa importa
- usar Patrol principalmente para:
  - login
  - anexos
  - permissoes
  - navegacao critica

## Governanca de conteudo

O frontend novo nao sera profissional se o conteudo continuar sendo improvisado.

Direcao recomendada:

- usar principios de clareza de servico publico
- tratar labels, erros, hints, vazios e CTA como parte do sistema
- manter linguagem operacional, nao promocional

Referencias importantes:

- GOV.UK Design System
- GOV.UK service patterns
- Atlassian content design

## Skills que faltam

Este plano pede skills locais proprias.

Os contratos planejados estao em `docs/FRONTEND_SKILLS_FLUTTER.md`.

### 1. flutter-frontend-director

Responsabilidade:

- tese visual
- principio de composicao
- criterio de refinamento

### 2. flutter-design-lab

Responsabilidade:

- transformar discovery em exploracao visual
- orientar Stitch e Figma

### 3. flutter-component-workbench

Responsabilidade:

- organizar Widgetbook
- definir use cases
- padronizar fixtures e knobs

### 4. flutter-visual-guard

Responsabilidade:

- padronizar Alchemist
- baseline local
- gate visual

### 5. flutter-runtime-evidence

Responsabilidade:

- prova em Android
- evidencias
- regressao funcional relevante

### 6. service-ux-content-governance

Responsabilidade:

- labels
- mensagens
- erros
- empty states
- consistencia de linguagem institucional

## Roadmap recomendado

### Fase 0 - Preparacao

- consolidar docs desta frente
- congelar os principios
- escolher a stack principal

Saida:

- manifesto e plano aceitos

### Fase 1 - Workbench

- introduzir Widgetbook
- publicar as primeiras superficies
- definir fixtures e estados

Saida:

- laboratorio funcional separado do runtime

### Fase 2 - Guarda visual

- introduzir Alchemist
- gerar primeiros goldens de componente
- gerar primeiros goldens de superficie
- manter o gate canonico em `tool/frontend/validate_widgetbook.ps1`

Saida:

- baseline visual inicial

### Fase 3 - Runtime evidence

- introduzir `integration_test`
- formalizar smoke Android

Saida:

- trilha de prova sem depender apenas de uso manual

### Fase 4 - Patrol

- endurecer testes nativos de fluxos criticos

Saida:

- prova mais forte para anexos, permissoes e interacoes Android

## Criterios de sucesso

Vamos considerar esse plano bem sucedido quando:

- o app tiver um laboratorio proprio de componentes e superficies
- o redesign de uma tela nao depender de tentativa no runtime
- mudancas visuais relevantes tiverem baseline
- o Android continuar sendo a prova final, nao o primeiro lugar de exploracao
- o frontend passar a nascer de sistema, nao de improviso

## Referencias e precedentes

### Referencias oficiais

- Flutter Material:
  - https://docs.flutter.dev/ui/design/material
- Flutter adaptive design:
  - https://docs.flutter.dev/ui/adaptive-responsive
- Flutter accessibility:
  - https://docs.flutter.dev/ui/accessibility
- Flutter testing:
  - https://docs.flutter.dev/testing/overview
- ThemeExtension:
  - https://api.flutter.dev/flutter/material/ThemeExtension-class.html
- ColorScheme:
  - https://api.flutter.dev/flutter/material/ColorScheme-class.html
- Widgetbook:
  - https://www.widgetbook.io/
  - https://docs.widgetbook.io/
- Alchemist:
  - https://pub.dev/packages/alchemist
- Patrol:
  - https://patrol.leancode.co/documentation/write-your-first-test
- Atlassian Design System:
  - https://atlassian.design/
- Atlassian content:
  - https://atlassian.design/foundations/content
- GOV.UK Design System:
  - https://design-system.service.gov.uk/
- Apple HIG layout:
  - https://developer.apple.com/design/human-interface-guidelines/layout
- Figma Dev Mode:
  - https://www.figma.com/dev-mode/

### Precedentes locais

- `C:\Users\jonathan-moletta\code\gestao-carregadores-oficial\docs\FRONTEND_VISUAL_REVIEW_STACK_2026-04-01.md`
- `C:\Users\jonathan-moletta\code\gestao-carregadores-oficial\docs\LOADING_DESIGN_SYSTEM_2026-04-02.md`
- `C:\Users\jonathan-moletta\code\hub-operacional-web\docs\phase38-hub-storybook-visual-guard-2026-04-10.md`

## Conclusao

O laboratorio e a guarda visual nao sao extras.

Eles sao a infraestrutura minima para que o proximo frontend deste produto seja:

- novo
- sofisticado
- coerente
- seguro de evoluir

Sem isso, vamos continuar fazendo reforma visual diretamente no app e chamando isso de processo.
