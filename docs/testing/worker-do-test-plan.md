# Plano de Testes - Worker e Durable Objects

## Escopo

Validar contrato mobile, estados de idempotencia, concorrencia, capabilities e
proxy de anexos sem chamar o GLPI de producao.

O upstream deve ser um fake deterministico ou um GLPI de homologacao isolado.

## Idempotencia

### CT-W01 - Mutacao confirmada

- Enviar `POST /mobile/tickets` com `X-Operation-Id` novo.
- O fake GLPI retorna sucesso.
- Esperado: `RECEIVED -> PROCESSING -> COMPLETED`, resposta `201` e mesmo
  `operation_id`.

### CT-W02 - Falha comprovadamente pre-dispatch

- Fazer a validacao local abortar antes de chamar `fetch`.
- Esperado: `RETRY_WAIT`, sem chamada registrada no fake GLPI.

Falha generica de rede nao deve ser classificada como pre-dispatch sem evidencia
do runtime.

### CT-W03 - Resultado remoto ambiguo

- O fake GLPI recebe a mutacao e encerra a conexao sem resposta conclusiva.
- Esperado: `UNKNOWN` e `409 OPERATION_UNKNOWN`.
- Novo request com o mesmo ID nao pode emitir nova mutacao.

### CT-W04 - Create/followup inconclusivo

- Reconciliar `create_ticket` ou `add_followup` por busca sem marcador unico.
- Esperado: mesmo que exista candidato por texto/usuario/data, o estado continua
  `UNKNOWN`.

### CT-W05 - Sucesso equivalente

- Simular `change_status` ambiguo e retornar no read-back o status alvo.
- Esperado: `RECONCILING -> COMPLETED`, registrado como sucesso equivalente,
  nao como prova da tentativa original.

### CT-W06 - Operation ID reutilizado

- Repetir `X-Operation-Id` com digest de payload diferente.
- Esperado: `409 OPERATION_ID_REUSED`; nenhuma chamada adicional ao upstream.

### CT-W07 - Concorrencia

- Enviar duas mutacoes simultaneas com mesmo operation ID e digest.
- Esperado: apenas uma adquire o lease; a outra recebe
  `409 OPERATION_IN_PROGRESS`.

### CT-W08 - Escrita tardia

- A execucao A perde o lease; B assume estado valido; A retorna depois do
  `fetch`.
- Esperado: CAS/fencing rejeita a escrita de A.

### CT-W09 - Sessao e versao

- Cobrir Session-Token ausente/expirado, `X-App-Version` ausente e versao abaixo
  do minimo.
- Esperado: `401 AUTH_REQUIRED` ou `426 UPGRADE_REQUIRED`, sem mutacao upstream.

### CT-W10 - Matriz de operacoes

- Repetir sucesso, conflito e UNKNOWN para create ticket, followup, solution,
  status, claim e upload.
- Esperado: resposta e estado aderentes ao OpenAPI para cada action type.

## Snapshot e capabilities

### CT-W11 - ETag do snapshot

- Primeira leitura retorna `200` e ETag.
- Leitura com `If-None-Match` atual retorna `304`.

### CT-W12 - Capability advisory

- Capability previamente permitida fica invalida por mudanca remota.
- Esperado: a mutacao revalida o estado e retorna `409 STATE_CONFLICT`.

## Proxy de anexos

### CT-W13 - Documento direto no ticket

- Provar `Document_Item -> Ticket` e acesso ao ticket.
- Esperado: stream somente depois das duas validacoes.

### CT-W14 - Documento de followup

- Provar `Document_Item -> ITILFollowup -> Ticket`.
- Esperado: stream permitido apenas quando toda a cadeia aponta ao ticket da
  URL.

### CT-W15 - Documento de solucao

- Provar `Document_Item -> ITILSolution -> Ticket`.
- Esperado: mesma regra do followup.

### CT-W16 - Acesso cruzado

- Usar `document_item_id` de outro ticket.
- Esperado: `403 CROSS_ACCESS_ATTEMPT`, sem vazar URL ou metadados do documento.

### CT-W17 - Range

- Enviar Range valido e invalido.
- Esperado: anunciar `Accept-Ranges` apenas quando o upstream retornar `206` e
  `Content-Range`; Range invalido retorna `416`.

## Criterio de saida

- Todos os testes rodam com fake/homologacao.
- Nenhum teste usa ticket real de usuario.
- UNKNOWN nunca produz uma segunda mutacao automatica.
- Logs correlacionam operation ID e correlation ID sem registrar secrets.
