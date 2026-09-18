import assert from 'node:assert/strict';

export const projectId = 'demo-symmetry-rules';
export const bucket = `${projectId}.appspot.com`;

// Validate BOTH endpoints before initializing any Firebase client. No defaults
// from .firebaserc, Firebase options, credentials, or a real project are used.
export function requireDemoEmulators(env = process.env) {
  assert.equal(env.GCLOUD_PROJECT, projectId, 'Only demo-symmetry-rules is allowed');
  const endpoint = (name, port) => {
    assert.ok(
      env[name] === `127.0.0.1:${port}` || env[name] === `localhost:${port}`,
      `${name} must point to the local emulator on ${port}; run npm run test:integration`,
    );
    return { host: '127.0.0.1', port };
  };
  return {
    firestore: endpoint('FIRESTORE_EMULATOR_HOST', 18080),
    storage: endpoint('FIREBASE_STORAGE_EMULATOR_HOST', 19199),
  };
}

// Before downloading a returned URL, reject remote destinations and redirects.
export function requireLocalDownloadUrl(value) {
  const url = new URL(value);
  assert.equal(url.protocol, 'http:');
  assert.equal(url.hostname, '127.0.0.1');
  assert.equal(url.port, '19199');
  assert.equal(url.username, '');
  assert.equal(url.password, '');
  assert.ok(url.pathname.startsWith(`/v0/b/${bucket}/o/`));
  return url;
}
