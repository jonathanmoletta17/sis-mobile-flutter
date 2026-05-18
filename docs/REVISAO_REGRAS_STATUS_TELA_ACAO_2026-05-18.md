# Revisao de regras status x tela x acao - SIS Mobile

Data: 2026-05-18
Escopo: regra local do app Flutter. Nenhuma validacao mutavel contra GLPI real foi executada.

## Decisao operacional

Conversa/historico nao e a mesma coisa que mutacao.

- Tickets sincronizados em qualquer status GLPI canonico (`1..6`) podem abrir a tela de conversa para leitura.
- O status controla o composer e as acoes dentro da conversa.
- Ticket offline nao abre conversa remota ate sincronizar.

## Matriz atual implementada

| Status | Abrir conversa | Ver historico | Enviar mensagem/anexo comum | Propor solucao | Aprovar/recusar solucao | Acoes tecnicas de status |
| --- | --- | --- | --- | --- | --- | --- |
| Novo | sim | sim | sim | tecnico | nao | tecnico |
| Em Atendimento | sim | sim | sim | tecnico | nao | tecnico |
| Planejado | sim | sim | sim | tecnico | nao | tecnico |
| Pendente | sim | sim | sim | tecnico | nao | tecnico |
| Solucionado | sim | sim | nao | nao | solicitante valido, exceto autor da propria solucao | nao |
| Fechado | sim | sim | nao | nao | nao | nao |
| Pendente Offline | nao remoto | local | nao GLPI | nao | nao | nao |

## Papel

- Solicitante prevalece sobre perfil tecnico global no proprio chamado.
- Tecnico-solicitante e tratado como solicitante naquele ticket.
- Perfil requester/self-service/post-only nao recebe acoes tecnicas.
- Sessao invalida continua bloqueada pelos guards de AppState/API.

## Arquivos alterados

- `lib/state/app_state_ticket_support.dart`
  - adiciona policy central: `canOpenConversation`, `canSendCommonInteraction`, `canProposeSolution`, `canValidateSolutionForTicket`.
- `lib/screens/ticket_detail_screen.dart`
  - `Abrir conversa` usa policy central; offline mostra bloqueio ate sincronizar.
- `lib/screens/ticket_message_screen.dart`
  - recebe `ticketStatus` do detalhe;
  - refresh remoto atualiza status local da tela;
  - composer bloqueia `Solucionado` e `Fechado`;
  - validacao de solucao usa policy central.
- `test/ticket_status_action_matrix_test.dart`
  - cobre matriz status x acao x papel.

## Evidencia de validacao

Executado localmente em WSL, sem GLPI mutavel:

```text
flutter test test/ticket_status_action_matrix_test.dart
=> 5 passed

flutter analyze
=> No issues found

flutter test
=> 74 passed

flutter test test/dtic_formcreator_models_test.dart
=> 13 passed

cd widgetbook && flutter test test/dtic_app_surfaces_preview_test.dart test/dtic_formcreator_surface_preview_test.dart
=> 8 passed

flutter build apk --release --flavor sis -t lib/main.dart
=> build/app/outputs/flutter-apk/app-sis-release.apk, 56.563.500 bytes, sha256 7ed98708772bf72426ab44bd1d373879bb5e42ee66d498ea62496601ca0d9ebe

flutter build apk --release --flavor dtic -t lib/main.dart
=> build/app/outputs/flutter-apk/app-dtic-release.apk, 56.540.252 bytes, sha256 ff8af614f5b7ea76013e94bd959b6b92e63710d1a38fb2de9b1b5e047637e22b
```

Copias Windows iniciais:

```text
C:\Users\jonathan-moletta\ops\sis-mobile\sis-mobile-release-worker-status-rules-20260518.apk
C:\Users\jonathan-moletta\ops\dtic-mobile\dtic-mobile-release-worker-status-rules-20260518.apk
```

## Evidencia adicional - build publico corrigido

Durante a validacao de instalacao foi identificado que os APKs iniciais ainda carregavam `.env` operacional antigo:

- SIS apontava para `http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php`, inadequado para celular fora da rede/VPN.
- DTIC apontava para Worker antigo `sis-mobile-ppiratini-20260428`.

Foram gerados novos APKs com `.env.public` / `.env.public.dtic`, sem secrets embutidos:

```text
C:\Users\jonathan-moletta\ops\sis-mobile\sis-mobile-release-worker-status-rules-public-20260518.apk
sha256 8d5c2a3fc00d0ac11b8eb79830d23bbe58b0c9ce23c7f2fe6bada98af8c0448f
assets/flutter_assets/.env:
GLPI_BASE_URL=https://sis-glpi.jonathan-sis-mobile-20260518.workers.dev/sis/apirest.php
GLPI_DEBUG_LOGS=false

C:\Users\jonathan-moletta\ops\dtic-mobile\dtic-mobile-release-worker-status-rules-public-20260518.apk
sha256 8c07c7fc124cc1267b938057396f48b3b34bf90cea2e843171f62885e202daf4
assets/flutter_assets/.env:
DTIC_GLPI_BASE_URL=https://dtic-glpi.jonathan-sis-mobile-20260518.workers.dev/glpi/apirest.php
GLPI_DEBUG_LOGS=false
DTIC_ENABLE_FORM_SUBMISSION=false
DTIC_ENABLE_TICKET_ACTIONS=false
```

Validacoes read-only/nao-mutaveis dos Workers publicos em 2026-05-18:

```text
GET  https://sis-glpi.jonathan-sis-mobile-20260518.workers.dev/healthz  => HTTP 200
DELETE /sis/apirest.php/Ticket/1                                       => HTTP 403 allowlist

GET  https://dtic-glpi.jonathan-sis-mobile-20260518.workers.dev/healthz => HTTP 200
DELETE /glpi/apirest.php/Ticket/1                                      => HTTP 403 allowlist
```

Validacao Android no emulador local:

```text
KVM: /dev/kvm liberado temporariamente com chmod o+rw apos aprovacao humana.
AVD: hermes_sis_mobile_api35
Device: emulator-5554, Android 15, 1080x2400
adb install SIS => Success
adb install DTIC => Success
pm list packages => br.gov.rs.casacivil.sismobile, br.gov.rs.casacivil.dticmobile
```

Evidencias capturadas:

```text
/home/jonathan/.brain/evidence/sis-mobile/sis-login-android-20260518.png
/home/jonathan/.brain/evidence/sis-mobile/dtic-login-android-20260518.png
/home/jonathan/.brain/evidence/sis-mobile/sis-empty-login-validation-20260518.png
/home/jonathan/.brain/evidence/sis-mobile/dtic-empty-login-validation-20260518.png
/home/jonathan/.brain/evidence/sis-mobile/sis-package-dumpsys-20260518.txt
/home/jonathan/.brain/evidence/sis-mobile/dtic-package-dumpsys-20260518.txt
```

Resultado visual Android:

- SIS abre na tela `GLPI SIS`, com usuario, senha e botao `Entrar`.
- DTIC abre na tela `GLPI DTIC`, com usuario, senha, botao `Entrar` e toggle visual de senha.
- Submissao vazia em SIS mostra validacao local: `O nome de usuario e obrigatorio` e `A senha e obrigatoria`.
- Submissao vazia em DTIC mostra validacao local: `Informe o usuario.` e `Informe a senha.`.
- Nao houve login, credencial, initSession, ticket, followup, anexo, status, solucao, DELETE, purge ou cleanup.
- Logcat filtrado nao mostrou `FATAL EXCEPTION`, `Force finishing` ou crash relacionado aos pacotes `br.gov.rs.casacivil.*mobile`.

Hardening posterior executado:

```text
tool/android/readonly_smoke_android.sh
```

O script reproduz automaticamente o smoke Android read-only, valida APKs, sobe AVD headless, instala SIS/DTIC, captura telas de login e validacao local, coleta dumpsys/logcat, restaura KVM e encerra o emulador. Procedimento documentado em:

```text
docs/ANDROID_READONLY_SMOKE.md
```

Execucao de prova:

```text
/home/jonathan/.brain/evidence/sis-mobile/android-smoke-20260518-061923/summary.txt
=> READ-ONLY ANDROID SMOKE PASSED
```

A validacao visual web local tambem chegou na tela de login `GLPI SIS`, mas nao avancou porque isso exigiria credenciais GLPI e sessao real.

Validacao autenticada read-only SIS executada apos aprovacao explicita do usuario:

```text
API Worker SIS:
POST /initSession => 200, session_token presente
GET /getFullSession => 200
GET /killSession => 200
```

Validacao Android autenticada read-only:

```text
Evidencias: /home/jonathan/.brain/evidence/sis-mobile/auth-ui-20260518-0640/
App: br.gov.rs.casacivil.sismobile
Credenciais: nao registradas no relatorio, nao persistidas em arquivo de codigo
Mutacoes GLPI: nenhuma
```

Fluxos validados visualmente:

- login SIS com credencial autorizada;
- tela `Servicos` carregada;
- entidade exibida inicialmente como `PIRATINI` apos login;
- `Meus Chamados` carregou contagens por estado: Novo, Em Atendimento, Planejado, Pendente, Solucionado, Fechado;
- secao `Em Atendimento` expandiu e listou tickets;
- detalhe do ticket ID 8595 abriu em modo read-only;
- botao `Abrir conversa` apareceu para ticket `Em Atendimento`;
- conversa do ticket ID 8595 abriu;
- composer de mensagem e botao de anexo/envio apareceram para `Em Atendimento`;
- aba `Conversas` carregou lista de conversas/atividades recentes;
- nenhum followup, anexo, status, solucao, aprovacao, recusa, fechamento, DELETE, purge ou cleanup foi executado;
- tentativa de logout visual nao retornou para tela de login de forma conclusiva; foi feita limpeza local do app (`pm clear`) e encerramento do emulador. A sessao API usada para preflight foi encerrada com `killSession`.

Evidencias principais:

```text
01-login-before.png
03-after-submit.png removido por conter tentativa de digitacao falha; nao preservar screenshots com credenciais.
after-login-success.png
04-my-tickets.png
05-em-atendimento-expanded.png
06-ticket-detail-attempt.png
07-conversation-em-atendimento.png
12-conversas-tab.png
14-after-logout.png
15-cleanup-summary.json
```

Observacao de seguranca: uma tentativa automatizada inicial digitou o texto no campo incorreto; o diretorio de evidencia dessa tentativa foi removido imediatamente e os arquivos textuais restantes foram varridos/redigidos para nao persistir credenciais.

## Resultado do caso reportado

Para ticket existente com status `Em Atendimento`:

- `Abrir conversa`: deve estar disponivel.
- Composer de mensagem/anexo: deve estar disponivel.
- Opcao de solucionar: apenas tecnico que nao seja solicitante do proprio chamado.
- Se nao aparecer no celular depois de novo APK, suspeitas restantes sao build velho, status remoto divergente, perfil/sessao, ou falha runtime na tela.

## Limites da validacao read-only inicial

A secao anterior descreve a validacao autenticada read-only inicial. Naquele momento:

- Nao foi criado ticket.
- Nao foi enviado followup.
- Nao foi anexado arquivo.
- Nao foi alterado status.
- Nao foi aprovada/recusada solucao.
- Nao foi executado DELETE/purge/cleanup.

## Validacao E2E mutavel controlada posterior

Apos aprovacao explicita do usuario para usar somente um ticket sintetico, foi executado um E2E controlado no SIS Mobile com o ticket:

```text
ID: 8963
Titulo: [HERMES-E2E-NAO-APAGAR] 20260518-0650 sis-mobile-e2e-controlado
Contexto: GLPI SIS
```

Regras aplicadas antes de cada mutacao:

- reconsultar `/Ticket/8963`;
- confirmar ID exato `8963`;
- confirmar prefixo `[HERMES-E2E-NAO-APAGAR]` no titulo;
- confirmar `is_deleted == 0`;
- abortar em qualquer divergencia.

Fluxos cobertos:

- followup;
- solucao;
- recusa de solucao;
- reabertura;
- novo followup;
- fechamento;
- detalhe Android;
- conversa Android;
- anexo ja vinculado exibido no detalhe/conversa;
- bloqueio de novas interacoes em `Fechado`.

Resultado visual importante:

- `Novo`: detalhe do ticket 8963 mostrou botao `Abrir conversa`.
- Conversa aberta: historico/followups/solucao/anexo visiveis e composer disponivel.
- `Fechado`: historico permaneceu visivel e o composer desapareceu, com aviso `Chamado fechado. Novas interacoes desabilitadas.`

Evidencias:

```text
/home/jonathan/.brain/evidence/sis-mobile/e2e-mutable-8963-20260518/final-readonly-proof.json
/home/jonathan/.brain/evidence/sis-mobile/e2e-mutable-8963-20260518/android-auth/08-target-detail-after-reopen.png
/home/jonathan/.brain/evidence/sis-mobile/e2e-mutable-8963-20260518/android-auth/10-conversation-screen-after-button.png
/home/jonathan/.brain/evidence/sis-mobile/e2e-mutable-8963-20260518/android-auth/11-conversation-after-final-close-refresh.png
```

Relatorio completo:

```text
docs/RELATORIO_SIS_MOBILE_E2E_MUTAVEL_CONTROLADO_2026-05-18.md
```

Achados:

- Worker SIS bloqueou `POST /Document` por allowlist, o que e seguro por default; novo upload de anexo exige gate especifico.
- `Ticket.status` deve continuar sendo a verdade operacional para lista/detalhe/composer. Linhas de `ITILSolution` podem representar historico apos reabertura/fechamento no mesmo ticket.
- Nenhum `DELETE`, purge ou cleanup GLPI foi executado.
