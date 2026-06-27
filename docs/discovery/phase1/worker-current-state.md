# Estado Atual do Worker/Middleware

## 1. Stack e configuracao sem secrets

- Linguagem/framework: JavaScript em Cloudflare Worker, exportando handler `fetch`.
- Local no repositorio: `tool/external-access/workers-vpc/`.
- Arquivo principal: `tool/external-access/workers-vpc/src/index.js`.
- Configuracao declarativa: `tool/external-access/workers-vpc/wrangler.jsonc`.
- Variaveis/bindings observados, sem valores:
  - `GLPI`: binding Workers VPC para o GLPI.
  - `GLPI_APP_TOKEN`: secret injetado como `App-Token` e `app_token`.
  - `GLPI_SERVICE_USER_TOKEN`: token de servico usado apenas para leitura de diretorio `User`/`Group`.
  - `GLPI_SERVICE_PROFILE_ID`: perfil central usado pela sessao de servico.
  - `ALLOW_FORMCREATOR_SUBMISSION`: gate explicito para `PluginFormcreatorFormAnswer`; default declarado como `false`.

Evidencias:
- Allowlist, paths de metadados e prefixo GLPI: `tool/external-access/workers-vpc/src/index.js:4`.
- Injecao de `GLPI_APP_TOKEN`: `tool/external-access/workers-vpc/src/index.js:67`.
- Sessao de servico restrita a `User`/`Group`: `tool/external-access/workers-vpc/src/index.js:89`.
- Gate de FormCreator: `tool/external-access/workers-vpc/src/index.js:186`.
- Flag default em config: `tool/external-access/workers-vpc/wrangler.jsonc:1`.

## 2. Autenticacao GLPI

- O Worker nao cria sessao de usuario propria para o fluxo normal; ele repassa a requisicao ao GLPI com `App-Token` e preserva `Session-Token` recebido do app.
- Para leituras de diretorio (`User`/`Group`), existe uma sessao de servico em memoria do isolate, renovada em caso de `401`.
- Nao foi encontrado armazenamento persistente de sessoes, idempotencia ou fila no Worker.

Confianca: alta para o desenho atual, pois o comportamento esta concentrado em `src/index.js`.

## 3. Endpoints GLPI encontrados no Worker

Classificacao aqui e semantica operacional, nao uma decisao de seguranca. Nada foi executado contra o GLPI nesta fase.

| Endpoint GLPI | Metodo | Classificacao | Funcao no Worker |
|---|---:|---|---|
| `/initSession` | GET/POST | READ para allowlist, sensivel para auth | Login/pass-through de sessao GLPI |
| `/killSession` | GET | MUTATING leve | Encerrar sessao GLPI |
| `/getFullSession` | GET | READ | Contexto de sessao/perfil/entidade |
| `/getActiveProfile` | GET | READ | Perfil ativo |
| `/getMyProfiles` | GET | READ | Perfis do usuario |
| `/getMyEntities` | GET | READ | Entidades do usuario |
| `/ITILCategory` | GET | READ | Categorias |
| `/RequestType` | GET | READ | Tipos de requisicao |
| `/Location` | GET | READ | Localizacoes |
| `/Entity` | GET | READ | Entidades |
| `/search/Ticket` | GET | READ | Busca de chamados |
| `/Ticket` | GET | READ | Lista/leitura de chamados |
| `/Ticket` | POST | MUTATING | Criar chamado |
| `/Ticket/{id}` | GET | READ | Detalhe de chamado |
| `/Ticket/{id}` | PUT | MUTATING | Alterar status/campos do chamado |
| `/Ticket/{id}/TicketFollowup` | GET | READ | Acompanhamentos |
| `/TicketFollowup` | POST | MUTATING | Criar acompanhamento |
| `/Ticket/{id}/ITILSolution` | GET | READ | Solucoes do chamado |
| `/ITILSolution` | POST | MUTATING | Criar solucao |
| `/ITILSolution/{id}` | PUT | MUTATING | Alterar solucao |
| `/Ticket_User` | POST | MUTATING | Atribuir tecnico |
| `/Ticket/{id}/Ticket_User` | GET | READ | Usuarios vinculados |
| `/Ticket/{id}/Group_Ticket` | GET | READ | Grupos vinculados |
| `/Ticket/{id}/Document` | POST | MUTATING | Upload direto de anexo no ticket |
| `/ITILFollowup/{id}/Document` | POST | MUTATING | Upload direto de anexo no followup |
| `/ITILSolution/{id}/Document` | POST | MUTATING | Upload direto de anexo na solucao |
| `/Ticket/{id}/Document_Item` | GET | READ | Validar vinculos de documentos do ticket |
| `/ITILFollowup/{id}/Document_Item` | GET | READ | Validar documentos de followup |
| `/ITILSolution/{id}/Document_Item` | GET | READ | Validar documentos de solucao |
| `/Document/{id}` | GET | READ | Detalhe/download de documento |
| `/Document_Item` | GET | READ | Consulta generica de vinculos |
| `/Document` | POST | BLOQUEADO | Upload orfao bloqueado pela allowlist |
| `/Document_Item` | POST | BLOQUEADO | Vinculo manual bloqueado pela allowlist |
| `/PluginFormcreator*` | GET | READ | Metadados FormCreator |
| `/PluginFormcreatorFormAnswer` | POST | MUTATING gated | Submissao FormCreator, bloqueada por default |
| `/PluginGenericobjectConservacao*` | GET | READ | Lookup de itens de conservacao |
| `/changeActiveProfile` | POST | MUTATING interno | Usado somente dentro da sessao de servico |

Evidencias principais:
- Padrao read-only: `tool/external-access/workers-vpc/src/index.js:9`.
- POST allowlist: `tool/external-access/workers-vpc/src/index.js:18`.
- Upload de documento por item: `tool/external-access/workers-vpc/src/index.js:26`.
- PUT allowlist: `tool/external-access/workers-vpc/src/index.js:29`.
- Decisor de allowlist: `tool/external-access/workers-vpc/src/index.js:178`.
- Testes de bloqueio de rotas destrutivas/orfas: `tool/external-access/workers-vpc/test/allowlist.test.mjs:1`.

## 4. Banco de dados, fila e idempotencia

- Banco proprio do Worker: nao encontrado.
- Schema persistente: nao encontrado.
- Controle de idempotencia: nao encontrado.
- Fila/mensageria: nao encontrada.
- Cache persistente de resultado GLPI: nao encontrado.
- Estado em memoria: apenas `serviceSessionToken`, usado para sessao de servico de diretorio.

Confianca: alta para o repositorio atual. Ainda falta confirmar se ha outro repo backend fora deste workspace, mas o AGENTS.md declara este workspace como raiz canonica para o mobile.

## 5. Metadados expostos pelo Worker

- `/metadata/mobile/sis/catalog`: catalogo runtime SIS, read-only, com ETag e hash de snapshot.
- `/metadata/mobile/sis/checklists`: catalogo read-only de checklists SIS.
- Nao foi encontrado endpoint de `capabilities` por ticket.
- Nao foi encontrado endpoint de snapshot unificado contendo regras, permissoes, formularios, categorias e acoes por perfil de forma transacional.

Evidencias:
- Rotas de metadados: `tool/external-access/workers-vpc/src/index.js:6`.
- Resposta read-only do catalogo: `tool/external-access/workers-vpc/src/index.js:207`.

## 6. Lacunas identificadas no Worker

- [x] Nao possui `idempotency_registry` com hash de payload, resultado GLPI e distincao entre falha terminal e retryable.
- [x] Nao possui proxy seguro de anexo com JWT proprio, escopo, expiracao e validacao cruzada `ticket_id` + `document_id`.
- [x] Nao expõe `capabilities` por ticket para o app decidir botoes/acoes a partir do estado real.
- [x] Nao possui re-fetch padronizado apos toda acao mutavel; algumas confirmacoes existem no app, nao como contrato server-side.
- [x] Nao possui fila server-side ou persistencia de outbox.
- [ ] Possui allowlist operacional de rotas e bloqueia rotas destrutivas/orfas conhecidas.
- [ ] Possui metadados read-only de catalogo e checklists.

## 7. Riscos e decisoes

| Item | Risco | Confianca | Decisao necessaria |
|---|---|---:|---|
| W1 | Repetir uma criacao/followup apos timeout pode duplicar registros no GLPI. | Alta | Escolher armazenamento de idempotencia no Worker. |
| W2 | Download de `/Document/{id}` via Worker nao prova que o documento pertence ao ticket aberto pelo usuario. | Alta | Criar proxy de anexo com validacao cruzada em `Document_Item`. |
| W3 | App continua decidindo parte das acoes por regra local/fallback. | Alta | Definir contrato `capabilities` por ticket. |
| W4 | FormCreator write esta bloqueado por default, mas ainda nao existe matriz runtime completa `unsupported/native/webview/discovery/specialized/blocked`. | Media | Definir e publicar schema de formulario/capability. |
