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

test('SIS worker allows metadata ETag preflight headers', async () => {
  const response = await __test.fetch(
    new Request('https://example.test/metadata/mobile/sis/catalog', {
      method: 'OPTIONS',
      headers: {
        Origin: 'http://127.0.0.1:8081',
        'Access-Control-Request-Method': 'GET',
        'Access-Control-Request-Headers': 'if-none-match',
      },
    }),
    {},
  );

  assert.equal(response.status, 204);
  assert.match(response.headers.get('Access-Control-Allow-Headers'), /If-None-Match/);
  assert.match(response.headers.get('Access-Control-Allow-Methods'), /GET/);
});

test('SIS worker serves mobile metadata catalog read-only without VPC binding', async () => {
  const response = await __test.fetch(
    new Request('https://example.test/metadata/mobile/sis/catalog', {method: 'GET'}),
    {},
  );
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.consumer_id, 'sis-mobile-flutter');
  assert.equal(body.records.length, 133);
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
test('SIS worker injects configured GLPI App-Token into upstream requests', async () => {
  let upstreamAppToken = null;
  let upstreamAppTokenParam = null;
  const response = await __test.fetch(
    new Request('https://example.test/sis/apirest.php/initSession?range=0-0', {
      method: 'POST',
      headers: {
        Authorization: 'Basic invalid-test-value',
      },
    }),
    {
      GLPI_APP_TOKEN: 'unit-test-app-token',
      GLPI: {
        fetch: async (request) => {
          upstreamAppToken = request.headers.get('App-Token');
          upstreamAppTokenParam = new URL(request.url).searchParams.get('app_token');
          return new Response('["ERROR_GLPI_LOGIN","Credenciais invalidas"]', {
            status: 401,
            headers: {'Content-Type': 'application/json'},
          });
        },
      },
    },
  );

  assert.equal(response.status, 401);
  assert.equal(upstreamAppToken, 'unit-test-app-token');
  assert.equal(upstreamAppTokenParam, 'unit-test-app-token');
});

test('SIS worker fails visibly when GLPI App-Token secret is missing', async () => {
  const response = await __test.fetch(
    new Request('https://example.test/sis/apirest.php/initSession', {
      method: 'GET',
      headers: {
        Authorization: 'Basic invalid-test-value',
      },
    }),
    {
      GLPI: {
        fetch: async () => new Response('should not reach upstream', {status: 599}),
      },
    },
  );
  const body = await response.json();

  assert.equal(response.status, 500);
  assert.match(body.error, /App-Token/);
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
  assert.equal(__test.isAllowedRequest('GET', '/Ticket/123/Ticket_User'), true);
  assert.equal(__test.isAllowedRequest('GET', '/Ticket/123/Group_Ticket'), true);
  assert.equal(__test.isAllowedRequest('GET', '/User/2039'), true);
  assert.equal(__test.isAllowedRequest('GET', '/Group/22'), true);
  assert.equal(__test.isAllowedRequest('GET', '/Ticket/123/Document_Item'), true);
  assert.equal(__test.isAllowedRequest('GET', '/Document/456'), true);
});

test('SIS worker allows read-only FormCreator condition lookup', () => {
  assert.equal(__test.isAllowedRequest('GET', '/PluginFormcreatorCondition'), true);
  assert.equal(__test.isAllowedRequest('GET', '/PluginFormcreatorCondition/771'), true);
  assert.equal(
    __test.isAllowedRequest(
      'GET',
      '/PluginFormcreatorCondition?searchText[itemtype]=PluginFormcreatorSection&searchText[items_id]=166',
    ),
    true,
  );
  assert.equal(__test.isAllowedRequest('POST', '/PluginFormcreatorCondition'), false);
  assert.equal(__test.isAllowedRequest('PUT', '/PluginFormcreatorCondition/771'), false);
  assert.equal(__test.isAllowedRequest('DELETE', '/PluginFormcreatorCondition/771'), false);
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

test('SIS worker allows session profile switching for the user', () => {
  // getMyProfiles (GET) via padrão read-only; changeActiveProfile (POST) na
  // sessão do próprio usuário — operação de sessão, não-destrutiva.
  assert.equal(__test.isAllowedRequest('GET', '/getMyProfiles'), true);
  assert.equal(__test.isAllowedRequest('POST', '/changeActiveProfile'), true);
});

test('SIS worker blocks destructive and orphan-prone routes', () => {
  assert.equal(__test.isAllowedRequest('DELETE', '/Ticket/123'), false);
  assert.equal(__test.isAllowedRequest('DELETE', '/Document/6530'), false);
  assert.equal(__test.isAllowedRequest('POST', '/Document'), false);
  assert.equal(__test.isAllowedRequest('POST', '/Document_Item'), false);
  assert.equal(__test.isAllowedRequest('POST', '/Ticket/123/Invalid'), false);
  assert.equal(__test.isAllowedRequest('PATCH', '/Ticket/123'), false);
});
