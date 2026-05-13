# SIS Mobile - Produto e UI Canonicos

> Documento normativo para sessoes de produto, UX, UI e implementacao Flutter no `sis-mobile-flutter`.
> Em conflitos de linguagem visual, componentes, tema ou organizacao de superficies, este documento prevalece sobre notas avulsas.
> A decisao final continua precisando bater com o codigo ativo em `lib/` e com o runtime descrito em `RUNTIME_CANONICO_E_VALIDACAO.md`.

---

## 1. Mapa do produto

O `sis-mobile-flutter` nao e um hub multiaplicacao web.
Ele e um **app Flutter unico**, focado no dominio **SIS**, com operacao centrada em chamados GLPI.

### Superficies canonicas

1. **Login**
   - autenticacao via `initSession`
   - entrada principal do app
2. **Catalogo de servicos**
   - porta de entrada operacional
   - acesso a abertura de chamados e navegacao principal
3. **Meus Chamados**
   - lista, filtros, agrupamento por status e sincronizacao offline
4. **Detalhe do chamado**
   - metadados, status, resumo, anexos e acoes
5. **Conversa do chamado**
   - followups, solucoes, anexos e composer
6. **Formulario de solicitacao**
   - captura estruturada para abertura de chamados
7. **Fila offline**
   - persistencia local, sincronizacao e recuperacao de contexto

### Objetivo do produto

- permitir autenticacao real no GLPI SIS
- consultar chamados do usuario autenticado
- abrir novos chamados com contexto de entidade
- interagir em conversas e anexos
- sobreviver a oscilacao de conectividade com fila offline controlada

---

## 2. Identidade visual do produto

O runtime SIS tem **um unico dominio visual principal**: **SIS**.
Nao existe variacao de dominio como DTIC, Manutencao, Conservacao e
Carregadores dentro do app SIS.

A linha DTIC existe de forma isolada neste repositorio, com entrypoint, estado,
flavor e Worker proprios. A padronizacao entre SIS e DTIC e definida em
`PADRONIZACAO_APPS_SIS_DTIC.md`.

### Cor ancora do produto

- **SIS / marca primaria**
  - `AppColors.brand = #0A8F63`
  - uso: `AppBar`, CTAs primarias, foco principal, hero principal

### Cores auxiliares permitidas

- `AppColors.brandDark = #07563D`
- `AppColors.brandSoft = #DCEFE8`
- `AppColors.accent = #DFAB32`
- `AppColors.info = #2E7C8F`
- `AppColors.warning = #CC8B2F`
- `AppColors.danger = #C74634`
- `AppColors.success = #2E7D32`
- `AppColors.neutral = #72837D`

### Regra de uso

- verde SIS governa shell, navegacao, foco principal e hierarquia estrutural
- cores de status governam estado operacional, nunca branding
- cores especificas de categoria em `service_data.dart` sao aceitas apenas em `ServiceCard` e em elementos derivados do catalogo
- novos componentes nao devem introduzir hex direto fora de `lib/theme/app_colors.dart`

---

## 3. Stack tecnica obrigatoria

### Runtime

- Flutter 3.43.x ou compativel com o host atual
- Dart 3.9+
- Material 3 com `ThemeData` centralizado

### Estado e servicos

- `provider` para distribuicao de estado
- `AppState` como estado global canonico
- `GlpiClient` como contrato principal com o backend
- `shared_preferences` para persistencia local de sessao e fila

### UI e entradas

- `file_picker` e `image_picker` para anexos
- `font_awesome_flutter` para icones de catalogo
- `Icons` do Material para shell e navegacao

### Proibicoes

- nao criar tema paralelo por tela
- nao espalhar `Color(...)` hardcoded em widgets novos
- nao duplicar widget canonico para um caso isolado
- nao introduzir biblioteca de estado global concorrente com `AppState`
- nao criar variante web-first de arquitetura dentro deste app Flutter

---

## 4. Fonte de verdade de tema e tokens

### Arquivos canonicos

- `lib/theme/app_colors.dart`
- `lib/theme/app_spacing.dart`
- `lib/theme/app_radius.dart`
- `lib/theme/app_theme.dart`

### Regra

- tokens nascem nesses arquivos
- telas e widgets consomem tokens
- qualquer novo token precisa entrar primeiro nessa camada

### Semantica atual obrigatoria

#### Fundos

- `AppColors.background`
- `AppColors.surface`
- `AppColors.surfaceMuted`

#### Texto

- `AppColors.textStrong`
- `AppColors.textMuted`
- `AppColors.textInverse`

#### Borda

- `AppColors.border`

#### Estados

- `AppColors.success`
- `AppColors.info`
- `AppColors.warning`
- `AppColors.danger`
- `AppColors.neutral`

### Direcao futura aceita

Se a camada visual crescer, a evolucao correta e:

1. enriquecer `AppColors`
2. enriquecer `AppTheme`
3. extrair semantica adicional em widgets `ui/`

Nao e correto criar um segundo design system paralelo fora dessa hierarquia.

---

## 5. Componentes canonicos existentes

> Estes componentes sao a base compartilhada do app.
> Antes de criar widget novo, verificar se o caso cabe por extensao deles.

### Shell e estrutura

- `SisPageScaffold`
  - shell principal de pagina
  - padroniza `AppBar`, fundo e acoes
- `SisShellDrawer`
  - navegacao lateral e contexto operacional
- `SisSectionHeader`
  - cabecalhos internos de secao

### Estado e badges

- `SisStatusChip`
  - badge semantico de estado
- `SisActionBadge`
  - contador de pendencias
- `SisEmptyState`
  - vazio/erro/estado sem conteudo

### Catalogo e formularios

- `ServiceCard`
  - entrada visual das categorias do catalogo
- `CustomTextField`
- `CustomDropdownField`
- `AnexarArquivoWidget`

### Regra

- se uma tela precisar de bloco repetido, extrair para `lib/widgets/ui/` ou `lib/widgets/`
- nao criar widgets por tela para padroes que vao reaparecer

---

## 6. Superficies canonicas e responsabilidades

### 6.1 Login

Arquivo principal:

- `lib/screens/login_screen.dart`

Requisitos:

- identidade SIS clara
- marca grafica SIS apenas; nao exibir DTIC ou outra marca secundaria como identidade da tela SIS
- dois campos visiveis: usuario e senha
- erro de autenticacao direto e compreensivel
- CTA primaria unica
- sem navegacao paralela

### 6.2 Catalogo

Arquivo principal:

- `lib/screens/service_catalog_screen.dart`

Requisitos:

- hero operacional com contexto de entidade
- entrada rapida para `Meus Chamados` e `Conversas`
- grid de categorias como superficie primaria de acao
- status de sincronizacao visivel

### 6.3 Meus Chamados

Arquivo principal:

- `lib/screens/my_tickets_screen.dart`

Requisitos:

- agrupamento por status canonico
- filtros claros e reversiveis
- evidencia de chamados offline
- navegacao direta para detalhe

### 6.4 Detalhe do chamado

Arquivo principal:

- `lib/screens/ticket_detail_screen.dart`

Requisitos:

- resumo do ticket
- status atual e acoes permitidas
- anexos remotos em superficie propria
- leitura clara dos campos operacionais

### 6.5 Conversa

Arquivo principal:

- `lib/screens/ticket_message_screen.dart`

Requisitos:

- feed legivel de followups e solucoes
- anexos e imagens no fluxo da conversa
- composer unico no rodape
- bloqueio explicito quando o chamado estiver fechado

### 6.6 Formulario

Arquivo principal:

- `lib/screens/form_template.dart`

Requisitos:

- secoes claras
- labels sempre visiveis
- regras de obrigatoriedade explicitas
- anexo integrado ao fluxo de submissao

### 6.7 Fila offline

Arquivo principal:

- `lib/screens/offline_queue_screen.dart`

Requisitos:

- resumo claro da fila local
- evidencia de contexto de entidade e anexos locais
- chamada explicita para sincronizacao
- navegacao direta para detalhe de chamado offline

---

## 7. Estado canonico do app

Arquivo principal:

- `lib/state/app_state.dart`

### Responsabilidades canonicas

- sessao autenticada
- perfil e entidade ativa
- entidade alvo para novos chamados
- fila de tickets offline
- sincronizacao
- leitura de tickets
- mensageria, anexos e solucoes

### Regra

- fluxo global e de sessao deve passar por `AppState`
- telas nao devem inventar fonte paralela de verdade global
- estado efemero local pode ficar em `StatefulWidget` quando for apenas UI

---

## 8. Modelo de status e semantica operacional

Arquivos canonicos:

- `lib/models/glpi_status.dart`
- `lib/models/glpi_ticket.dart`
- `lib/models/ticket_message.dart`

### Regra

- o app nao deve comparar string crua de status espalhada
- interpretacao de status deve passar por `GlpiStatusMapper`
- UI de status deve usar tons semanticos, nao cor arbitraria por tela

### Tons atuais aceitos

- `brand`
- `info`
- `success`
- `warning`
- `danger`
- `neutral`

Se surgir novo estado operacional recorrente, primeiro evoluir o mapeamento de status e depois a camada de UI.

---

## 9. Acessibilidade minima obrigatoria

Mesmo sendo app interno, a barra tecnica minima e esta:

- labels visiveis em todos os campos
- `ElevatedButton`, `TextButton`, `IconButton` e `ListTile` para acoes, nunca gestos improvisados sem semantica
- contraste suficiente entre texto, fundo e badges
- estado desabilitado sempre visivel
- feedback de erro por `SnackBar` ou texto contextual
- fluxo principal operavel sem ambiguidade de toque

### Em Flutter

- preferir widgets semanticos do Material
- evitar usar apenas placeholder como identificacao de campo
- manter `tooltip` em icones de acao critica quando fizer sentido

---

## 10. Estados de UI obrigatorios

Toda superficie com dados deve prever:

1. `loading`
2. `empty`
3. `error`
4. `success/data`

### Regra local

- `SisEmptyState` e o padrao inicial para `empty` e `error`
- `CircularProgressIndicator` puro so e aceitavel em transicao curta
- novas superficies repetidas devem migrar para skeletons dedicados, nao spinner eterno

---

## 11. Padrrao de implementacao para novas melhorias visuais

### Ordem obrigatoria

1. resolver token
2. resolver componente canonico
3. resolver estados de tela
4. resolver acessibilidade
5. so entao detalhar polish visual

### Nunca fazer

- criar uma tela com paleta propria fora do sistema SIS
- introduzir cor fixa nova sem passar por `app_colors.dart`
- duplicar `Scaffold` com shell visual paralelo se `SisPageScaffold` puder ser evoluido
- resolver inconsistencia visual com remendo local sem extracao do padrao

---

## 12. Estrutura de pastas canonica do app atual

### Produto

- `lib/screens/`
- `lib/widgets/`
- `lib/widgets/ui/`
- `lib/theme/`
- `lib/state/`
- `lib/services/`
- `lib/models/`

### Regra editorial

- tela em `screens/`
- componente reutilizavel em `widgets/`
- componente de sistema em `widgets/ui/`
- token e tema em `theme/`
- contrato de backend em `services/`
- estado global em `state/`

---

## 13. Checklist de entrega para mudancas de produto/UI

- `flutter analyze` sem issues
- `flutter test` passando
- sem hex novo espalhado fora da camada de tema
- sem widget duplicado quando havia componente canonico aplicavel
- sem regressao visual gritante nas telas principais
- login, catalogo, meus chamados, detalhe e conversa continuam navegaveis
- erro, vazio e loading continuam tratados
- sem quebrar fluxo offline

---

## 14. Instrucoes para agentes

### Antes de propor codigo

1. identificar qual superficie do app sera alterada
2. localizar o componente canonico existente
3. localizar o token de tema existente
4. verificar impacto em `AppState`, `GlpiStatusMapper` e fluxo offline quando aplicavel

### Ao alterar UI

- preservar linguagem SIS
- manter coerencia entre login, catalogo, chamados, detalhe e conversa
- preferir melhoria sistemica a remendo pontual
- registrar no resumo final quais superficies foram afetadas

### Ao alterar o sistema visual

- mexer primeiro em `lib/theme/`
- depois em `lib/widgets/ui/`
- por ultimo nas telas

---

## 15. Roadmap de realizacao recomendado

### Fase 1 - Fundacao

- consolidar semantica de tokens
- reduzir hardcodes restantes em telas pesadas
- completar biblioteca `widgets/ui/`

### Fase 2 - Superficies de alto impacto

- login
- catalogo
- meus chamados

### Fase 3 - Superficies complexas

- detalhe do chamado
- conversa
- formularios

### Fase 4 - Qualidade visual

- harness de screenshots
- golden tests dos componentes centrais
- smoke visual Android recorrente

---

Versao adaptada ao `sis-mobile-flutter` em 11/04/2026.
