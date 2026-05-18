import assert from 'node:assert/strict';
import {test} from 'node:test';

import {__test} from '../src/index.js';

test('SIS worker normalizes supported API paths', () => {
  assert.equal(__test.normalizeGlpiPath('/sis/apirest.php/Ticket/123'), '/sis/apirest.php/Ticket/123');
  assert.equal(__test.normalizeGlpiPath('/apirest.php/Ticket/123'), '/sis/apirest.php/Ticket/123');
  assert.equal(__test.normalizeGlpiPath('/Ticket/123'), '/sis/apirest.php/Ticket/123');
});

test('SIS worker allows login, session close and read-only ticket endpoints', () => {
  assert.equal(__test.isAllowedRequest('POST', '/initSession'), true);
  assert.equal(__test.isAllowedRequest('GET', '/killSession'), true);
  assert.equal(__test.isAllowedRequest('GET', '/getFullSession'), true);
  assert.equal(__test.isAllowedRequest('GET', '/ITILCategory'), true);
  assert.equal(__test.isAllowedRequest('GET', '/search/Ticket'), true);
  assert.equal(__test.isAllowedRequest('GET', '/Ticket/123'), true);
  assert.equal(__test.isAllowedRequest('GET', '/Ticket/123/TicketFollowup'), true);
  assert.equal(__test.isAllowedRequest('GET', '/Ticket/123/Document_Item'), true);
  assert.equal(__test.isAllowedRequest('GET', '/Document/456'), true);
});

test('SIS worker allows app operational writes but only on known routes', () => {
  assert.equal(__test.isAllowedRequest('POST', '/Ticket'), true);
  assert.equal(__test.isAllowedRequest('POST', '/TicketFollowup'), true);
  assert.equal(__test.isAllowedRequest('POST', '/ITILSolution'), true);
  assert.equal(__test.isAllowedRequest('POST', '/Ticket_User'), true);
  assert.equal(__test.isAllowedRequest('POST', '/Ticket/123/Document'), true);
  assert.equal(__test.isAllowedRequest('POST', '/ITILFollowup/123/Document'), true);
  assert.equal(__test.isAllowedRequest('POST', '/ITILSolution/123/Document'), true);
  assert.equal(__test.isAllowedRequest('PUT', '/Ticket/123'), true);
  assert.equal(__test.isAllowedRequest('PUT', '/ITILSolution/123'), true);
});

test('SIS worker blocks destructive and orphan-prone routes', () => {
  assert.equal(__test.isAllowedRequest('DELETE', '/Ticket/123'), false);
  assert.equal(__test.isAllowedRequest('DELETE', '/Document/6530'), false);
  assert.equal(__test.isAllowedRequest('POST', '/Document'), false);
  assert.equal(__test.isAllowedRequest('POST', '/Document_Item'), false);
  assert.equal(__test.isAllowedRequest('POST', '/Ticket/123/Invalid'), false);
  assert.equal(__test.isAllowedRequest('PATCH', '/Ticket/123'), false);
});
