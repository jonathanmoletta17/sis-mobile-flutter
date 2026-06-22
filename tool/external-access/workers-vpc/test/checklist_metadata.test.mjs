import assert from 'node:assert/strict';
import {test} from 'node:test';

import {__test} from '../src/index.js';

const CHECKLIST_PATH = 'https://example.test/metadata/mobile/sis/checklists';

test('SIS checklist metadata endpoint is read-only and returns checklist catalog', async () => {
  const response = await __test.fetch(new Request(CHECKLIST_PATH, {method: 'GET'}), {});
  assert.equal(response.status, 200);
  const body = await response.json();
  assert.equal(body.forms.length, 5);
  assert.equal(body.targets.length, 17);
  assert.equal(body.questions.length, 1252);
  assert.equal(response.headers.get('Cache-Control'), 'private, max-age=300');
  assert.ok(response.headers.get('ETag'));
  assert.ok(response.headers.get('X-GLPI-Snapshot-Hash'));
});

test('SIS checklist metadata exposes GLPI profile gate per form', async () => {
  const response = await __test.fetch(new Request(CHECKLIST_PATH, {method: 'GET'}), {});
  const body = await response.json();
  for (const form of body.forms) {
    assert.ok(Array.isArray(form.profile_ids), `form ${form.id} must carry profile_ids`);
    assert.deepEqual(form.profile_ids, [4], `form ${form.id} must be Super-Admin only today`);
  }
});

test('SIS checklist metadata returns 304 for ETag match', async () => {
  const first = await __test.fetch(new Request(CHECKLIST_PATH, {method: 'GET'}), {});
  const etag = first.headers.get('ETag');
  const second = await __test.fetch(
    new Request(CHECKLIST_PATH, {method: 'GET', headers: {'If-None-Match': etag}}),
    {},
  );
  assert.equal(second.status, 304);
  assert.equal(second.headers.get('ETag'), etag);
});

test('SIS checklist metadata rejects POST', async () => {
  const response = await __test.fetch(new Request(CHECKLIST_PATH, {method: 'POST'}), {});
  assert.equal(response.status, 405);
});
