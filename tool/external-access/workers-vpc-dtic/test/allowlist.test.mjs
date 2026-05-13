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
  assert.equal(__test.isAllowedRequest('POST', '/Document_Item', ticketActionsOn), true);
  assert.equal(__test.isAllowedRequest('PUT', '/Ticket/123', ticketActionsOn), true);
  assert.equal(__test.isAllowedRequest('PUT', '/ITILSolution/456', ticketActionsOn), true);
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
