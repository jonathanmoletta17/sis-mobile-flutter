# Plano DTIC Mobile — reaproveitamento controlado do trabalho do SIS Mobile

Data: 2026-05-18
Host: CC-PC-WS1655947
Repo: `/home/jonathan/projects/work/mobile/sis-mobile-flutter`
Branch: `main`
Path class: WSL ext4 canonical source root

## 1. Objetivo

Estruturar uma frente de estudo e validação do DTIC Mobile reaproveitando o que já foi provado no SIS Mobile, sem assumir que as regras de negócio são idênticas e sem executar mutações em GLPI real nesta fase.

Objetivo prático futuro:

- publicar/validar acesso externo DTIC por Cloudflare Workers VPC;
- gerar APK DTIC com endpoint externo;
- validar login, catálogo FormCreator, meus chamados, detalhe, conversa, anexos, solução/status e bloqueios;
- fazer qualquer mutação somente depois de aprovação explícita, usando no máximo 1 ou 2 tickets sintéticos DTIC.

## 2. Princípio de segurança

Tudo começa em modo read-only.

Proibido nesta fase:

- criar chamado DTIC real;
- enviar followup em chamado real;
- anexar arquivo em chamado real;
- propor solução em chamado real;
- alterar status em chamado real;
- aprovar/recusar solução em chamado real;
- usar tickets históricos como massa de teste;
- executar DELETE, purge, cleanup ou qualquer limpeza automatizada;
- imprimir `.env`, App-Token, Session-Token, senha, keystore ou credenciais.

Qualquer teste mutável futuro deve usar prefixo inequívoco:

`[HERMES-E2E-DTIC-NAO-APAGAR] <timestamp> <objetivo>`

## 3. O que já aprendemos com SIS Mobile e deve ser reaproveitado

| Aprendizado SIS | Aplicação no DTIC |
|---|---|
| Worker público não pode ser pass-through irrestrito | DTIC Worker precisa allowlist, flags e bloqueios explícitos |
| `DELETE`, purge e cleanup devem ser bloqueados na borda | manter bloqueio permanente no Worker DTIC |
| `/healthz` deve responder sem tocar no GLPI | manter como primeiro smoke externo |
| VPC/Tunnel/Worker precisam estar na mesma conta Cloudflare | verificar `account_id`, `service_id`, tunnel e permissões antes de deploy |
| API token pode não ter permissão Workers VPC | preferir `wrangler login` OAuth se binding falhar |
| TLS de `workers.dev` pode demorar alguns minutos | poll de `/healthz` antes de diagnosticar falso erro |
| APK deve embutir `.env.public` não secreto | criar `.env.public.dtic` ou equivalente com `DTIC_GLPI_BASE_URL` |
| Validar APK por `unzip`, `sha256`, `apksigner`, `aapt` | repetir para flavor `dtic` |
| Anexos no GLPI exigem prova via `Document_Item` + `Document` | repetir validação no GLPI DTIC; não confiar só em HTTP 200 |
| Ticket sintético deve ser reconsultado antes de cada mutação | regra obrigatória no plano DTIC E2E |

## 4. Fatos confirmados no código DTIC

### 4.1 Estrutura DTIC no mesmo workspace

Arquivos principais confirmados:

- `lib/main_dtic.dart`
- `lib/dtic/dtic_app.dart`
- `lib/dtic/config/dtic_config.dart`
- `lib/dtic/services/dtic_glpi_client.dart`
- `lib/dtic/state/dtic_app_state.dart`
- `lib/dtic/state/dtic_app_state_storage.dart`
- `lib/dtic/models/dtic_ticket_models.dart`
- `lib/dtic/models/dtic_formcreator_models.dart`
- `lib/dtic/screens/dtic_login_screen.dart`
- `lib/dtic/screens/dtic_catalog_screen.dart`
- `lib/dtic/screens/dtic_dynamic_form_screen.dart`
- `lib/dtic/screens/dtic_my_tickets_screen.dart`
- `lib/dtic/screens/dtic_ticket_detail_screen.dart`
- `lib/dtic/screens/dtic_chat_overview_screen.dart`

### 4.2 Configuração de endpoint

`DticConfig.baseUrl` usa:

1. `DTIC_GLPI_BASE_URL`
2. fallback `GLPI_BASE_URL`

O código rejeita endpoint SIS no app DTIC:

- bloqueia `sis-glpi`;
- bloqueia `/sis/apirest.php`;
- bloqueia `cau.ppiratini.intra.rs.gov.br/sis`.

Também alerta se DTIC apontar direto para GLPI interno `/glpi/apirest.php`, recomendando Worker DTIC para uso externo.

### 4.3 Feature flags mutáveis

Por padrão, ações mutáveis DTIC ficam desligadas:

- `DTIC_ENABLE_FORM_SUBMISSION=false` por default;
- `DTIC_ENABLE_TICKET_ACTIONS=false` por default.

Isso é bom: permite APK read-only/consulta antes de liberar criação/ações.

### 4.4 Autenticação e sessão

`DticGlpiClient` implementa:

- `POST /initSession`;
- `GET /killSession`;
- `GET /getFullSession`;
- hidratação local via `hydrateSession`;
- limpeza local via `clearSession`.

`DticAppState` implementa:

- `restoreSession()`;
- `authenticate()`;
- `logout()`;
- persistência via `DticAppStateStorage`.

### 4.5 Catálogo FormCreator

`fetchFormCatalog()` lê, de forma read-only:

- `PluginFormcreatorForm`;
- `PluginFormcreatorCategory`;
- `PluginFormcreatorSection`;
- `PluginFormcreatorQuestion`;
- `PluginFormcreatorTargetTicket`;
- `PluginFormcreatorCondition`.

Fluxo mutável de formulário deve ser tratado separadamente, provavelmente via `PluginFormcreatorFormAnswer`.

### 4.6 Tickets e conversa

Read-only confirmado:

- listagem por `/search/Ticket` filtrando requerente;
- detalhe por `/Ticket/{id}?expand_dropdowns=true`;
- followups por `/Ticket/{id}/TicketFollowup`;
- soluções por `/Ticket/{id}/ITILSolution`;
- documentos por `/Document_Item`, `/ITILFollowup/{id}/Document_Item`, `/ITILSolution/{id}/Document_Item` e `/Document/{id}`.

Mutável confirmado:

- `POST /TicketFollowup`;
- `POST /ITILSolution`;
- `PUT /Ticket/{id}`;
- `PUT /ITILSolution/{id}`;
- upload por endpoints de `Document`/`Document_Item` e item-specific `/{Ticket|ITILFollowup|ITILSolution}/{id}/Document`.

### 4.7 Guards já existentes

`DticAppState._guardedTicketAction()` reconsulta detalhe do ticket antes de executar ação e bloqueia se status não estiver aberto para interação.

Limite atual: o guard valida status, mas ainda precisa ser complementado para E2E automatizado com prova de ticket sintético antes de qualquer mutação prática.

### 4.8 Worker DTIC já existe

Arquivos:

- `tool/external-access/workers-vpc-dtic/src/index.js`
- `tool/external-access/workers-vpc-dtic/wrangler.jsonc`

Config atual do Worker DTIC:

- Worker name: `dtic-glpi`;
- origin interno: `http://10.72.30.39`;
- API prefix: `/glpi/apirest.php`;
- `workers_dev=true`;
- `ALLOW_TICKET_ACTIONS=false`;
- `ALLOW_FORMCREATOR_SUBMISSION=false`;
- VPC service atual: `019e2016-2a46-7923-966c-84a6cd95ce94`.

Atenção: antes de deploy real, confirmar se esse `service_id` pertence à conta Cloudflare correta e se aponta para DTIC `/glpi`, não SIS `/sis`.

### 4.9 Testes e superfícies visuais DTIC

Teste unitário encontrado:

- `test/dtic_formcreator_models_test.dart`

Widgetbook/visual surfaces existentes:

- `widgetbook/lib/previews/dtic_app_surfaces_preview.dart`
- `widgetbook/lib/previews/dtic_formcreator_surface_preview.dart`
- `widgetbook/test/dtic_app_surfaces_preview_test.dart`
- `widgetbook/test/dtic_formcreator_surface_preview_test.dart`
- goldens DTIC para login, catálogo, FormCreator, tickets, detalhe e conversas.

Lacuna inicial: há menos testes DTIC de regras de estado/ação do que foi criado/validado no SIS.

## 5. Diferenças SIS vs DTIC que não podemos ignorar

| Tema | SIS Mobile | DTIC Mobile |
|---|---|---|
| API path | `/sis/apirest.php` | `/glpi/apirest.php` |
| Config base | `GLPI_BASE_URL` | `DTIC_GLPI_BASE_URL` com fallback `GLPI_BASE_URL` |
| Catálogo | serviços SIS | FormCreator DTIC |
| Criação | fluxo de ticket/catálogo SIS | provável `PluginFormcreatorFormAnswer` |
| Flags mutáveis | dependem do build/Worker SIS | `DTIC_ENABLE_FORM_SUBMISSION`, `DTIC_ENABLE_TICKET_ACTIONS`, `ALLOW_*` no Worker |
| Worker | `sis-glpi` | `dtic-glpi` |
| Risco principal | tickets SIS operacionais | tickets CAU/DTIC suporte TI, com usuários reais e técnicos reais |

Conclusão: aproveitar infraestrutura, gates e metodologia; não copiar fluxos de negócio cegamente.

## 6. Plano por fases

### Fase 0 — Preparação read-only

Objetivo: congelar escopo e impedir mutação acidental.

Tarefas:

1. Confirmar que nenhum teste prático DTIC mutável será executado.
2. Registrar arquivos DTIC relevantes.
3. Confirmar endpoint DTIC esperado: Worker público apontando para `/glpi/apirest.php`.
4. Confirmar que `.env`, tokens e secrets não serão lidos/impressos.
5. Confirmar que `DTIC_ENABLE_FORM_SUBMISSION=false` e `DTIC_ENABLE_TICKET_ACTIONS=false` no primeiro APK externo.

Saída esperada:

- relatório de escopo;
- matriz inicial de read-only/mutável;
- lista de pendências.

### Fase 1 — Discovery profundo DTIC

Ler e confrontar:

- `README.md`, `HERMES.md`, `AGENTS.md`, `BOOTSTRAP.md`;
- docs existentes de runtime/validação mobile;
- todos os arquivos `lib/dtic/**`;
- worker DTIC;
- testes `test/*dtic*`;
- Widgetbook DTIC;
- `android/app/build.gradle.kts` para flavor DTIC.

Mapear:

- arquitetura Flutter DTIC;
- entrypoint `lib/main_dtic.dart`;
- flavor Android `dtic`;
- storage local;
- sessão/hidratação/logout;
- catálogo FormCreator;
- submissão de formulário;
- listagem de chamados;
- detalhe/conversa/anexos/soluções;
- estados GLPI e permissões;
- diferenças com SIS.

Saída esperada:

- fatos por arquivo;
- inferências;
- divergências docs vs código;
- lacunas de teste.

### Fase 2 — Matriz de endpoints DTIC

Classificar cada endpoint usado pelo app:

| Endpoint | Método | Uso | Classe | Flag/Gate |
|---|---:|---|---|---|
| `/initSession` | POST | login | auth | read-only operacional |
| `/getFullSession` | GET | contexto sessão | read-only | sempre permitido |
| `/killSession` | GET | logout | sessão | permitido |
| `/PluginFormcreator*` | GET | catálogo | read-only | permitido |
| `/search/Ticket` | GET | meus chamados | read-only | permitido |
| `/Ticket/{id}` | GET | detalhe | read-only | permitido |
| `/Ticket/{id}/TicketFollowup` | GET | conversa | read-only | permitido |
| `/Ticket/{id}/ITILSolution` | GET | soluções | read-only | permitido |
| `/Document_Item` | GET | vínculos de anexo | read-only | permitido |
| `/Document/{id}` | GET | detalhe/download | read-only | permitido |
| `/PluginFormcreatorFormAnswer` | POST | criação via formulário | mutável | `DTIC_ENABLE_FORM_SUBMISSION` + aprovação |
| `/TicketFollowup` | POST | mensagem | mutável | `DTIC_ENABLE_TICKET_ACTIONS` + ticket sintético |
| `/ITILSolution` | POST | solução | mutável sensível | aprovação explícita |
| `/Ticket/{id}` | PUT | status/campos | mutável sensível | aprovação explícita |
| `/ITILSolution/{id}` | PUT | aprovar/recusar solução | mutável sensível | aprovação explícita |
| `/Document` | POST | documento standalone | risco órfão | bloquear até prova |
| `/Document_Item` | POST | vínculo manual | risco órfão | bloquear até prova |
| `DELETE *` | qualquer | delete/purge | proibido | bloquear sempre |

### Fase 3 — Worker DTIC seguro

Objetivo: deixar o Worker DTIC com a mesma maturidade do SIS, mas respeitando FormCreator.

Tarefas:

1. Revisar `tool/external-access/workers-vpc-dtic/src/index.js`.
2. Confirmar `/healthz`; se não existir, adicionar antes de deploy prático.
3. Garantir bloqueio permanente de `DELETE` e métodos desconhecidos.
4. Manter `ALLOW_TICKET_ACTIONS=false` e `ALLOW_FORMCREATOR_SUBMISSION=false` para smoke inicial.
5. Criar/rodar testes Node de allowlist DTIC.
6. Validar `wrangler deploy --dry-run`.
7. Confirmar se `service_id` `019e2016-2a46-7923-966c-84a6cd95ce94` existe na conta Cloudflare atual.
8. Deploy só depois de Gate Ambiente.

Smoke externo read-only esperado:

- `GET /healthz -> 200`;
- `DELETE /glpi/apirest.php/Ticket/1 -> 403`;
- `GET /glpi/apirest.php/ITILCategory -> ERROR_SESSION_TOKEN_MISSING` sem credenciais, provando alcance;
- com credencial autorizada e sem imprimir segredo: `initSession`, `getFullSession`, catálogo FormCreator, `killSession`.

### Fase 4 — APK DTIC read-only

Objetivo: gerar primeiro APK DTIC externo sem ações mutáveis.

Criar arquivo não secreto:

`.env.public.dtic`

Conteúdo esperado:

```env
DTIC_GLPI_BASE_URL=https://dtic-glpi.<subdomain>.workers.dev/glpi/apirest.php
GLPI_DEBUG_LOGS=false
DTIC_ENABLE_FORM_SUBMISSION=false
DTIC_ENABLE_TICKET_ACTIONS=false
```

Build esperado:

```bash
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter build apk --release --flavor dtic -t lib/main_dtic.dart
```

Validações obrigatórias:

- `sha256sum`;
- `unzip -tq`;
- `unzip -p APK assets/flutter_assets/.env` confirmando endpoint DTIC e flags false;
- `apksigner verify --verbose`;
- `aapt dump badging` confirmando package/label/flavor;
- copiar para `C:\Users\jonathan-moletta\ops\dtic-mobile\`.

### Fase 5 — Testes read-only no app

Sem mutação, validar:

1. abertura do app;
2. login;
3. restauração de sessão;
4. getFullSession;
5. entidade ativa;
6. catálogo FormCreator;
7. formulário abre, mas submissão bloqueada;
8. meus chamados;
9. detalhe de chamado próprio;
10. conversa/followups/soluções em leitura;
11. anexos em leitura/download;
12. logout/killSession;
13. comportamento com sessão expirada.

Evidências:

- screenshot ou UI tree;
- log do app/logcat quando possível;
- endpoint chamado;
- HTTP status;
- prova de que nenhuma flag mutável estava ligada.

### Fase 6 — Plano mutável DTIC com ticket sintético

Só depois de aprovação explícita.

Ticket/formulário sintético:

`[HERMES-E2E-DTIC-NAO-APAGAR] <timestamp> <objetivo>`

Estratégia com no máximo 1 ou 2 tickets:

1. Se FormCreator permitir, criar um chamado sintético via formulário de teste autorizado.
2. Registrar ID imediatamente.
3. Antes de cada mutação:
   - reconsultar `/Ticket/{id}`;
   - confirmar ID exato;
   - confirmar prefixo no título;
   - confirmar entidade;
   - confirmar que o usuário atual tem papel esperado;
   - confirmar que a ação está no escopo aprovado.
4. Reutilizar o mesmo ticket para:
   - listagem;
   - detalhe;
   - followup;
   - anexo;
   - solução;
   - status;
   - aprovação/recusa, se aplicável ao perfil;
   - bloqueios em Solucionado/Fechado.
5. Não deletar no final; deixar como evidência, salvo aprovação explícita de cleanup não-purge.

### Fase 7 — Lacunas de teste a criar antes de E2E mutável

Testes recomendados:

- `test/dtic_config_test.dart` — impede endpoint SIS em DTIC.
- `test/dtic_app_state_ticket_action_guard_test.dart` — ações bloqueadas quando flags false.
- `test/dtic_app_state_stale_ticket_guard_test.dart` — reconsulta remota antes de ação.
- `test/dtic_glpi_client_endpoint_contract_test.dart` — endpoints e payloads mutáveis isolados/mocados.
- `tool/external-access/workers-vpc-dtic/test/allowlist.test.mjs` — Worker bloqueia destrutivos e respeita flags.
- Widgetbook/goldens DTIC para estados de erro: sessão expirada, ação bloqueada, ticket fechado, formulário read-only.

### Fase 8 — Gates de aprovação

#### Gate A — Discovery DTIC concluído

- arquitetura mapeada;
- endpoints classificados;
- Worker DTIC auditado;
- flags mutáveis identificadas;
- lacunas documentadas.

#### Gate B — Ambiente externo DTIC aprovado

Confirmar:

- conta Cloudflare;
- tunnel;
- VPC Service;
- Worker URL;
- endpoint `/glpi/apirest.php`;
- se é produção/homologação;
- Worker sem `DELETE`;
- secrets não expostos.

#### Gate C — APK read-only aprovado

Confirmar:

- APK flavor `dtic`;
- endpoint Worker DTIC;
- `DTIC_ENABLE_FORM_SUBMISSION=false`;
- `DTIC_ENABLE_TICKET_ACTIONS=false`;
- assinatura e SHA-256;
- instalação em celular.

#### Gate D — Mutação sintética aprovada

A aprovação precisa dizer explicitamente:

- pode criar chamado sintético DTIC;
- formulário/entidade autorizado;
- pode enviar followup;
- pode anexar arquivo;
- pode propor solução;
- pode alterar status;
- pode aprovar/recusar solução, se perfil permitir;
- pode fechar apenas o ticket sintético;
- não pode tocar em tickets fora do prefixo.

## 7. Riscos principais

| Risco | Dano | Prevenção |
|---|---|---|
| DTIC app apontar para SIS | criar/ler chamado no sistema errado | `DticConfig` já bloqueia SIS; validar `.env` no APK |
| Worker DTIC com ações abertas por engano | mutação externa não controlada | `ALLOW_* = false` no primeiro deploy/APK |
| FormCreator criar chamado real em categoria errada | ruído operacional no CAU | só criar com prefixo sintético e aprovação |
| Followup/anexo em ticket real | contamina histórico real | reconsulta + prefixo + ID exato antes de cada mutação |
| `POST /Document` criar órfão | lixo documental | bloquear/evitar fallback standalone até prova |
| Status/solução por perfil privilegiado | fechamento indevido | matriz papel × estado × ação antes de habilitar |
| Sessão expirada mas UI ainda mostra ação | erro ou mutação com contexto stale | revalidar sessão e ticket antes da ação |

## 8. Recomendação objetiva

Sequência recomendada:

1. Fazer discovery DTIC completo, sem GLPI mutável.
2. Endurecer Worker DTIC e criar testes de allowlist.
3. Publicar Worker DTIC read-only.
4. Validar endpoint externo read-only.
5. Gerar APK DTIC read-only.
6. Instalar e validar login/catálogo/lista/detalhe/conversa em leitura.
7. Só então pedir aprovação para um único chamado sintético DTIC.

Não pular direto para APK mutável. O DTIC tem FormCreator e CAU real; o risco operacional é maior que no teste controlado do SIS.

## 9. Perguntas para Jonathan antes da execução prática

1. O DTIC Mobile deve usar o mesmo subdomínio Cloudflare `jonathan-sis-mobile-20260518.workers.dev` com outro Worker, ou você prefere um subdomínio/rota separada?
2. O VPC Service DTIC `019e2016-2a46-7923-966c-84a6cd95ce94` já foi criado na conta correta e aponta para `/glpi`?
3. Existe formulário DTIC seguro para chamado sintético de teste?
4. Qual entidade DTIC deve ser usada para o ticket canário?
5. O primeiro APK DTIC deve ser estritamente read-only, com `DTIC_ENABLE_FORM_SUBMISSION=false` e `DTIC_ENABLE_TICKET_ACTIONS=false`?
6. Quem será o usuário autorizado para o teste mutável futuro?
7. O ticket sintético DTIC pode ficar aberto/fechado como evidência, sem cleanup?
