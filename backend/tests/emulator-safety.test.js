import assert from 'node:assert/strict';
import { test } from 'node:test';
import { bucket, projectId, requireDemoEmulators, requireLocalDownloadUrl } from './support/emulator-safety.js';

const valid = {
  GCLOUD_PROJECT: projectId,
  FIRESTORE_EMULATOR_HOST: '127.0.0.1:18080',
  FIREBASE_STORAGE_EMULATOR_HOST: '127.0.0.1:19199',
};

test('accepts only the demo project with both explicit local endpoints', () => {
  assert.deepEqual(requireDemoEmulators(valid), {
    firestore: { host: '127.0.0.1', port: 18080 },
    storage: { host: '127.0.0.1', port: 19199 },
  });
});
for (const field of Object.keys(valid)) {
  test(`fails closed when ${field} is missing`, () => {
    const env = { ...valid };
    delete env[field];
    assert.throws(() => requireDemoEmulators(env));
  });
}
test('rejects a real project even with both emulator endpoints', () => {
  assert.throws(() => requireDemoEmulators({ ...valid, GCLOUD_PROJECT: 'real-project' }));
});
for (const field of ['FIRESTORE_EMULATOR_HOST', 'FIREBASE_STORAGE_EMULATOR_HOST']) {
  test(`rejects a remote or wrong-port endpoint for ${field}`, () => {
    for (const value of ['example.com:443', '127.0.0.1:8080', 'localhost.evil:19199']) {
      assert.throws(() => requireDemoEmulators({ ...valid, [field]: value }));
    }
  });
}
test('download guard rejects remote URLs and the wrong bucket', () => {
  assert.doesNotThrow(() => requireLocalDownloadUrl(`http://127.0.0.1:19199/v0/b/${bucket}/o/image`));
  for (const url of [
    `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/image`,
    'http://127.0.0.1:19199/v0/b/real-project/o/image',
    `http://127.0.0.1:9199/v0/b/${bucket}/o/image`,
  ]) assert.throws(() => requireLocalDownloadUrl(url));
});
