# Relatorio SIS Mobile - E2E mutavel controlado com ticket sintetico

Data: 2026-05-18
Host: CC-PC-WS1655947
Repo: `/home/jonathan/projects/work/mobile/sis-mobile-flutter`
Branch: `main`
Path class: WSL ext4, raiz canonica em `/home/jonathan/projects`

## 1. Escopo autorizado

Validacao E2E controlada do SIS Mobile usando somente um ticket sintetico aprovado, sem usar chamados historicos ou operacionais como massa de teste.

Ticket alvo:

```text
ID: 8963
Titulo: [HERMES-E2E-NAO-APAGAR] 20260518-0650 sis-mobile-e2e-controlado
Contexto GLPI: SIS
Entidade: Origem > PIRATINI
Prefixo de seguranca: [HERMES-E2E-NAO-APAGAR]
```

Regra aplicada antes de cada mutacao:

1. reconsultar `/Ticket/8963`;
2. confirmar `id == 8963`;
3. confirmar titulo com prefixo `[HERMES-E2E-NAO-APAGAR]`;
4. confirmar `is_deleted == 0`;
5. abortar se qualquer predicado falhar.

## 2. Acoes executadas

| Ordem | Acao | Endpoint/API | Resultado |
| --- | --- | --- | --- |
| 1 | Confirmacao read-only do alvo | `GET /Ticket/8963` | OK, prefixo sintetico confirmado |
| 2 | Solucao 1 | `POST /ITILSolution` | Criada, ID 7404 |
| 3 | Recusa da solucao 1 | `PUT /ITILSolution/7404` | OK |
| 4 | Reabertura apos recusa | `PUT /Ticket/8963 status=1` | OK, voltou para Novo |
| 5 | Followup de justificativa | `POST /TicketFollowup tickets_id=8963` | Criado, ID 11624 |
| 6 | Status em atendimento | `PUT /Ticket/8963 status=2` | OK |
| 7 | Solucao 2 | `POST /ITILSolution` | Criada, ID 7405 |
| 8 | Aprovacao/validacao controlada da solucao 2 | `PUT /ITILSolution/7405` | OK em nivel de chamada GLPI |
| 9 | Fechamento inicial | `PUT /Ticket/8963 status=6` | OK |
| 10 | Reabertura temporaria para validacao visual Android | `PUT /Ticket/8963 status=1` | OK |
| 11 | Followup visual Android | `POST /TicketFollowup tickets_id=8963` | Criado, ID 11625 |
| 12 | Fechamento final | `PUT /Ticket/8963 status=6` | OK |

Nenhum `DELETE`, purge ou cleanup GLPI foi executado.

## 3. Resultado final read-only no GLPI

Fonte: `/home/jonathan/.brain/evidence/sis-mobile/e2e-mutable-8963-20260518/final-readonly-proof.json`

```json
{
  "ticket_id": 8963,
  "name": "[HERMES-E2E-NAO-APAGAR] 20260518-0650 sis-mobile-e2e-controlado",
  "status": 6,
  "is_deleted": 0,
  "closedate": "2026-05-18 07:16:08",
  "safe_prefix_ok": true,
  "followups": 3,
  "solutions": 2,
  "documents": 1,
  "kill_status": 200
}
```

## 4. Validacao Android

APK validado:

```text
SIS APK: C:\Users\jonathan-moletta\ops\sis-mobile\sis-mobile-release-worker-status-rules-public-20260518.apk
SHA256: 8d5c2a3fc00d0ac11b8eb79830d23bbe58b0c9ce23c7f2fe6bada98af8c0448f
Runtime URL embutida: https://sis-glpi.jonathan-sis-mobile-20260518.workers.dev/sis/apirest.php
```

Ambiente Android:

```text
AVD: hermes_sis_mobile_api35
Serial: emulator-5554
Android: 15
Tela: 1080x2400
```

Fluxo visual confirmado:

| Superficie | Evidencia | Resultado |
| --- | --- | --- |
| Login SIS | `android-auth/01-after-login.png` | Login concluido, tela Servicos carregada |
| Meus Chamados | `android-auth/02-my-tickets-opened.png` | Contagens por status exibidas |
| Detalhe do ticket reaberto | `android-auth/08-target-detail-after-reopen.png` | `Chamado 8963`, titulo sintetico, status `Novo`, botao `Abrir conversa` |
| Conversa aberta | `android-auth/10-conversation-screen-after-button.png` | Historico/followups/solucao/anexo visiveis e composer disponivel |
| Conversa apos fechamento final | `android-auth/11-conversation-after-final-close-refresh.png` | Historico permanece visivel e composer desaparece |

Resultado de bloqueio em fechado:

```text
Chamado fechado. Novas interacoes desabilitadas.
```

Logcat capturado nao apresentou:

```text
FATAL EXCEPTION
Force finishing
Fatal signal
```

## 5. Anexos

A validacao visual confirmou um anexo ja vinculado ao ticket sintetico:

```text
hermes-e2e-8963-evidencia.txt
```

A tentativa de novo upload pelo Worker SIS foi bloqueada pela allowlist:

```text
POST /Document => {"error":"Endpoint blocked by SIS Worker allowlist."}
```

Decisao: nao foi feito bypass. Para validar novo upload futuro via app/API, liberar explicitamente rota segura no Worker ou usar endpoint direto comprovadamente vinculado ao item, com novo gate humano.

## 6. Provas de isolamento

Provas aplicadas:

- todos os endpoints mutaveis usaram ID 8963 ou filhos diretos do ticket 8963;
- cada mutacao foi cercada por leitura de `/Ticket/8963`;
- prefixo sintetico foi validado antes/depois;
- `is_deleted` permaneceu `0`;
- nenhuma limpeza automatizada foi executada;
- ticket foi deixado como evidencia.

Arquivos de prova:

```text
/home/jonathan/.brain/evidence/sis-mobile/e2e-mutable-8963-20260518/phase2-solution-status-summary.json
/home/jonathan/.brain/evidence/sis-mobile/e2e-mutable-8963-20260518/attachment-summary.json
/home/jonathan/.brain/evidence/sis-mobile/e2e-mutable-8963-20260518/android-visual-reopen-summary.json
/home/jonathan/.brain/evidence/sis-mobile/e2e-mutable-8963-20260518/final-close-summary.json
/home/jonathan/.brain/evidence/sis-mobile/e2e-mutable-8963-20260518/final-readonly-proof.json
```

## 7. Limpeza local e seguranca de evidencias

Final da execucao:

```text
adb devices => vazio
qemu-system => nenhum processo ativo
/dev/kvm => 660 root kvm
App SIS local => limpo com pm clear
Sessao API => encerrada com killSession
```

Varredura de evidencias:

```json
{
  "checked_files": 44,
  "secret_string_findings": []
}
```

Durante automacao de login houve uma tentativa inicial que poderia preservar entrada sensivel em screenshot/XML. Esse diretorio foi removido e a varredura final confirmou ausencia das strings sensiveis conhecidas nos artefatos mantidos.

## 8. Divergencias/achados

### 8.1 Worker SIS bloqueia upload novo por `/Document`

O Worker SIS bloqueou `POST /Document`, o que e seguro por default. A validacao visual de anexo passou porque o ticket possuia documento vinculado, mas upload novo pelo app ainda exige gate especifico.

### 8.2 `ITILSolution.status` pode ficar historico apos reabertura/fechamento

Depois de recusa, reabertura e fechamento final no mesmo ticket, o estado operacional confiavel para a UI foi `Ticket.status`. As linhas de `ITILSolution` podem refletir artefatos historicos de solucao/reabertura e nao devem ser usadas isoladamente como verdade do fluxo de tela.

Regra recomendada:

- lista/detalhe/composer: usar `Ticket.status` fresco;
- timeline: exibir solucoes como historico;
- validacao de aprovar/recusar: permitir somente quando `Ticket.status == 5` e papel for solicitante valido.

## 9. Conclusao

A validacao E2E mutavel controlada passou.

O SIS Mobile convergiu corretamente entre GLPI e app para o ticket sintetico 8963:

- lista encontrou o ticket em `Novo` apos reabertura controlada;
- detalhe mostrou ID, titulo, status e anexos;
- conversa mostrou followups, anexo e solucao;
- em estado aberto, composer ficou disponivel;
- apos fechamento final, historico permaneceu visivel e novas interacoes foram bloqueadas.

Nenhum ticket real ou historico foi usado como massa de teste mutavel.

## 10. Proximos gates recomendados

Antes de nova execucao pratica:

1. se o objetivo for upload novo, aprovar explicitamente a rota segura de anexo no Worker SIS;
2. se o objetivo for validar aprovacao/recusa por papeis distintos, aprovar usuario/conta de teste diferente do tecnico atual;
3. se o objetivo for offline sync, usar no maximo um segundo ticket sintetico ou reabrir o mesmo ticket somente se o fluxo offline suportar repeticao segura;
4. manter proibicao de DELETE/purge/cleanup;
5. manter ticket 8963 como evidencia, salvo ordem explicita em contrario.
