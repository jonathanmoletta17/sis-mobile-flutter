# Padronizacao dos Apps SIS e DTIC

## Objetivo

Definir o padrao de telas, funcionamento e reaproveitamento entre as linhas SIS
e DTIC dentro deste repositorio, sem misturar regras de negocio nem criar
acoplamento indevido entre os dois contextos.

Este documento complementa:

- `SIS_MOBILE_PRODUTO_UI_CANONICO.md`, que continua sendo o contrato do app SIS
- `DTIC_MOBILE_V1.md`, que continua sendo o contrato tecnico da linha DTIC

## Decisao de produto

SIS e DTIC devem compartilhar a mesma fundacao de app mobile operacional, mas
nao devem ser tratados como a mesma aplicacao com textos trocados.

Padrao comum:

- Flutter + Material 3
- `Provider` como gerenciamento de estado
- `AppTheme`, `AppColors`, `AppSpacing`, `AppRadius` e `AppStatusPalette`
- componentes `widgets/ui/`
- superficie compartilhada de login em `GlpiLoginSurface`
- estados explicitos de `loading`, `empty`, `error` e `success/data`
- autenticacao GLPI por usuario e senha
- sessao de usuario por `Session-Token`
- acesso externo via Worker quando o uso for fora do dominio institucional
- configuracao runtime separada por app: `SIS_GLPI_BASE_URL` e
  `DTIC_GLPI_BASE_URL`, com `GLPI_BASE_URL` apenas como fallback legado

Padrao especifico:

- SIS usa catalogo hardcoded em `service_data.dart`, abertura por payload SIS,
  fila offline e acoes completas de ticket conforme permissao/estado
- DTIC usa catalogo FormCreator como fonte de verdade para solicitacoes,
  Worker proprio com `App-Token` server-side e as mesmas capacidades de produto
  devem evoluir por paridade sempre que o GLPI DTIC e o contrato de seguranca
  suportarem

## Matriz de telas

| Superficie | SIS | DTIC | Padrao esperado |
| --- | --- | --- | --- |
| Entrada do app | `main.dart` + `LoginScreen` | `main_dtic.dart` + `DticLoginScreen` | Cada app tem entrypoint e estado proprio. Tema compartilhado. |
| Login | marca SIS e GLPI SIS | marca DTIC e GLPI DTIC | Mesma composicao visual por `GlpiLoginSurface`: usuario, senha, erro claro, loading e CTA unica. Texto/identidade por contexto. |
| Navegacao principal | abas inferiores: servicos, chamados, conversas e offline | abas inferiores: servicos, chamados e conversas | Mesmo shell operacional. Destinos aparecem conforme capacidade implementada por app. |
| Catalogo | categorias SIS de `service_data.dart` | formularios ativos do FormCreator | Mesmo papel de tela inicial operacional. A diferenca e so a fonte de dados da abertura. |
| Meus chamados | lista SIS com offline e filtros SIS | lista DTIC dos chamados do usuario | Mesmo padrao de agrupamento por status, busca/filtros, refresh, vazio e erro. |
| Detalhe | contexto, anexos, status e entrada para conversa | contexto, historico, anexos e painel de acoes | Mesmo padrao de leitura, anexos e acoes. Acoes variam por perfil, estado e flag. |
| Conversa | tela propria com followups, solucoes, anexos e composer | lista de conversas DTIC e detalhe com historico/resposta | Mesmo papel operacional: localizar chamados em andamento e responder quando permitido. |
| Formulario de abertura | formulario SIS estruturado e fallback offline | renderizador FormCreator com validacao local | Mesmo padrao de secoes, labels, obrigatoriedade e revisao. Contrato de submissao diferente. |
| Fila offline | superficie propria obrigatoria | capacidade pendente | Offline nao e proibido na DTIC; precisa ser modelado para respostas e/ou submissao FormCreator sem corromper chamados. |

## Padroes obrigatorios por contexto

### SIS

- Preservar o app SIS como runtime padrao.
- Preservar `service_data.dart` como catalogo SIS enquanto nao houver decisao de
  migracao.
- Manter abertura e sincronizacao offline como comportamento de primeira classe.
- Manter acoes de ticket condicionadas por estado GLPI, perfil e identidade do
  usuario.
- Nao introduzir FormCreator na SIS sem decisao arquitetural especifica.

### DTIC

- Preservar `lib/main_dtic.dart`, flavor Android e Worker DTIC separados.
- Nunca usar `service_data.dart` como fonte de verdade DTIC.
- Nunca colocar `App-Token` em Flutter, `.env`, assets ou APK.
- Manter `POST /Ticket` direto fora do fluxo DTIC.
- Manter FormCreator como fonte de verdade de catalogo e abertura.
- Acoes de ticket DTIC devem existir por capacidade de produto quando
  autorizadas pelo perfil/estado do chamado. Em ambiente externo elas tambem
  exigem:
  - `DTIC_ENABLE_TICKET_ACTIONS=true` no build
  - `ALLOW_TICKET_ACTIONS=true` no Worker
- Submissao FormCreator real e uma capacidade de abertura, nao uma razao para
  reduzir o restante do app. Em ambiente externo ela exige:
  - `DTIC_ENABLE_FORM_SUBMISSION=true` no build
  - `ALLOW_FORMCREATOR_SUBMISSION=true` no Worker
  - validacao controlada para evitar chamados indevidos

## Biblioteca visual compartilhada

Os nomes `SisPageScaffold`, `SisEmptyState`, `SisLoadingState`,
`SisStatusChip` e demais widgets `Sis*` devem ser entendidos hoje como legado
nominal da biblioteca visual deste repositorio, nao como permissao para misturar
regra SIS dentro da DTIC.

Regra pratica:

- e correto a DTIC usar `SisPageScaffold`, `SisEmptyState`, `SisLoadingState` e
  `SisStatusChip`
- nao e correto a DTIC usar `SisShellDrawer` se ele continuar acoplado a
  `AppState` da SIS
- nao e correto a DTIC usar `ServiceCard` se o card depender de
  `service_data.dart`
- se um componente visual precisar servir aos dois apps, ele deve depender de
  DTOs neutros ou parametros simples, nao de modelos SIS

## Navegacao padrao

SIS:

```text
Login
  -> Catalogo SIS
     -> Meus Chamados
     -> Conversas
     -> Fila offline
     -> Formulario SIS
     -> Detalhe
        -> Conversa
```

DTIC:

```text
Login
  -> Catalogo DTIC FormCreator
     -> Meus Chamados DTIC
     -> Conversas DTIC
     -> Formulario DTIC em validacao local
     -> Detalhe DTIC
        -> Historico, anexos e painel de acoes
           -> Mensagem, solucao, anexos e status, se habilitados
```

Essa diferenca e intencional. Padronizacao nao significa obrigar a DTIC a ter
fila offline ou todas as acoes tecnicas da SIS no MVP.

## Funcionamento padrao

Toda tela operacional nova ou alterada deve declarar:

- fonte de verdade dos dados
- estado global usado
- estados de UI suportados
- acoes permitidas
- guardas de permissao/estado
- comportamento fora do dominio
- impacto em SIS e DTIC

Padrao minimo por superficie:

- loading com `SisLoadingState` quando a carga nao for transicao curta
- empty/error com `SisEmptyState`
- refresh visivel quando a tela depende de dados remotos
- status por `GlpiStatusMapper` e `SisStatusChip`
- campos com label visivel
- erro de acao por `SnackBar` ou mensagem persistente contextual
- escrita remota sempre protegida por estado atual do chamado

## Estado da padronizacao hoje

Padronizado:

- tema e tokens compartilhados
- login SIS e DTIC na mesma superficie visual `GlpiLoginSurface`
- shell de paginas internas com `SisPageScaffold`
- navegacao inferior nas telas-raiz
- estados vazios/loading
- status GLPI e chips semanticos
- padrao geral de lista agrupada por status
- detalhe DTIC com painel de mensagem, solucao, anexos e status quando
  habilitado
- acesso externo por Worker como estrategia para operar fora do dominio

Parcialmente padronizado:

- catalogo: mesmo papel operacional, fontes de verdade diferentes
- detalhe: leitura/anexos parecidos, acoes diferentes
- formularios: ambos estruturados, mas SIS submete/faz fallback offline e DTIC
  ainda valida sem escrita real
- runtime: cada app tem chave preferencial propria, mas `GLPI_BASE_URL` segue
  como fallback legado para compatibilidade operacional

Nao padronizado de proposito:

- catalogo hardcoded SIS versus FormCreator DTIC
- fila offline SIS versus modelagem offline DTIC ainda pendente
- conversa SIS e detalhe DTIC ja compartilham o padrao de mensagem com anexos;
  ainda falta consolidar offline DTIC para respostas pendentes
- acoes tecnicas SIS versus acoes DTIC dependentes de permissao, estado e
  liberacao do Worker

Lacunas reais:

- Widgetbook DTIC ja tem previews e goldens para login, catalogo, chamados,
  conversas, detalhe e FormCreator; falta validar runtime Android real com o
  mesmo rigor aplicado a SIS
- os componentes compartilhados ainda carregam prefixo `Sis*`
- nao ha uma configuracao neutra de shell por app
- conversa DTIC ainda nao tem uma tela dedicada equivalente ao
  `TicketMessageScreen` da SIS; hoje a experiencia fica concentrada no detalhe
  com historico e painel de acoes
- DTIC ainda nao tem prova de runtime Android equivalente a SIS para todas as
  superficies
- offline DTIC e submissao FormCreator real precisam de desenho especifico para
  manter paridade sem criar chamados duplicados

## Sequenciamento recomendado

1. Manter SIS e DTIC isolados em estado, entrypoint, build e Worker.
2. Padronizar o shell de abas e as superficies operacionais equivalentes antes
   de discutir diferencas profundas de dominio.
3. Usar este documento como checklist antes de alterar telas compartilhadas.
4. Manter os previews e goldens DTIC sincronizados com cada mudanca visual.
5. Extrair componentes neutros apenas quando houver repeticao real entre SIS e
   DTIC.
6. Criar configuracao visual por app somente se houver decisao de marca DTIC
   diferente da paleta atual.
7. Validar runtime Android das duas linhas antes de distribuir build externo.
