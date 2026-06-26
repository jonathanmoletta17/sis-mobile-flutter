import assert from 'node:assert/strict';
import {test} from 'node:test';

import {__test} from '../src/index.js';

test('read-only checklist lookups are allowed (GET only)', () => {
  assert.equal(__test.isAllowedRequest('GET', '/search/Ticket'), true);
  assert.equal(__test.isAllowedRequest('GET', '/PluginGenericobjectConservacao'), true);
  assert.equal(__test.isAllowedRequest('GET', '/PluginGenericobjectConservacao/42'), true);
  assert.equal(__test.isAllowedRequest('GET', '/search/PluginGenericobjectConservacao'), true);
});

test('checklist option provider item is never mutable', () => {
  assert.equal(__test.isAllowedRequest('POST', '/PluginGenericobjectConservacao'), false);
  assert.equal(__test.isAllowedRequest('PUT', '/PluginGenericobjectConservacao/1'), false);
  assert.equal(__test.isAllowedRequest('DELETE', '/PluginGenericobjectConservacao/1'), false);
});

test('existing FormCreator read-only GETs remain allowed', () => {
  assert.equal(__test.isAllowedRequest('GET', '/PluginFormcreatorForm/52'), true);
  assert.equal(__test.isAllowedRequest('GET', '/PluginFormcreatorTargetTicket/341'), true);
});
