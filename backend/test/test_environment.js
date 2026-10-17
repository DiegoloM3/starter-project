import { readFileSync } from 'node:fs';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

export const PROJECT_ID = 'symmetry-technical-test-6230c';
export const STORAGE_BUCKET = `${PROJECT_ID}.firebasestorage.app`;

export function createTestEnvironment() {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
    storage: {
      rules: readFileSync(new URL('../storage.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 9199,
    },
  });
}
