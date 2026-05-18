# SIS Mobile - Plano de regressao operacional ponta a ponta

## Restricao de seguranca para novas execucoes

Este plano registra cobertura operacional, mas nao autoriza uso de tickets reais de usuarios como massa de teste por agentes.

- Funcionalidades reais de producao continuam preservadas para usuarios autorizados.
- Validacao por agente deve ser read-only por padrao.
- Qualquer regressao mutavel exige aprovacao humana explicita, ambiente de homologacao/sandbox ou ticket sintetico isolado, credencial apropriada e criterio de parada.
- Nao executar purge, cleanup automatizado, `DELETE /Ticket` ou metodos destrutivos via Worker SIS pass-through contra GLPI real.

## Objetivo

Consolidar uma rotina de validacao incremental para o SIS Mobile Flutter, cobrindo as inconsistencias ja encontradas e os riscos ainda provaveis antes de ampliar testes em aparelho fisico ou distribuir APK para mais usuarios.

O plano evita mudar arquitetura sem evidencia. Cada etapa deve terminar com:

- comportamento observado em app real ou teste automatizado
- comando de validacao executado
- evidencia registrada
- decisao objetiva de seguir, corrigir ou replanejar

## Premissas canonicas

- A fonte canonica permanece em `/home/jonathan/projects/work/mobile/sis-mobile-flutter`.
- WSL e a camada de desenvolvimento, `flutter analyze`, `flutter test` e Widgetbook por comandos Flutter Linux.
- Windows host e a camada Android para Android SDK, emulator, dispositivo fisico, `adb` e builds Android.
- O GLPI real direto depende de rede interna, VPN institucional ou endpoint externo controlado.
- Para uso externo com "somente o APK", nao exigir VPN por aparelho como primeira fase.
- Nao usar bridge USB/LAN, `adb reverse` ou proxy de notebook como estrategia suportada.
- Nao versionar `.env`, secrets, keystores, `key.properties`, caches ou outputs de build.

## Gates obrigatorios por tipo de mudanca

### Mudanca em regra de negocio, estado ou UI Flutter

1. Teste automatizado focado cobrindo a regra.
2. `/opt/flutter/bin/flutter analyze`
3. `/opt/flutter/bin/flutter test`
4. Widgetbook se a tela ou estado visual foi afetado:
   - `cd widgetbook && /opt/flutter/bin/flutter analyze`
   - `cd widgetbook && /opt/flutter/bin/flutter test`
5. APK debug no Android host quando o fluxo for operacional.
6. Smoke manual no emulador ou aparelho fisico.

### Mudanca em acesso externo ou runtime

1. Revisar `.env` local sem versionar segredo.
2. Validar `initSession` no endpoint configurado.
3. Gerar APK debug usando o fluxo Windows/Task Scheduler ou fluxo Android host suportado.
4. Instalar em emulador ou aparelho fora da intranet.
5. Validar login, catalogo, meus chamados, detalhe, conversa, criacao e anexo.

### Mudanca em distribuicao Android

1. Nao tocar em keystores sem autorizacao explicita.
2. Usar Windows host.
3. Confirmar `android-build-task.cmd` restaurado se for reponte temporario.
4. Registrar path e timestamp do APK.

## Etapa 1 - Baseline de identidade visual SIS

### Pergunta que a etapa responde

O app inteiro comunica SIS Mobile de forma consistente, sem heranca visual indevida de DTIC ou outros produtos?

### Superficies

- login
- splash Android
- nome do app Android
- icone do app
- catalogo/servicos
- drawer
- Widgetbook

### Validacoes

- Auditar assets e textos:
  - `rg -n "DTIC|dtic|SIS|sis|Casa Civil|casacivil|logo|Logo|app_name" assets lib android widgetbook`
- Abrir app no emulador e capturar:
  - login
  - tela Servicos
  - drawer
- Rodar Widgetbook:
  - `cd widgetbook && /opt/flutter/bin/flutter analyze && /opt/flutter/bin/flutter test`

### Criterio de aceite

- Nenhum logo DTIC aparece como marca principal do app.
- Nome, icone e textos principais apontam para SIS Mobile.
- Se houver marca institucional secundaria, ela deve ser intencional e documentada.

## Etapa 2 - Matriz de identidade GLPI: nomes versus IDs

### Pergunta que a etapa responde

Todas as telas exibem nomes humanos onde o usuario espera nomes, e IDs apenas onde ID tecnico e util?

### Campos criticos

- solicitante
- tecnico responsavel
- autor de followup
- autor de solucao
- entidade ativa
- categoria/servico
- anexos/documentos

### Casos obrigatorios

1. Usuario com `firstname` e `realname`.
2. Usuario com apenas `name/login`.
3. Usuario retornado como ID numerico.
4. Tecnico nao atribuido.
5. Ticket com solicitante e tecnico iguais.
6. Ticket com solicitante e tecnico diferentes.

### Validacoes

- Testes unitarios de parsing/formatacao.
- Fixtures GLPI para `Ticket_User` e `User/{id}`.
- App real abrindo tickets dos seis casos.
- Captura de detalhe e conversa no emulador.

### Criterio de aceite

- `Solicitante` e `Tecnico Responsavel` nunca aparecem como `2039` quando a API permite resolver nome.
- Quando nao for possivel resolver nome, o fallback deve ser claro e restrito, por exemplo `Usuario 2039`.

## Etapa 3 - Matriz de papeis por chamado

### Pergunta que a etapa responde

O app decide a interface pelo papel do usuario naquele chamado, e nao apenas pelo perfil global do GLPI?

### Regras esperadas

- Se usuario logado e solicitante do chamado, ve fluxo de solicitante naquele chamado.
- Se usuario logado e tecnico, mas tambem e solicitante, nao deve aprovar a propria solucao.
- Se usuario logado e tecnico e nao e solicitante, pode executar acoes tecnicas quando o status permite.
- Aprovacao/recusa de solucao pertence ao solicitante original.

### Casos obrigatorios

1. Solicitante comum abre chamado.
2. Tecnico abre seu proprio chamado.
3. Tecnico B assume chamado aberto por solicitante A.
4. Solicitante A aprova solucao proposta por tecnico B.
5. Solicitante A recusa solucao proposta por tecnico B.
6. Tecnico B tenta aprovar a propria solucao.

### Validacoes

- Testes em `AppStateTicketSupport`.
- Teste de `TicketMessage.senderUserId`.
- Teste manual multiusuario no GLPI real.
- Capturas de tela antes e depois de cada acao.

### Criterio de aceite

- Nenhum usuario aprova ou recusa a propria solucao por acidente.
- Acoes tecnicas nao aparecem para o solicitante do chamado.
- Acoes de aprovacao nao aparecem para quem propôs a solucao.

## Etapa 4 - Maquina de estados do ticket

### Pergunta que a etapa responde

Os botoes, mensagens e listas seguem o status real do GLPI sem estado local stale?

### Estados GLPI a cobrir

- Novo
- Em Atendimento
- Planejado
- Pendente
- Solucionado
- Fechado
- Offline local

### Transicoes obrigatorias

1. Novo -> Em Atendimento
2. Em Atendimento -> Solucionado com solucao registrada
3. Solucionado/Pendente -> Fechado por aprovacao
4. Solucionado/Pendente -> Novo ou Em Atendimento por recusa, conforme contrato GLPI validado
5. Fechado -> tentativa de alteracao bloqueada
6. Offline -> sincronizado -> status remoto inicial correto

### Validacoes

- Testes unitarios de `GlpiStatusMapper`.
- Testes de policy para ocultar acoes em status terminal.
- App real apos cada acao deve recarregar detalhe e conversa.
- Conferir GLPI web para status final.

### Criterio de aceite

- Ticket fechado nao mostra `Em Atendimento`, `Solucionado`, campo de mensagem nem modo de solucao.
- Conversa de ticket fechado nao mostra pendencia contraditoria.
- Depois de aprovar/recusar/mudar status, a tela reflete o GLPI real.

## Etapa 5 - Detalhe do chamado e resumo do formulario

### Pergunta que a etapa responde

O detalhe mostra informacao util para humano sem vazar payload tecnico do app?

### Campos principais esperados

- titulo
- servico
- status
- solicitante
- tecnico responsavel
- data de abertura
- localizacao
- telefone
- resumo do atendimento legivel
- anexos

### Campos que devem ficar fora do corpo principal

- tipo de solicitacao `Helpdesk`
- urgencia/impacto/prioridade em formato cru
- IDs internos sem contexto
- nomes UUID de anexos dentro do resumo
- separadores de payload

### Validacoes

- `test/ticket_form_summary_test.dart`
- Ticket criado pelo app com anexo.
- Ticket antigo com `content` HTML ou texto livre.
- Ticket sem formulario estruturado.

### Criterio de aceite

- Nenhum resumo mostra `-- FORMULARIO DO APP`, `----`, `Urgencia: 3` cru ou nome UUID de anexo.
- Metadados tecnicos ficam colapsados ou ausentes da leitura principal.

## Etapa 6 - Conversa, followup, solucao e anexos

### Pergunta que a etapa responde

A conversa opera como historico confiavel, sem confundir followup, anexo, solucao e estado final?

### Casos obrigatorios

1. Conversa vazia.
2. Conversa com followups.
3. Conversa com anexos de imagem.
4. Conversa com PDF/documento.
5. Solucao pendente.
6. Solucao aprovada.
7. Solucao recusada.
8. Ticket fechado com solucao historica inconsistente no GLPI.
9. Falha inicial de carregamento de mensagens.

### Validacoes

- Widgetbook para `active`, `solution-pending`, `closed`, `empty`, `loading`, `error`.
- Teste manual de envio de followup curto.
- Teste manual de anexo.
- Teste multiusuario de solucao.
- E2E sintetico deve validar anexo por leitura posterior em `Document_Item` e detalhe do `Document`; `Ticket/{id}/Document` pode retornar vazio mesmo quando o vinculo existe. HTTP 200/201 no endpoint direto nao basta se a resposta nao retornar ID de documento.

### Criterio de aceite

- Falha de carregamento nao parece conversa vazia.
- Ticket fechado bloqueia input.
- Solucao historica em ticket fechado nao aparece como acao pendente.
- Anexos abrem ou exibem erro claro.
- Upload direto de anexo so pode ser considerado sucesso se houver ID de documento ou vinculo verificavel em `Document_Item`; caso contrario, o app deve abortar com erro claro. No GLPI SIS, nao usar fallback `/Document` + `/Document_Item`, pois pode criar `Document` sem vinculo quando o link for negado pela API.

## Etapa 7 - Criacao de chamado e anexos

### Pergunta que a etapa responde

Criar chamado funciona de modo previsivel para todos os servicos relevantes e tipos de anexo?

### Casos obrigatorios

1. Criar chamado sem anexo.
2. Criar chamado com imagem da camera.
3. Criar chamado com imagem da galeria.
4. Criar chamado com PDF/arquivo.
5. Criar chamado com multiplos anexos.
6. Falha de upload de anexo.
7. Falha de rede depois de preencher formulario.
8. Retry apos falha.

### Validacoes

- Confirmar ticket no app.
- Confirmar ticket no GLPI web.
- Confirmar documento/anexo no GLPI web.
- Confirmar entidade correta.
- Antes de solucionar/fechar ticket criado pelo app, confirmar categoria GLPI preenchida; GLPI SIS rejeita solucao/fechamento sem categoria.

### Criterio de aceite

- O usuario nao perde dados preenchidos por falha de rede.
- Nao ha duplicidade de chamado por retry.
- Anexo aparece no GLPI e no app.

## Etapa 8 - Offline e sincronizacao

### Pergunta que a etapa responde

O trabalho feito sem rede e preservado, visivel e sincronizado na entidade correta?

### Casos obrigatorios

1. Criar chamado offline sem anexo.
2. Criar chamado offline com anexo.
3. Ver pendencia na tela Servicos.
4. Ver pendencia em Fila offline.
5. Sincronizar com sucesso.
6. Falha de sincronizacao por credencial/sessao.
7. Falha de sincronizacao por anexo local removido.

### Validacoes

- Testes de storage local.
- App em modo sem rede.
- GLPI web apos sincronizacao.

### Criterio de aceite

- Ticket offline nao desaparece.
- A fila explica o que esta pendente.
- Sincronizacao nao cria ticket em entidade errada.
- Falhas por item sao compreensiveis.

## Etapa 9 - Listas operacionais

### Pergunta que a etapa responde

Meus Chamados e Conversas mostram o conjunto certo de tickets, no status certo, com filtros uteis?

### Casos obrigatorios

1. Lista vazia.
2. Lista com muitos tickets.
3. Filtro por status.
4. Busca por ID.
5. Busca por texto.
6. Ticket offline misturado com online.
7. Ticket fechado com conversa historica.
8. Ticket pendente de aprovacao.

### Validacoes

- Widgetbook de lista.
- App real com filtros.
- Conferencia contra GLPI web em amostra pequena.

### Criterio de aceite

- Contadores por status batem com os tickets carregados.
- Busca nao esconde indevidamente tickets relevantes.
- Conversas nao vira duplicacao confusa de Meus Chamados.

## Etapa 10 - Endpoint externo controlado

### Pergunta que a etapa responde

O app funciona fora da intranet com endpoint estavel sem VPN por aparelho?

### Caminho preferencial

1. Cloudflare Worker em `workers.dev`.
2. Workers VPC Service para o GLPI interno.
3. Cloudflare Tunnel outbound em host institucional com acesso ao GLPI.
4. `GLPI_BASE_URL` apontando para o Worker.

### Smoke obrigatorio fora da intranet

1. `initSession`
2. login no APK
3. catalogo
4. meus chamados
5. detalhe
6. conversa
7. criacao
8. anexo

### Criterio de aceite

- Celular fora da rede interna usa somente o APK.
- Nao ha VPN por aparelho.
- Endpoint tem TLS valido e hostname estavel.
- Nenhum segredo permanente de edge fica embutido no app.

## Etapa 11 - Build, instalacao e evidencia Android

### Pergunta que a etapa responde

O APK entregue corresponde ao codigo validado e roda no Android real?

### Validacoes

1. `git status --ignored --short` antes do build.
2. Sincronizar espelho Windows quando necessario.
3. Gerar APK debug via Task Scheduler ou fluxo Android host validado.
4. Confirmar `EXIT=0`.
5. Confirmar timestamp do APK.
6. Instalar com:
   - `C:\Users\jonathan-moletta\Android\Sdk\platform-tools\adb.exe install -r "C:\Users\jonathan-moletta\build-mirrors\sis-mobile-flutter\build\app\outputs\flutter-apk\app-debug.apk"`
7. Capturar screenshots de:
   - tela Servicos autenticada
   - detalhe de ticket aberto
   - conversa
   - ticket fechado
8. `git diff --check` final.

### Criterio de aceite

- APK tem timestamp da rodada.
- App abre e autentica.
- Fluxos criticos passam no emulador e, quando aplicavel, no aparelho fisico.
- Tooling temporario e restaurado.

## Etapa 12 - Criterio de release interna

Uma build so deve ser chamada de candidata a distribuicao interna quando:

- Etapas 1 a 9 passam em WSL + Widgetbook + emulador.
- Etapa 10 passa quando o alvo for uso fora da intranet.
- Etapa 11 passa com APK final.
- Pelo menos um teste multiusuario real foi executado:
  - solicitante A
  - tecnico B
  - aprovacao/recusa por A
- Nao ha regressao conhecida em:
  - nomes versus IDs
  - status terminal
  - resumo do formulario
  - anexos
  - entidade
  - login/sessao expirada

## Checklist de cada slice

Use este checklist antes de encerrar qualquer slice:

- [ ] Li os arquivos afetados antes de editar.
- [ ] Preservei mudancas locais nao relacionadas.
- [ ] Escrevi ou atualizei teste focado.
- [ ] Rodei `flutter analyze`.
- [ ] Rodei `flutter test`.
- [ ] Rodei Widgetbook se UI mudou.
- [ ] Gerei APK se runtime Android foi afetado.
- [ ] Validei no emulador ou aparelho quando necessario.
- [ ] Registrei evidencias e pendencias reais.
- [ ] Nao toquei em secrets, keystores ou `.env` versionado.

## Registro de execucao - 2026-04-29 - Etapa 1

### Escopo executado

- Baseline de identidade visual SIS em login, Android, drawer e metadados desktop/mobile.
- Correcao do icone Android padrao Flutter para icone SIS.
- Correcao do splash Android para usar marca SIS.
- Correcao de nomes visiveis iOS, macOS e Linux para `SIS Mobile`.

### Evidencias locais

- `/tmp/sis-mobile-evidencias/login.png`
- `/tmp/sis-mobile-evidencias/after-login.png`
- `/tmp/sis-mobile-evidencias/drawer.png`

### Validacoes executadas

- `/opt/flutter/bin/flutter analyze`
- `/opt/flutter/bin/flutter test`
- `cd widgetbook && /opt/flutter/bin/flutter analyze`
- `cd widgetbook && /opt/flutter/bin/flutter test`
- Build Android debug via Task Scheduler no host Windows.
- Instalacao no emulador `emulator-5554`.
- Login real no APK instalado e captura da tela `Servicos` com entidade `PIRATINI`.
- Captura do drawer com cabecalho `SIS Mobile`.

### Resultado

- Nenhum logo DTIC aparece como marca principal nas superficies validadas.
- `assets/images/logo2.png` foi identificado como asset DTIC, mas permanece fora do `pubspec.yaml` e sem referencia no app.
- APK debug gerado em `C:\Users\jonathan-moletta\build-mirrors\sis-mobile-flutter\build\app\outputs\flutter-apk\app-debug.apk`.

## Registro de execucao - 2026-04-29 - Etapa 2

### Escopo executado

- Matriz de identidade GLPI focada em `Solicitante`, `Tecnico Responsavel`, autores de mensagens, autores de solucao e uploaders de anexos.
- Correcao de fallback para impedir exibicao de ID numerico cru como nome.
- Hidratacao do uploader de documentos via `User/{id}` antes de montar itens de conversa.
- Preservacao do ID GLPI apenas para politica interna de papel/autor, sem usa-lo como texto principal quando o nome foi resolvido.

### Evidencias locais

- `/tmp/sis-mobile-evidencias-etapa2/09-after-fix-ticket-detail-metadata.png`
- `/tmp/sis-mobile-evidencias-etapa2/08-after-fix-conversation.png`
- `/tmp/sis-mobile-evidencias-etapa2/ui-after-fix-ticket-detail-metadata-summary.txt`
- `/tmp/sis-mobile-evidencias-etapa2/ui-after-fix-conversation-summary.txt`

### Validacoes executadas

- `/opt/flutter/bin/flutter analyze`
- `/opt/flutter/bin/flutter test`
- `cd widgetbook && /opt/flutter/bin/flutter analyze`
- `cd widgetbook && /opt/flutter/bin/flutter test`
- Build Android debug via Task Scheduler no host Windows, com `android-build-task.cmd` restaurado ao SHA original.
- Instalacao no emulador `emulator-5554`.
- Smoke manual no ticket real `8595`, validando detalhe e conversa.
- Varredura da UI do detalhe e da conversa contra `2039`, `Usuario <id>`, `Tecnico <id>`, `Helpdesk`, `Resumo do Formulario` cru e separadores de payload.

### Resultado

- `Solicitante` e `Tecnico Responsavel` aparecem como `Jonathan Nascimento Moletta` no detalhe do ticket real `8595`.
- O resumo do formulario aparece estruturado por campos humanos, sem payload cru ou separadores internos.
- O anexo na conversa passou de fallback `Usuario 2039` para `Jonathan Nascimento Moletta`.
- Nao foram encontrados IDs numericos crus nas superficies validadas por UI tree.
- APK debug gerado em `C:\Users\jonathan-moletta\build-mirrors\sis-mobile-flutter\build\app\outputs\flutter-apk\app-debug.apk`.

### Pendencias reais

- Ainda falta montar fixtures ou massa GLPI real para executar manualmente todos os seis casos obrigatorios da matriz, especialmente solicitante e tecnico diferentes.
- O GLPI ainda pode retornar login textual em algumas superficies de solucao, por exemplo `jonathan-moletta`; isso nao e ID numerico, mas deve ser padronizado para nome completo quando houver API confiavel para resolver login.

## Proxima sequencia recomendada

1. Baseline visual SIS/DTIC.
2. Testes automatizados de identidade GLPI com fixtures.
3. Testes automatizados da maquina de estados e papeis.
4. Roteiro multiusuario real no GLPI.
5. Cobertura de anexos e offline.
6. Estabilizacao do endpoint externo controlado.
7. Build candidata para teste fisico ampliado.
