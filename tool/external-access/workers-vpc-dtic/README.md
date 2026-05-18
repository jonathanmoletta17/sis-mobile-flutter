# DTIC GLPI Worker

Worker separado para o app DTIC.

## Contrato

- Origem interna: `http://cau.ppiratini.intra.rs.gov.br/glpi/apirest.php`
- VPC Service atual: `019e39d4-a7ac-7362-ac8b-24a09050ae72`, compartilhado
  com o Worker SIS por apontar para o mesmo host/porta; a separacao SIS/DTIC
  ocorre no path (`/sis/apirest.php` vs `/glpi/apirest.php`).
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

- `GET /healthz` sem tocar no GLPI ou exigir secret
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
- `POST /Ticket/{id}/Document`
- `POST /ITILFollowup/{id}/Document`
- `POST /ITILSolution/{id}/Document`
- `PUT /Ticket/{id}`
- `PUT /ITILSolution/{id}`

`POST /Document` e `POST /Document_Item` standalone permanecem bloqueados mesmo
com `ALLOW_TICKET_ACTIONS=true`, porque podem criar documento orfao se o upload
for aceito e o vinculo falhar. O caminho liberado e o upload direto para o item
do GLPI: `/{Ticket|ITILFollowup|ITILSolution}/{id}/Document`.

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
