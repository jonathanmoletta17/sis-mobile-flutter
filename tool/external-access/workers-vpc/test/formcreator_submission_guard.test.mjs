import assert from 'node:assert/strict';
import {test} from 'node:test';

import {__test} from '../src/index.js';

test('SIS FormCreator submission is blocked by default', () => {
  assert.equal(__test.isAllowedRequest('POST', '/PluginFormcreatorFormAnswer', {}), false);
  assert.equal(__test.isAllowedRequest('POST', '/PluginFormcreatorFormAnswer'), false);
});

test('SIS FormCreator submission is blocked when flag is not exactly "true"', () => {
  assert.equal(
    __test.isAllowedRequest('POST', '/PluginFormcreatorFormAnswer', {ALLOW_FORMCREATOR_SUBMISSION: 'false'}),
    false,
  );
  assert.equal(
    __test.isAllowedRequest('POST', '/PluginFormcreatorFormAnswer', {ALLOW_FORMCREATOR_SUBMISSION: '1'}),
    false,
  );
});

test('SIS FormCreator submission requires explicit Worker flag', () => {
  assert.equal(
    __test.isAllowedRequest('POST', '/PluginFormcreatorFormAnswer', {ALLOW_FORMCREATOR_SUBMISSION: 'true'}),
    true,
  );
});

test('FormCreator flag does not widen other POST routes', () => {
  assert.equal(
    __test.isAllowedRequest('POST', '/Document', {ALLOW_FORMCREATOR_SUBMISSION: 'true'}),
    false,
  );
  assert.equal(
    __test.isAllowedRequest('PUT', '/PluginFormcreatorFormAnswer/1', {ALLOW_FORMCREATOR_SUBMISSION: 'true'}),
    false,
  );
  assert.equal(
    __test.isAllowedRequest('DELETE', '/PluginFormcreatorFormAnswer/1', {ALLOW_FORMCREATOR_SUBMISSION: 'true'}),
    false,
  );
});

test('existing operational POST routes still pass without the flag', () => {
  assert.equal(__test.isAllowedRequest('POST', '/Ticket', {}), true);
  assert.equal(__test.isAllowedRequest('POST', '/TicketFollowup', {}), true);
});
