import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { Timestamp, doc, serverTimestamp, setDoc, setLogLevel } from 'firebase/firestore';

// Expected PERMISSION_DENIED responses would otherwise be printed as SDK errors.
setLogLevel('silent');

const backendDir = resolve(dirname(fileURLToPath(import.meta.url)), '..');

export const PROJECT_ID = 'news-app-rules-test';
export const BUCKET = 'back-pruebasymmetry.firebasestorage.app';

/** The journalist most tests act as, and somebody else. */
export const AUTHOR_UID = 'journalist-1';
export const OTHER_UID = 'journalist-2';

/**
 * Boots a rules test environment against the running emulators.
 * Host and port are read from the FIRESTORE_EMULATOR_HOST and
 * FIREBASE_STORAGE_EMULATOR_HOST variables that `firebase emulators:exec` exports.
 */
export function createTestEnvironment() {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: readFileSync(resolve(backendDir, 'firestore.rules'), 'utf8') },
    storage: { rules: readFileSync(resolve(backendDir, 'storage.rules'), 'utf8') },
  });
}

/** Download URL of a thumbnail the journalist owns (file names carry the uid). */
export function thumbnailUrlFor(fileName, owner = AUTHOR_UID) {
  const encodedPath = encodeURIComponent(`media/articles/${owner}-${fileName}`);
  return `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${encodedPath}?alt=media&token=test-token`;
}

/** A document that satisfies every constraint in docs/DB_SCHEMA.md. */
export function validArticle(overrides = {}) {
  return {
    title: 'City council approves new bike lanes',
    description: 'Twelve kilometres of protected lanes will be built downtown by 2027.',
    content: 'The city council voted 9-2 on Tuesday to approve the plan.',
    author: 'Nelson Rojas',
    authorId: AUTHOR_UID,
    category: 'general',
    thumbnailURL: thumbnailUrlFor('bike-lanes.jpg'),
    thumbnailPath: `media/articles/${AUTHOR_UID}-bike-lanes.jpg`,
    publishedAt: Timestamp.fromDate(new Date('2026-09-15T10:00:00Z')),
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}

/** Returns a copy of `article` without the given field. */
export function without(article, field) {
  const copy = { ...article };
  delete copy[field];
  return copy;
}

export function stringOfLength(length) {
  return 'x'.repeat(length);
}

/** A tiny but valid-looking payload; rules only inspect contentType and size. */
export function fakeImageBytes(byteLength = 1024) {
  return new Uint8Array(byteLength);
}

/** The article document as seen by the signed-in author. */
export function articleRefAs(testEnv, uid, id = 'article-1') {
  const db = uid == null
    ? testEnv.unauthenticatedContext().firestore()
    : testEnv.authenticatedContext(uid).firestore();
  return doc(db, 'articles', id);
}

/** Writes a valid article bypassing rules, so update/delete tests start from real data. */
export async function seedArticle(testEnv, id = 'article-1', overrides = {}) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'articles', id), {
      ...validArticle(overrides),
      createdAt: Timestamp.fromDate(new Date('2026-09-01T00:00:00Z')),
      updatedAt: Timestamp.fromDate(new Date('2026-09-01T00:00:00Z')),
    });
  });
}
