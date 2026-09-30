import { randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { serverTimestamp, setLogLevel } from 'firebase/firestore';

// Denied writes are expected in these tests; don't flood the output with SDK warnings.
setLogLevel('silent');

export const PROJECT_ID = 'backend-news-symmetry';
export const BUCKET = `${PROJECT_ID}.firebasestorage.app`;

const ID_ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

export function createTestEnvironment() {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { host: '127.0.0.1', port: 8080, rules: readFileSync('firestore.rules', 'utf8') },
    storage: { host: '127.0.0.1', port: 9199, rules: readFileSync('storage.rules', 'utf8') },
  });
}

// Same shape as a Firestore auto-generated document id.
export function newArticleId() {
  return Array.from({ length: 20 }, () => ID_ALPHABET[Math.floor(Math.random() * ID_ALPHABET.length)]).join('');
}

export function thumbnailURLFor(articleId, { host = 'https://firebasestorage.googleapis.com', extension = 'jpg' } = {}) {
  return `${host}/v0/b/${BUCKET}/o/media%2Farticles%2F${articleId}.${extension}?alt=media&token=${randomUUID()}`;
}

export function validArticle(articleId) {
  return {
    title: 'Breaking News!',
    content: '## Subtitle\n\nThis is **breaking** news.',
    description: 'Subtitle This is breaking news.',
    author: 'Daily News Staff',
    thumbnailURL: thumbnailURLFor(articleId),
    publishedAt: serverTimestamp(),
  };
}
