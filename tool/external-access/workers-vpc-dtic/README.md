# DTIC GLPI Worker

Worker separado para o app DTIC.

## Contrato

- Origem interna: `http://cau.ppiratini.intra.rs.gov.br/glpi/apirest.php`
- O app Flutter aponta `DTIC_GLPI_BASE_URL` para:

```env
DTIC_GLPI_BASE_URL=https://dtic-glpi.<conta>.workers.dev/glpi/apirest.php
GLPI_DEBUG_LOGS=false
DTIC_ENABLE_TICKET_ACTIONS=false
DTIC_ENABLE_FORM_SUBMISSION=false
```

- O `App-Token` do GLPI DTIC deve ser configurado como secret do Worker:

```bash
npx wrangler secret put GLPI_APP_TOKEN
```

## Escrita e acoes

Por padrao, o Worker permite apenas:

- `POST /initSession`
- `GET /killSession`
- leituras de sessao, tickets, documentos e metadados FormCreator

Acoes operacionais de ticket usam a mesma abordagem externa da SIS: app aponta
para o Worker, Worker injeta `App-Token` no servidor e preserva
`Session-Token`, metodos, multipart e status HTTP do GLPI. Elas ficam
bloqueadas ate o ambiente ser explicitamente liberado:

```jsonc
"ALLOW_TICKET_ACTIONS": "true"
```

Com essa chave ativa, o Worker libera o subconjunto usado pelo app para
ticket, followup, solucao, atribuicao e anexos:

- `POST /TicketFollowup`
- `POST /ITILSolution`
- `POST /Ticket_User`
- `POST /Document`
- `POST /Document_Item`
- `POST /Ticket/{id}/Document`
- `POST /ITILFollowup/{id}/Document`
- `POST /ITILSolution/{id}/Document`
- `PUT /Ticket/{id}`
- `PUT /ITILSolution/{id}`

Criacao direta por `POST /Ticket` nao faz parte da linha DTIC. Abertura real de
chamado DTIC deve preservar o FormCreator.

Submissao real via `PluginFormcreatorFormAnswer` e outra decisao. Ela fica
bloqueada ate validacao institucional explicita e usa guarda separada:

```jsonc
"ALLOW_FORMCREATOR_SUBMISSION": "true"
```

Para uma janela controlada, configure:

```bash
npx wrangler secret put GLPI_APP_TOKEN
npx wrangler deploy
```

e altere apenas a chave necessaria no ambiente validado.
