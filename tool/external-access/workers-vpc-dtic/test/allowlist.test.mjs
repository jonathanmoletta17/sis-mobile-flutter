import assert from 'node:assert/strict';
import {test} from 'node:test';

import {__test} from '../src/index.js';

const ticketActionsOn = {
  ALLOW_TICKET_ACTIONS: 'true',
  ALLOW_FORMCREATOR_SUBMISSION: 'false',
};

const ticketActionsOff = {
  ALLOW_TICKET_ACTIONS: 'false',
  ALLOW_FORMCREATOR_SUBMISSION: 'false',
};

test('DTIC worker healthz does not require GLPI secret or upstream', async () => {
  const response = await __test.fetch(new Request('https://example.test/healthz'), {});
  assert.equal(response.status, 200);
  assert.equal(await response.text(), 'ok');
});

test('DTIC worker applies allowlist before checking GLPI secret', async () => {
  const response = await __test.fetch(
    new Request('https://example.test/glpi/apirest.php/Ticket/1', {method: 'DELETE'}),
    {},
  );
  assert.equal(response.status, 403);
});

test('DTIC worker answers browser CORS preflight for JSON login', async () => {
  const response = await __test.fetch(
    new Request('https://example.test/glpi/apirest.php/initSession', {
      method: 'OPTIONS',
      headers: {
        Origin: 'https://sis-dtic-mobile-pwa.pages.dev',
        'Access-Control-Request-Method': 'POST',
        'Access-Control-Request-Headers': 'content-type',
      },
    }),
    {},
  );
  assert.equal(response.status, 204);
  assert.equal(response.headers.get('Access-Control-Allow-Origin'), '*');
  assert.match(response.headers.get('Access-Control-Allow-Headers'), /Content-Type/);
  assert.match(response.headers.get('Access-Control-Allow-Methods'), /POST/);
});

test('DTIC worker always allows login and read-only ticket endpoints', () => {
  assert.equal(__test.isAllowedRequest('POST', '/initSession', ticketActionsOff), true);
  assert.equal(__test.isAllowedRequest('GET', '/Ticket/123', ticketActionsOff), true);
  assert.equal(
    __test.isAllowedRequest('GET', '/Ticket/123/TicketFollowup', ticketActionsOff),
    true,
  );
  assert.equal(
    __test.isAllowedRequest('GET', '/ITILFollowup/456/Document_Item', ticketActionsOff),
    true,
  );
  assert.equal(
    __test.isAllowedRequest('GET', '/ITILSolution/789/Document_Item', ticketActionsOff),
    true,
  );
});

test('DTIC worker blocks ticket writes by default', () => {
  assert.equal(__test.isAllowedRequest('POST', '/TicketFollowup', ticketActionsOff), false);
  assert.equal(__test.isAllowedRequest('POST', '/Document', ticketActionsOff), false);
  assert.equal(__test.isAllowedRequest('PUT', '/Ticket/123', ticketActionsOff), false);
});

test('DTIC worker allows operational ticket actions when explicitly enabled', () => {
  assert.equal(__test.isAllowedRequest('POST', '/TicketFollowup', ticketActionsOn), true);
  assert.equal(__test.isAllowedRequest('POST', '/ITILSolution', ticketActionsOn), true);
  assert.equal(__test.isAllowedRequest('POST', '/Ticket_User', ticketActionsOn), true);
  assert.equal(__test.isAllowedRequest('POST', '/Ticket/123/Document', ticketActionsOn), true);
  assert.equal(__test.isAllowedRequest('POST', '/ITILFollowup/456/Document', ticketActionsOn), true);
  assert.equal(__test.isAllowedRequest('POST', '/ITILSolution/789/Document', ticketActionsOn), true);
  assert.equal(__test.isAllowedRequest('PUT', '/Ticket/123', ticketActionsOn), true);
  assert.equal(__test.isAllowedRequest('PUT', '/ITILSolution/456', ticketActionsOn), true);
});

test('DTIC worker blocks orphan-prone standalone document writes even when ticket actions are enabled', () => {
  assert.equal(__test.isAllowedRequest('POST', '/Document', ticketActionsOn), false);
  assert.equal(__test.isAllowedRequest('POST', '/Document_Item', ticketActionsOn), false);
});

test('DTIC worker does not allow direct ticket creation or broad Ticket POST passthrough', () => {
  assert.equal(__test.isAllowedRequest('POST', '/Ticket', ticketActionsOn), false);
  assert.equal(__test.isAllowedRequest('POST', '/Ticket/123/Invalid', ticketActionsOn), false);
});

test('DTIC FormCreator submission is governed separately from ticket actions', () => {
  assert.equal(
    __test.isAllowedRequest('POST', '/PluginFormcreatorFormAnswer', ticketActionsOn),
    false,
  );
  assert.equal(
    __test.isAllowedRequest('POST', '/PluginFormcreatorFormAnswer', {
      ALLOW_TICKET_ACTIONS: 'false',
      ALLOW_FORMCREATOR_SUBMISSION: 'true',
    }),
    true,
  );
});
