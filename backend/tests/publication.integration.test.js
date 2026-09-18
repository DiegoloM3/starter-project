import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { after, test } from 'node:test';
import { initializeApp, deleteApp } from 'firebase/app';
import {
  getFirestore, connectFirestoreEmulator, collection, doc, setDoc,
  getDocFromServer, serverTimestamp, Timestamp, updateDoc, deleteDoc, terminate,
} from 'firebase/firestore';
import {
  getStorage, connectStorageEmulator, ref, uploadBytes, getMetadata,
  getDownloadURL, getBytes, deleteObject,
} from 'firebase/storage';
import { bucket, projectId, requireDemoEmulators, requireLocalDownloadUrl } from './support/emulator-safety.js';

// A direct invocation outside emulators:exec fails here, BEFORE Firebase init.
const endpoints = requireDemoEmulators();
const sessions = [];
function session() {
  requireDemoEmulators();
  const app = initializeApp({ projectId, storageBucket: bucket }, randomUUID());
  const firestore = getFirestore(app);
  const storage = getStorage(app);
  connectFirestoreEmulator(firestore, endpoints.firestore.host, endpoints.firestore.port);
  connectStorageEmulator(storage, endpoints.storage.host, endpoints.storage.port);
  const client = { app, firestore, storage };
  sessions.push(client);
  return client;
}
after(async () => {
  for (const client of sessions) {
    await terminate(client.firestore);
    await deleteApp(client.app);
  }
});

// Schema-only fixture: deliberately NOT an image uploaded by this test.
// It is never fetched and is never used to claim end-to-end publication.
const httpsFixture = `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/media%2Farticles%2Fschema-fixture%2Fthumbnail.png?alt=media`;
function article(thumbnailURL = httpsFixture) {
  return {
    author: 'Symmetry Emulator Test', title: 'Publication persistence fixture',
    description: 'Service integration only; not a Flutter end-to-end test.',
    content: 'Written by an unauthenticated JavaScript SDK client to a demo emulator.',
    thumbnailURL, publishedAt: serverTimestamp(), createdAt: serverTimestamp(), updatedAt: serverTimestamp(),
  };
}
const png = new Uint8Array(Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=', 'base64'));
const uniquePath = () => `media/articles/${randomUUID()}/thumbnail.png`;
const deniedFirestore = (promise) => assert.rejects(promise, { code: 'permission-denied' });
const deniedStorage = (promise) => assert.rejects(promise, { code: 'storage/unauthorized' });

test('Firestore: allocate ID, write eight fields, resolve server dates, read from a fresh client', async () => {
  const writer = session();
  const reference = doc(collection(writer.firestore, 'articles'));
  assert.equal((await getDocFromServer(reference)).exists(), false);
  const data = article();
  await setDoc(reference, data);
  const reader = session();
  const snapshot = await getDocFromServer(doc(reader.firestore, reference.path));
  assert.equal(snapshot.exists(), true);
  assert.equal(snapshot.metadata.fromCache, false);
  assert.equal(snapshot.metadata.hasPendingWrites, false);
  assert.equal(snapshot.id, reference.id);
  const stored = snapshot.data();
  assert.deepEqual(Object.keys(stored).sort(), Object.keys(data).sort());
  for (const field of ['author', 'title', 'description', 'content', 'thumbnailURL']) {
    assert.equal(stored[field], data[field]);
  }
  for (const field of ['publishedAt', 'createdAt', 'updatedAt']) {
    assert.ok(stored[field] instanceof Timestamp);
    assert.ok(Number.isFinite(stored[field].toDate().getTime()));
    assert.ok(stored[field].seconds > 0);
  }
  assert.ok(stored.createdAt.isEqual(stored.updatedAt));
  assert.ok(stored.publishedAt.isEqual(stored.createdAt));
});

test('Firestore: a persisted document remains immutable under client rules', async () => {
  const { firestore } = session();
  const reference = doc(collection(firestore, 'articles'));
  await setDoc(reference, article());
  await deniedFirestore(updateDoc(reference, { title: 'Changed' }));
  await deniedFirestore(deleteDoc(reference));
  assert.equal((await getDocFromServer(reference)).data().title, article().title);
});

for (const [name, change] of [
  ['missing field', (data) => { delete data.content; }],
  ['extra field', (data) => { data.id = 'not-allowed'; }],
  ['wrong type', (data) => { data.author = 42; }],
  ['client timestamp', (data) => { data.createdAt = Timestamp.fromMillis(0); }],
]) {
  test(`Firestore: rejects ${name} and leaves no document`, async () => {
    const { firestore } = session();
    const reference = doc(collection(firestore, 'articles'));
    const data = article();
    change(data);
    await deniedFirestore(setDoc(reference, data));
    assert.equal((await getDocFromServer(reference)).exists(), false);
  });
}

test('Storage: persist path, bytes, MIME and fetch the actual local download URL', async () => {
  const writer = session();
  const path = uniquePath();
  const reference = ref(writer.storage, path);
  await uploadBytes(reference, png, { contentType: 'image/png' });
  const reader = session();
  const persisted = ref(reader.storage, path);
  const metadata = await getMetadata(persisted);
  assert.equal(metadata.fullPath, path);
  assert.equal(metadata.bucket, bucket);
  assert.equal(metadata.contentType, 'image/png');
  assert.equal(metadata.size, png.byteLength);
  assert.deepEqual(new Uint8Array(await getBytes(persisted)), png);
  const url = requireLocalDownloadUrl(await getDownloadURL(persisted));
  assert.equal(decodeURIComponent(url.pathname.split('/o/')[1]), path);
  const response = await fetch(url, { redirect: 'error' });
  assert.equal(response.status, 200);
  assert.equal(response.headers.get('content-type'), 'image/png');
  assert.deepEqual(new Uint8Array(await response.arrayBuffer()), png);
});

test('Storage: a missing object returns object-not-found', async () => {
  const { storage } = session();
  await assert.rejects(getDownloadURL(ref(storage, uniquePath())), { code: 'storage/object-not-found' });
});

test('Storage: rules deny replacement and deletion of an existing image', async () => {
  const { storage } = session();
  const reference = ref(storage, uniquePath());
  await uploadBytes(reference, png, { contentType: 'image/png' });
  await deniedStorage(uploadBytes(reference, png, { contentType: 'image/png' }));
  await deniedStorage(deleteObject(reference));
  assert.deepEqual(new Uint8Array(await getBytes(reference)), png);
});

for (const [name, path, mime] of [
  ['invalid path', () => `other/${randomUUID()}/thumbnail.png`, 'image/png'],
  ['invalid MIME', uniquePath, 'application/pdf'],
]) {
  test(`Storage: rejects ${name}`, async () => {
    const { storage } = session();
    await deniedStorage(uploadBytes(ref(storage, path()), png, { contentType: mime }));
  });
}

test('Cross-service limitation: actual Storage emulator URL is rejected by unchanged Firestore rules', async (context) => {
  const { firestore, storage } = session();
  const document = doc(collection(firestore, 'articles'));
  const path = `media/articles/${document.id}/thumbnail.png`;
  const image = ref(storage, path);
  await uploadBytes(image, png, { contentType: 'image/png' });
  const downloadUrl = await getDownloadURL(image);
  const url = requireLocalDownloadUrl(downloadUrl);
  assert.equal(/^https:\/\/firebasestorage[.]googleapis[.]com\/.*$/.test(downloadUrl), false);
  await deniedFirestore(setDoc(document, article(downloadUrl)));
  assert.equal((await getDocFromServer(document)).exists(), false);
  assert.equal((await getMetadata(image)).fullPath, path);
  context.diagnostic(`Expected incompatibility confirmed: ${url.origin}; image exists, article was rejected. Not an end-to-end publication success.`);
});
