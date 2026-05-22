import assert from 'node:assert/strict';
import {test} from 'node:test';

import {__test} from '../src/index.js';

test('SIS worker normalizes supported API paths', () => {
  assert.equal(__test.normalizeGlpiPath('/sis/apirest.php/Ticket/123'), '/sis/apirest.php/Ticket/123');
  assert.equal(__test.normalizeGlpiPath('/apirest.php/Ticket/123'), '/sis/apirest.php/Ticket/123');
  assert.equal(__test.normalizeGlpiPath('/Ticket/123'), '/sis/apirest.php/Ticket/123');
});

test('SIS worker answers browser CORS preflight for JSON login', async () => {
  const response = await __test.fetch(
    new Request('https://example.test/sis/apirest.php/initSession', {
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

test('SIS worker serves mobile metadata catalog read-only without VPC binding', async () => {
  const response = await __test.fetch(
    new Request('https://example.test/metadata/mobile/sis/catalog', {method: 'GET'}),
    {},
  );
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.consumer_id, 'sis-mobile-flutter');
  assert.equal(body.services.length, 15);
  assert.equal(response.headers.get('Cache-Control'), 'private, max-age=300');
  assert.ok(response.headers.get('ETag'));
  assert.ok(response.headers.get('X-GLPI-Snapshot-Hash'));
  assert.equal(response.headers.get('X-Consumer-Id'), 'sis-mobile-flutter');
});

test('SIS worker returns 304 for metadata catalog ETag match', async () => {
  const first = await __test.fetch(
    new Request('https://example.test/metadata/mobile/sis/catalog', {method: 'GET'}),
    {},
  );
  const etag = first.headers.get('ETag');
  const second = await __test.fetch(
    new Request('https://example.test/metadata/mobile/sis/catalog', {
      method: 'GET',
      headers: {'If-None-Match': etag},
    }),
    {},
  );

  assert.equal(second.status, 304);
  assert.equal(second.headers.get('ETag'), etag);
});

test('SIS worker blocks metadata catalog mutations', async () => {
  const response = await __test.fetch(
    new Request('https://example.test/metadata/mobile/sis/catalog', {method: 'POST'}),
    {},
  );

  assert.equal(response.status, 405);
});
test('SIS worker allows login, session close and read-only ticket endpoints', () => {
  assert.equal(__test.isAllowedRequest('POST', '/initSession'), true);
  assert.equal(__test.isAllowedRequest('GET', '/initSession'), true);
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
