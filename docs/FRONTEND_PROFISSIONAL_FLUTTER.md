# Frontend Profissional Flutter

## Objetivo

Este documento define a direcao de construcao de frontend para o SIS Mobile em um nivel profissional.

O objetivo nao e melhorar gradualmente o frontend atual por tentativa e erro.
O objetivo e trocar o modelo de trabalho:

- sair de frontend montado diretamente no runtime
- sair de decisoes visuais tomadas no meio da implementacao
- sair de componentes crescidos sem laboratorio e sem guarda visual

O alvo e um fluxo capaz de produzir interfaces:

- claras
- sofisticadas
- operacionais
- acessiveis
- coerentes
- auditaveis

## O que estamos rejeitando

Este repo nao deve continuar preso a:

- vibecoding visual
- ajuste de tela por tela sem sistema
- tema feito por cor hardcoded em widget
- componente criado so para resolver um caso pontual
- review visual apenas no emulador, tarde demais
- implementacao antes de tese visual, tokens e estados

## Tese de produto

O SIS Mobile deve ser tratado como um produto de servico publico institucional com densidade operacional.

Isso significa:

- menos estetica de app generico
- menos heranca visual improvisada do frontend atual
- mais hierarquia, ritmo e linguagem de produto
- mais confianca, sobriedade e legibilidade

O app nao precisa parecer um dashboard web reduzido.
Ele precisa parecer um produto mobile serio, inteligente e util para operacao real.

## Principios

1. Runtime nao e laboratorio

- o app principal existe para provar contrato funcional e experiencia real
- exploracao visual acontece antes, fora do runtime canonico

2. Sistema antes de tela

- tipografia, cor, espacamento, icones, estados, motion e conteudo precisam existir como sistema
- tela sem sistema volta a gerar incoerencia

3. Estado visual e parte do componente

- loading, empty, error, disabled, success, pending e offline nao sao detalhe
- cada componente e cada superficie precisam nascer com esses estados

4. Conteudo e interface sao a mesma coisa

- labels, helper text, erros, titulos, vazios e CTA fazem parte do sistema
- nao existe frontend bom com linguagem operacional fraca

5. Evidencia antes de promocao

- design sem laboratorio vira opiniao
- implementacao sem baseline visual vira regressao futura
- runtime sem validacao real vira ilusao

## Fluxo profissional recomendado

### Fase 1 - Discovery e tese

Objetivo:

- entender dominio
- recuperar padroes cross-project
- fechar uma tese visual e operacional

Ferramentas:

- docs deste repo
- contexto cross-project local, quando existir de fato no filesystem atual
- referencias oficiais
- repertorio institucional e de service design

Saida esperada:

- tese visual
- principios
- riscos
- lista de superficies criticas

### Fase 2 - Design lab

Objetivo:

- explorar direcoes sem contaminar o app real

Ferramentas:

- Stitch
- Figma
- Dev Mode

Saida esperada:

- 2 ou 3 direcoes visuais plausiveis
- comparacao por criterios
- proposta escolhida

### Fase 3 - Design system

Objetivo:

- transformar a direcao escolhida em sistema

Base tecnica no Flutter:

- `ColorScheme`
- `ThemeData`
- `ThemeExtension`
- biblioteca propria de componentes

Saida esperada:

- tokens semanticos
- tipografia
- espacamento
- elevation
- motion rules
- content rules
- API de componentes

### Fase 4 - Workbench de componentes

Objetivo:

- isolar componentes e superficies antes do runtime

Direcao recomendada para Flutter:

- Widgetbook como laboratorio principal
- use cases reais
- estados reais
- fixtures controladas

Saida esperada:

- catalogo de componentes
- catalogo de estados
- laboratorio de superficies

### Fase 5 - Guarda visual

Objetivo:

- impedir regressao silenciosa

Direcao recomendada:

- golden tests com Alchemist ou stack equivalente
- baseline local controlada
- revisao visual por componente e superficie

Saida esperada:

- baseline visual reproduzivel
- gate de mudanca visual via `tool/frontend/validate_widgetbook.ps1`
- atualizacao intencional de baseline via `tool/frontend/validate_widgetbook.ps1 -UpdateGoldens`

### Fase 6 - Prova de runtime

Objetivo:

- validar que o sistema continua funcional no mundo real

Ferramentas:

- `flutter analyze`
- `flutter test`
- integration tests
- Android real ou emulador
- Patrol, quando fizer sentido

Saida esperada:

- evidencia real de UX e comportamento
- regressao funcional detectada cedo

## Stack recomendada

### Fonte de verdade

- `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md`
- `lib/theme/`
- `lib/widgets/ui/`

### Design e handoff

- Stitch para exploracao e ideacao
- Figma para biblioteca, tokens e Dev Mode
- Code Connect quando houver valor real entre design e codigo

### Laboratorio Flutter

- Widgetbook para workbench

### Guarda visual

- Alchemist para golden tests

### Runtime e automacao

- integration_test do Flutter
- Patrol para trilhas Android mais fortes

## Papel das skills

### Contexto cross-project local

Uso:

- discovery
- precedentes
- historico cross-project
- reducao de invencao desnecessaria

Limite:

- nao assumir existencia de Cerebro Central em Windows, `/mnt/c` ou outro local indisponivel
- usar somente fontes externas realmente presentes no ambiente atual

### frontend-skill

Uso:

- tese visual
- composicao
- hierarquia
- direcao de arte

Limite:

- e web-first
- entra como referencia de pensamento, nao como contrato tecnico do app

### stitch-design

Uso:

- ideacao
- prompt enhancement
- geracao de direcoes e superficies

### skills locais futuras

Este repo se beneficiaria de skills proprias para:

- frontend direction em Flutter
- design lab Flutter
- workbench de componentes
- guarda visual Flutter
- runtime evidence Android
- governanca de conteudo de servico publico

## Entregaveis canonicos do novo fluxo

1. manifesto de produto e frontend
2. design system semantico
3. workbench de componentes
4. baseline visual
5. protocolo de review
6. protocolo de runtime evidence

## Nao negociaveis

- nenhuma tela importante nasce sem estado de loading, empty e error
- nenhum redesign importante entra direto no runtime
- nenhum componente canonicamente compartilhado nasce sem laboratorio
- nenhuma mudanca visual relevante sobe sem Widgetbook, baseline local e gate `tool/frontend/validate_widgetbook.ps1`
- nenhuma atualizacao de golden deve ser aceita sem `-UpdateGoldens` e revisao explicita do diff
- nenhuma camada estetica pode degradar legibilidade operacional
- acessibilidade e conteudo fazem parte do frontend, nao sao pos-trabalho

## Fases sugeridas para este repo

### Fase A - Doutrina

- consolidar manifesto
- consolidar principios
- escolher referencias absorvidas

### Fase B - Laboratorio

- criar fluxo de exploracao visual separado do app
- escolher stack de workbench Flutter

### Fase C - Sistema

- endurecer tokens
- endurecer componentes
- endurecer estados

### Fase D - Guarda

- baseline visual
- testes de regressao

### Fase E - Runtime

- validacao em Android
- validacao com fluxo real do GLPI

## Referencias oficiais recomendadas

- Flutter UI and Material:
  - https://docs.flutter.dev/ui/design/material
  - https://api.flutter.dev/flutter/material/ColorScheme-class.html
  - https://api.flutter.dev/flutter/material/ThemeExtension-class.html
- Flutter adaptive and accessibility:
  - https://docs.flutter.dev/ui/adaptive-responsive
  - https://docs.flutter.dev/ui/accessibility
- Flutter testing:
  - https://docs.flutter.dev/testing/overview
- Atlassian Design System:
  - https://atlassian.design/
- Carbon Design System:
  - https://carbondesignsystem.com/
- GOV.UK Design System:
  - https://design-system.service.gov.uk/
- Apple Human Interface Guidelines:
  - https://developer.apple.com/design/human-interface-guidelines/layout
- Figma Dev Mode:
  - https://www.figma.com/dev-mode/
- Widgetbook:
  - https://www.widgetbook.io/
  - https://docs.widgetbook.io/
- Alchemist:
  - https://pub.dev/packages/alchemist
- Patrol:
  - https://patrol.leancode.co/documentation/write-your-first-test

## Conclusao

O proximo frontend bom deste produto nao deve nascer de refactor cosmetico.

Ele deve nascer de:

- descoberta melhor
- laboratorio melhor
- sistema melhor
- guarda melhor
- prova melhor

Esse e o caminho para sair de um frontend improvisado e entrar em um frontend profissional.
