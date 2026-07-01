# Auditoria Operacional - Tecnicos, APK/PWA e Anexos

Data: 2026-06-25

Escopo: auditoria funcional, operacional e de UX do fluxo diario dos tecnicos no SIS Mobile.

Restricao aplicada na fase de auditoria: nenhuma correcao foi implementada naquela etapa. A validacao contra GLPI real permaneceu read-only por padrao; nao houve criacao, alteracao, fechamento, anexo ou limpeza em tickets reais.

## Atualizacao de Implementacao

Data/hora: 2026-06-25 15:12:24 -03

Depois da auditoria, foram implementados os fixes locais de maior retorno operacional:

1. **Anexos**
   - envio somente com anexo agora falha quando todos os uploads falham;
   - a UI nao limpa a selecao como sucesso quando o anexo nao foi enviado;
   - falha parcial de anexo passa a retornar aviso explicito ao usuario.
2. **Assuncao/status**
   - chamado `Novo` elegivel exibe CTA `Assumir e iniciar atendimento`;
   - falha em `Ticket_User` deixa de ser tratada como sucesso simples;
   - sucesso de assuncao exige read-back fresco com status `Em Atendimento` e tecnico responsavel confirmado.
3. **Fila operacional**
   - tickets `_source: operational` passam a usar `TicketQueueFilter`/`TicketQueueType` via `TicketQueueClassifier`;
   - a UI deixa de depender apenas do balde generico `Fila Operacional` quando consegue resolver `Atribuidos a mim`, `Fila Manutencao`, `Fila Conservacao` ou `Demandas GG Conservacao`.

Arquivos principais alterados nesta etapa:

- `lib/state/app_state_message_support.dart`
- `lib/screens/ticket_message_screen.dart`
- `lib/state/app_state.dart`
- `lib/screens/ticket_detail_screen.dart`
- `lib/screens/my_tickets_screen.dart`
- `lib/policy/ticket_queue_classifier.dart`
- `test/app_state_message_guard_test.dart`
- `test/app_state_status_guard_test.dart`
- `test/ticket_detail_status_actions_test.dart`
- `test/ticket_queue_classifier_test.dart`

Validacao executada apos os fixes:

```bash
/opt/flutter/bin/flutter test test/app_state_message_guard_test.dart test/app_state_status_guard_test.dart test/ticket_detail_status_actions_test.dart test/ticket_queue_classifier_test.dart test/ticket_queue_filter_test.dart test/app_state_operational_new_queue_test.dart
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
/opt/flutter/bin/flutter build web --release -t lib/main.dart
ANDROID_HOME=/home/jonathan/Android/Sdk /opt/flutter/bin/flutter build apk --debug --flavor sis -t lib/main.dart
/home/jonathan/Android/Sdk/build-tools/36.0.0/aapt dump badging build/app/outputs/flutter-apk/app-sis-debug.apk
sha256sum build/app/outputs/flutter-apk/app-sis-debug.apk build/web/index.html
node --test tool/external-access/workers-vpc/test/*.test.mjs
cd widgetbook
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
/opt/flutter/bin/flutter build web
```

Resultados atuais:

- bateria focada dos fixes: 23 testes passaram;
- `flutter analyze`: passou, sem issues;
- `flutter test`: 293 testes passaram; 15 validacoes mutaveis foram puladas por configuracao nao habilitada;
- build PWA SIS: passou, gerou `build/web`;
- build APK debug SIS: passou, gerou `build/app/outputs/flutter-apk/app-sis-debug.apk`;
- APK badging: package `br.gov.rs.casacivil.sismobile`, label `SIS Mobile`, `minSdk 24`, `targetSdk 36`;
- APK debug: 173 MB, SHA-256 `3ad9ff33da62786afdc73d14308d4534f098a83b327553adc0bb9fd5868a625b`;
- `build/web/index.html`: SHA-256 `21580b3efce9fb6a501ccbb6ef6d5d249dd363eb9b42c00577c9cce72ab0407e`;
- Worker SIS: 22 testes passaram;
- Widgetbook gate WSL: `pub get`, `analyze`, `test` e `build web` passaram.

Limitacoes que continuam verdadeiras:

- nao houve smoke autenticado em Android ou PWA com login real;
- nao houve mutacao GLPI real para followup, solucao, status, atribuicao ou anexo;
- a prova remota de `Document_Item` em ticket sintetico ainda exige aprovacao humana explicita, ambiente/ticket isolado e credenciais de validacao.

## Metodo

Fontes lidas:

- `BOOTSTRAP.md`
- `README.md`
- `docs/README.md`
- `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
- `docs/domain/ticket/STATES.md`
- `docs/domain/ticket/TRANSITIONS.md`
- `docs/domain/ticket/INVARIANTS.md`
- `docs/domain/ticket/SOURCES_OF_TRUTH.md`
- `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md`
- `docs/FRONTEND_PROFISSIONAL_FLUTTER.md`
- `docs/FRONTEND_SURFACE_DISCOVERY_FLUTTER.md`
- `docs/WIDGETBOOK_WORKBENCH.md`
- `docs/PLANO_REGRESSAO_OPERACIONAL_SIS_MOBILE.md`
- `docs/audits/RELATORIO_SIS_MOBILE_E2E_MUTAVEL_CONTROLADO_2026-05-18.md`

Superficies e contratos inspecionados:

- `lib/screens/my_tickets_screen.dart`
- `lib/screens/ticket_detail_screen.dart`
- `lib/screens/ticket_message_screen.dart`
- `lib/state/app_state.dart`
- `lib/state/app_state_ticket_support.dart`
- `lib/state/app_state_message_support.dart`
- `lib/state/app_state_attachment_support.dart`
- `lib/services/glpi_client.dart`
- `lib/services/glpi_client_support.dart`
- `lib/models/glpi_status.dart`
- `lib/models/ticket_message.dart`
- `lib/policy/ticket_queue_filter.dart`
- `tool/external-access/workers-vpc/src/index.js`

Comandos executados:

```bash
git status --short
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test test/ticket_status_action_matrix_test.dart test/app_state_operational_new_queue_test.dart test/ticket_detail_status_actions_test.dart test/app_state_status_guard_test.dart test/app_state_message_guard_test.dart test/app_state_solution_guard_test.dart test/app_state_reject_solution_guard_test.dart test/attachment_display_test.dart test/glpi_client_support_test.dart test/glpi_ticket_support_test.dart test/ticket_queue_filter_test.dart test/permission_service_test.dart
node --test tool/external-access/workers-vpc/test/*.test.mjs
/opt/flutter/bin/flutter build web --release -t lib/main.dart
ANDROID_HOME=/home/jonathan/Android/Sdk /opt/flutter/bin/flutter build apk --debug --flavor sis -t lib/main.dart
/home/jonathan/Android/Sdk/build-tools/36.0.0/aapt dump badging build/app/outputs/flutter-apk/app-sis-debug.apk
sha256sum build/app/outputs/flutter-apk/app-sis-debug.apk build/web/index.html
```

Resultados de validacao:

- `flutter analyze`: passou, sem issues.
- Testes Flutter focados: 67 testes passaram.
- Testes Worker SIS: 22 testes passaram.
- Build PWA SIS: passou, gerou `build/web`.
- Build APK debug SIS: passou, gerou `build/app/outputs/flutter-apk/app-sis-debug.apk`.
- APK badging: package `br.gov.rs.casacivil.sismobile`, label `SIS Mobile`, `minSdk 24`, `targetSdk 36`.
- APK debug: 173 MB, SHA-256 `8c5309ae2b9c30bb0cd6a5a2929f4705ec4b36df100da2e2cb4658de70e48cf9`.
- `build/web/index.html`: SHA-256 `21580b3efce9fb6a501ccbb6ef6d5d249dd363eb9b42c00577c9cce72ab0407e`.

Limitacoes:

- Nao houve smoke autenticado no Android nem execucao da PWA em navegador com login real.
- Nao houve comparacao visual interativa APK vs PWA em dispositivo.
- Nao houve mutacao GLPI para criar followup, solucao, status ou anexo.
- A simulacao de 20/50/100/500 tickets foi analise estrutural do codigo, nao teste visual automatizado em runtime.
- O workspace ja estava sujo antes desta auditoria, com alteracoes locais em `lib/` e `test/`; esta auditoria considerou esse estado atual e nao reverteu nada.

## Resumo Executivo

| Tema | Conclusao |
| --- | --- |
| APK/PWA | Nao ha divergencia de compilacao detectada para SIS: ambos buildam a partir de `lib/main.dart`. A equivalencia funcional ainda nao esta provada sem smoke real. |
| Fila operacional | Existe melhoria parcial: tecnicos/admins carregam fila ampla por status. A UX ainda nao separa de forma suficiente "meus", "grupo", "sem responsavel", "pendentes", "solucionados" e "encerrados". |
| Assuncao de tickets | Existe mecanismo tecnico de autoatribuicao, mas ele esta escondido como efeito colateral de mudar status para `Em Atendimento`. Nao ha CTA claro de "Assumir chamado". |
| Status `Novo -> Em Atendimento` | O app tem caminho para alterar status e depois tentar atribuir o tecnico. Acompanhamentos comuns nao mudam status, o que explica o relato de tickets permanecerem `Novo` apos interacoes. |
| Anexos | Foi encontrado defeito critico de semantica local: em envio somente com anexo, o app pode criar o followup generico e retornar sucesso mesmo que todos os uploads falhem. Isso explica o sintoma "Anexo enviado pelo aplicativo" sem arquivo real. |

## Problemas Encontrados

### Critico - Anexo-only pode virar followup generico mesmo com upload totalmente falho

Fato reportado pelo pedido:

- Ao anexar arquivos, aparece texto generico como "Anexo do aplicativo" / "Anexo enviado pelo aplicativo", sem exibicao do arquivo real.
- O comportamento foi observado no aplicativo e na PWA.

Evidencia no codigo:

- `TicketMessageScreen._sendMessage()` envia `filePaths` para `AppState.sendTicketMessageWithAttachments()` e, se `result['success'] == true`, limpa a selecao e recarrega a conversa sem verificar `attachmentsFail` ou `errors`: `lib/screens/ticket_message_screen.dart:246`.
- `AppStateMessageSupport.sendTicketMessageWithAttachments()` cria uma interacao quando ha texto ou anexos: `lib/state/app_state_message_support.dart:135`.
- Quando nao ha texto, o conteudo efetivo vira `[Anexo enviado pelo aplicativo]`: `lib/state/app_state_message_support.dart:141`.
- O upload dos arquivos ocorre depois da interacao criada: `lib/state/app_state_message_support.dart:178`.
- A variavel `isSuccess` considera `mustCreateInteraction` como sucesso, mesmo que `successCount == 0` e `failCount > 0`: `lib/state/app_state_message_support.dart:194`.
- `TicketMessage.fromDocumentMap()` so renderiza o arquivo real quando existe documento recuperado com `name` e `download_url`: `lib/models/ticket_message.dart:274`.
- O upload direto exige prova por `Document_Item`; se nao houver ID/verificacao, aborta para evitar `Document` orfao: `lib/services/glpi_client.dart:1142` e `lib/services/glpi_client.dart:1170`.

Causa provavel:

- Alta confianca: o fluxo mistura "criar interacao textual" com "subir/vincular documento". Se o envio e somente anexo, a interacao generica e criada primeiro; se o upload falha, o retorno ainda pode ser tratado como sucesso pela UI.
- Media confianca: quando o upload para `ITILFollowup/{id}/Document` ou `ITILSolution/{id}/Document` falha, `AppStateAttachmentSupport` faz fallback para `Ticket/{ticketId}/Document`, o que pode separar visualmente o texto generico do documento real: `lib/state/app_state_attachment_support.dart:85`.

Impacto operacional:

- O tecnico ou solicitante acredita que anexou evidencia, mas o arquivo pode nao estar vinculado ou visivel.
- A conversa fica poluida com followup generico sem prova documental.
- Como o erro pode ser mascarado como sucesso, o usuario nao tem acao corretiva imediata.

Recomendacao:

1. Corrigir a semantica de retorno: envio somente com anexo deve falhar se `successCount == 0`.
2. Exibir erro parcial quando `attachmentsFail > 0`, mesmo que texto/followup tenha sido criado.
3. Diferenciar claramente no retorno: `interactionCreated`, `attachmentsSuccess`, `attachmentsFail`, `fallbackToTicketRoot`.
4. No read-back, exigir prova `Document_Item` do item correto para followup/solucao quando o fluxo pede anexo contextual.
5. Criar validacao mutavel isolada em ticket sintetico para: abertura com anexo, acompanhamento com anexo, solucao com anexo e download posterior.

### Alto - Assumir chamado existe como efeito colateral, nao como fluxo claro

Fato observado no codigo:

- O contrato de dominio permite tecnico mudar `Novo -> Em Atendimento`: `docs/domain/ticket/TRANSITIONS.md`.
- A tela de detalhe mostra botao generico `Alterar status`, nao `Assumir chamado`: `lib/screens/ticket_detail_screen.dart:503`.
- O bottom sheet lista status permitidos, com fallback para `Em Atendimento` e `Solucionado`: `lib/screens/ticket_detail_screen.dart:410`.
- `AppState.updateTicketStatus()` primeiro altera status via `PUT /Ticket/{id}` e depois, se o alvo for `Em Atendimento`, chama `assignTicketToMe()`: `lib/state/app_state.dart:764` e `lib/state/app_state.dart:789`.
- `GlpiClient.assignTicketToMe()` usa `POST /Ticket_User` com `type: 2`: `lib/services/glpi_client.dart:1956`.
- Se a atribuicao falha, `updateTicketStatus()` ainda retorna `success: true` com mensagem de falha de atribuicao: `lib/state/app_state.dart:824`.

Causa provavel:

- Alta confianca: a capacidade tecnica existe, mas a UX nao comunica "assumir/iniciar atendimento"; ela comunica apenas mudanca de status.
- Alta confianca: o fluxo nao e atomico. O ticket pode ficar `Em Atendimento` mesmo se a atribuicao do tecnico falhar.

Impacto operacional:

- Tecnicos podem nao perceber como assumir tickets `Novo`.
- Acompanhamentos comuns nao alteram status; isso e coerente com o codigo atual, mas pode contrariar expectativa operacional se a UI nao orientar o usuario.
- Uma falha de `Ticket_User` pode deixar o ticket iniciado sem responsavel tecnico claro.

Recomendacao:

1. Para ticket `Novo` elegivel, expor CTA explicita: `Assumir e iniciar atendimento`.
2. Separar visualmente `Assumir` de `Registrar solucao`.
3. Confirmar por read-back depois da acao: status final, `Ticket_User` do tecnico e grupo/fila.
4. Tratar falha de atribuicao como falha operacional do fluxo principal, nao como sucesso simples.

### Alto - Fila operacional ainda nao escala como mesa de trabalho de tecnico

Fato observado no codigo:

- Para perfis tecnicos/admin, `AppState.fetchTickets()` busca tickets pessoais e tambem consulta fila ampla por status `Novo`, `Em Atendimento`, `Planejado`, `Pendente` e `Solucionado`: `lib/state/app_state.dart:636`.
- `GlpiClient.getTicketsByStatus()` consulta ate `range=0-500` por status: `lib/services/glpi_client.dart:392`.
- Tickets que nao sao pessoais sao marcados apenas com `_source: operational`: `lib/state/app_state.dart:662`.
- `MyTicketsScreen._groupKey()` colapsa todos esses tickets em um unico grupo `Fila Operacional`: `lib/screens/my_tickets_screen.dart:97`.
- Tickets pessoais sao agrupados por status, nao por fila operacional: `lib/screens/my_tickets_screen.dart:334`.
- Existe camada de politica capaz de resolver filas como `Atribuidos a mim`, `Fila Manutencao`, `Fila Conservacao`, `Pendentes de validacao`, mas ela nao esta ligada a `MyTicketsScreen`: `lib/policy/ticket_queue_filter.dart:8` e `lib/models/ticket_queue_type.dart:1`.
- Ao expandir um grupo, o `ExpansionTile` recebe `children: ticketsInGroup.map(...).toList()`, construindo todos os cards daquele grupo de uma vez: `lib/screens/my_tickets_screen.dart:449`.

Analise de escalabilidade:

| Volume | Avaliacao |
| --- | --- |
| 20 tickets | Usavel, especialmente com grupos fechados. |
| 50 tickets | Usavel com filtros, mas a separacao operacional ainda exige leitura manual. |
| 100 tickets | Risco alto de perda de prioridade; `Fila Operacional` vira balde generico. |
| 500 tickets | Nao recomendado no desenho atual: cada status pode buscar ate 500 e um grupo expandido constroi todos os filhos de uma vez. |

Causa provavel:

- Alta confianca: a tela `Meus Chamados` foi evoluida para incluir a fila operacional, mas ainda nao virou uma mesa de trabalho de tecnico.

Impacto operacional:

- O tecnico nao distingue rapidamente: meus chamados, chamados do grupo, chamados sem responsavel, pendentes, solucionados e encerrados.
- Com muitos tickets, a triagem depende de rolagem e filtros manuais.

Recomendacao:

1. Reorganizar a tela por intencao operacional, nao apenas por status.
2. Modelo recomendado para mobile:
   - `Acao agora`: novos sem responsavel, pendentes de tecnico, falhas de sync.
   - `Meus`: atribuidos a mim em atendimento/pendentes.
   - `Grupo`: chamados do grupo sem dono ou compartilhados.
   - `Solucionados`: aguardando validacao.
   - `Encerrados`: fechados/cancelados para leitura historica.
3. Usar segmented controls ou tabs para o primeiro nivel; accordion pode continuar dentro de cada secao.
4. Evitar construir centenas de filhos dentro de um unico `ExpansionTile`; usar listas lazy por secao.

### Medio - APK e PWA compilam, mas equivalencia funcional ainda nao esta provada

Fato verificado:

- `flutter build web --release -t lib/main.dart` passou.
- `flutter build apk --debug --flavor sis -t lib/main.dart` passou.
- O APK gerado usa package `br.gov.rs.casacivil.sismobile` e label `SIS Mobile`.
- `web/manifest.json` e `build/web/manifest.json` declaram `SIS Mobile`, `display: standalone`, `orientation: portrait-primary`.

Riscos restantes:

- O fluxo de conversa usa camera, galeria, arquivos, abertura de arquivo e salvar imagem: `lib/screens/ticket_message_screen.dart:1147`, `lib/screens/ticket_message_screen.dart:793` e `lib/screens/ticket_message_screen.dart:872`.
- Build web bem-sucedido nao prova que `open_filex`, `gal`, camera, permissao de galeria e download se comportem de forma equivalente em navegador/PWA e APK.

Conclusao:

- Nao ha divergencia estrutural de build detectada.
- Existe risco funcional de plataforma no fluxo de anexos e download, que precisa de smoke APK/PWA com o mesmo ticket sintetico.

Recomendacao:

1. Definir matriz APK/PWA para anexos: selecionar, enviar, persistir, listar, visualizar imagem, baixar/abrir arquivo nao-imagem.
2. Rodar a mesma matriz em APK e PWA com ticket sintetico isolado.
3. Tratar diferencas de plataforma como UX explicita, nao como comportamento implícito.

### Baixo - Advertencia recorrente em testes sobre binding Flutter

Fato observado:

- A bateria focada passou, mas varios testes emitiram aviso `Binding has not yet been initialized` ao carregar contrato de regras GLPI.

Impacto:

- Nao falhou a validacao, mas gera ruido e pode esconder logs operacionais importantes em rodadas futuras.

Recomendacao:

- Inicializar binding nos testes afetados ou tornar o carregamento do contrato tolerante a ambiente headless sem stack Flutter completa.

## Respostas Diretas as Perguntas

1. Existem divergencias entre APK e PWA?
   - Compilacao: nao detectada. APK debug e PWA buildaram.
   - Funcional: nao provada. O maior risco esta em anexos, download/abertura de arquivo, camera/galeria e salvar imagem.

2. A fila operacional atual escala adequadamente?
   - Parcialmente. Ela escala tecnicamente para buscar muitos tickets, mas a UX nao escala bem para operacao diaria com 100+ ou 500 tickets.

3. O tecnico consegue assumir tickets de forma clara?
   - Nao de forma clara. O mecanismo esta escondido dentro de `Alterar status -> Em Atendimento`.

4. Existe mecanismo funcional de autoatribuicao?
   - Sim, mas apenas como efeito colateral apos mudar status para `Em Atendimento`. Nao ha CTA independente e a falha de atribuicao ainda retorna `success: true`.

5. Existe falha na transicao de `Novo` para `Em Atendimento`?
   - O codigo possui caminho para a transicao. O relato de followups mantendo status `Novo` e coerente com o desenho atual: followup comum nao muda status. A falha mais provavel e UX/descoberta da acao, mais o risco de atribuicao falhar apos status.

6. O fluxo atual esta aderente ao GLPI?
   - Parcialmente. Usa `PUT /Ticket/{id}` para status, `POST /Ticket_User` para tecnico, `POST /TicketFollowup`, `POST /ITILSolution` e rotas diretas de `Document`. A aderencia operacional ainda precisa de read-back real em ticket sintetico.

7. Os anexos realmente funcionam?
   - Nao foi comprovado neste turno por restricao read-only. O codigo tem defeito critico que pode mascarar falha total de upload como sucesso quando a interacao generica foi criada.

8. Onde exatamente ocorre a falha dos anexos?
   - Ponto mais provavel: `AppStateMessageSupport.sendTicketMessageWithAttachments()`, depois de criar o followup/solution generico e durante/apos o loop de upload. O retorno `success` nao representa corretamente falha total dos anexos.

9. Quais problemas impactam diretamente a operacao diaria dos tecnicos?
   - Anexo aparentemente enviado sem arquivo real.
   - Falta de CTA clara para assumir chamado.
   - Ticket `Novo` permanecendo novo apos followups, sem orientacao para iniciar atendimento.
   - Fila operacional pouco discriminada para alto volume.
   - Falta de prova APK/PWA equivalente no fluxo de anexos.

10. Quais correcoes possuem maior retorno operacional?
   - Corrigir semantica e feedback de anexos.
   - Criar fluxo explicito de `Assumir e iniciar atendimento` com read-back.
   - Reorganizar fila operacional por trabalho do tecnico.
   - Criar smoke mutavel controlado para anexos em ticket sintetico, rodado em APK e PWA.

## Priorizacao Recomendada

1. **Anexos - Critico**
   - Ajustar retorno de `sendTicketMessageWithAttachments()`.
   - Exibir falha parcial/total ao usuario.
   - Validar `Document_Item` do item correto.

2. **Assuncao/status - Alto**
   - Expor `Assumir e iniciar atendimento`.
   - Confirmar `Ticket.status` e `Ticket_User` por read-back.
   - Nao tratar falha de atribuicao como sucesso simples.

3. **Fila operacional - Alto**
   - Ligar `TicketQueueFilter`/`TicketQueueType` na UI.
   - Separar meus, grupo, sem responsavel, pendentes e historico.
   - Tornar listas lazy/paginadas para alto volume.

4. **APK/PWA - Medio**
   - Smoke comparativo em ticket sintetico para anexo, visualizacao e download.
   - Registrar diferencas reais de plataforma.

5. **Guarda visual/operacional - Medio**
   - Modelar fluxo de tecnico no Widgetbook antes de redesign.
   - Acrescentar fixtures de 20/50/100/500 tickets.

## Proxima Validacao Necessaria

Para fechar diagnostico de anexos sem risco a tickets reais:

1. Aprovar explicitamente ticket sintetico isolado ou ambiente sandbox.
2. Rodar no APK:
   - followup somente com anexo;
   - followup com texto + anexo;
   - solucao com anexo;
   - abertura com anexo.
3. Rodar os mesmos casos na PWA.
4. Para cada caso, registrar:
   - ID de `TicketFollowup`/`ITILSolution`;
   - IDs de `Document`;
   - linhas de `Document_Item`;
   - visualizacao no app;
   - visualizacao no GLPI web;
   - download real do arquivo.

Sem essa prova, a causa raiz remota do GLPI nao fica fechada. Com a evidencia estatica atual, a causa local mais provavel ja e forte o suficiente para entrar como primeiro fix.

## Atualizacao - Validacao E2E Controlada em 2026-06-25 15:43

Escopo executado com 3 tickets sinteticos `"[TESTE-AUTOMATIZADO SIS] [E2E-CONTROLADO]"`, usando credenciais de teste/admin do `.env` sem expor secrets:

- `10011`: fluxo principal de criacao, mensagem, anexo, visualizacao no GLPI Web, visualizacao no app e acao tecnica.
- `10012`: aprovacao de solucao.
- `10013`: recusa de solucao.

Comandos principais:

- `/opt/flutter/bin/dart run tool/validation/sis_controlled_e2e.dart audit`
- `/opt/flutter/bin/dart run tool/validation/sis_controlled_e2e.dart setup`
- `/opt/flutter/bin/flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083`
- `npx --yes --package @playwright/cli playwright-cli ...`
- `/opt/flutter/bin/dart run tool/validation/sis_controlled_e2e.dart cleanup`

Resultado:

- Auditoria inicial: `total=88`, `openCount=0`.
- Setup criou exatamente 3 tickets: `10011`, `10012`, `10013`.
- `10011` foi criado via Worker/app path com categoria `47`, entidade `28`, grupo atribuido `21 / CC-CONSERVACAO`, status inicial `Novo`.
- Mensagem em `10011`: `TicketFollowup` criado com status HTTP `201`, visivel no app em `Chamado: 10011 Conversa e anexos`.
- Anexo em `10011`: upload retornou HTTP `201` e `documentId=7557`.
- GLPI Web original confirmou o anexo no ticket `10011`: link `/sis/front/document.send.php?docid=7557&tickets_id=10011`.
- App/PWA nao conseguiu visualizar o anexo: a tela `Anexos do Chamado` mostrou `Nenhum anexo encontrado`.
- Console do app confirmou `403` em:
  - `Ticket/10011/Document_Item`
  - `ITILFollowup/13166/Document_Item`
- Perfil tecnico/admin no app abriu `10011` pela `Fila Conservacao`, exibiu `Acoes de Status` e o CTA `Assumir e iniciar atendimento`.
- Acionar o CTA no app mudou `10011` para `Em Atendimento` e exibiu `Tecnico Responsavel Jonathan Nascimento Moletta`.
- GLPI Web original confirmou `10011` como `Em atendimento (atribuido)` e ator atribuido `Jonathan Nascimento Moletta`, alem do grupo `CC-CONSERVACAO`.
- `10012` foi confirmado no GLPI Web como `Fechado` apos aprovacao (`5 -> 6`).
- `10013` foi confirmado no GLPI Web como `Novo` apos recusa/reabertura (`5 -> 1`).
- Cleanup fechou `10011`, `10012`, `10013`.
- Auditoria final independente: `total=91`, `openCount=0`, `openTickets=[]`.

Evidencias salvas em `output/e2e/`:

- `glpi-ticket-10011-initial.png`
- `app-ticket-10011-no-attachments.png`
- `app-ticket-10011-conversation-message-no-attachment.png`
- `apptech-ticket-10011-status-action-visible.png`
- `apptech-ticket-10011-after-assume.png`
- `glpi-ticket-10011-after-assume.png`
- `glpi-ticket-10012-approved-closed.png`
- `glpi-ticket-10013-rejected-reopened.png`
- `final-audit.json`

Conclusao atual:

- Status/assuncao tecnica estao funcionais no app e confirmados no GLPI Web original.
- Aprovacao e recusa de solucao funcionaram e foram confirmadas no GLPI Web original.
- Anexo nao pode ser considerado OK no aplicativo: ele existe no GLPI Web original, mas o app nao consegue lista-lo/visualiza-lo porque as rotas `Document_Item` retornam `403`.
