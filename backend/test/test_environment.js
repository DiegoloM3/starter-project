import { readFileSync } from 'node:fs';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, serverTimestamp, setDoc } from 'firebase/firestore';

export const PROJECT_ID = 'symmetry-technical-test-6230c';
export const STORAGE_BUCKET = `${PROJECT_ID}.firebasestorage.app`;
export const VALID_THUMBNAIL_URL = `https://firebasestorage.googleapis.com/v0/b/${STORAGE_BUCKET}/o/media%2Farticles%2F123.jpg?alt=media&token=abc`;

export const READER = { uid: 'reader', name: 'Reader', email: 'reader@test.com' };
export const JOURNALIST = { uid: 'journalist', name: 'Journalist', email: 'journalist@test.com', role: 'journalist' };
export const OTHER_JOURNALIST = { uid: 'otherJournalist', name: 'Other Journalist', email: 'other@test.com', role: 'journalist' };

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

export function firestoreAs(testEnvironment, user) {
  return contextFor(testEnvironment, user).firestore();
}

export function storageAs(testEnvironment, user) {
  return contextFor(testEnvironment, user).storage(`gs://${STORAGE_BUCKET}`);
}

function contextFor(testEnvironment, user) {
  if (!user) return testEnvironment.unauthenticatedContext();
  const customClaims = user.role ? { role: user.role } : {};
  return testEnvironment.authenticatedContext(user.uid, { email: user.email, ...customClaims });
}

export function buildValidArticle(author = JOURNALIST) {
  return {
    title: 'Title',
    description: 'Description',
    content: 'Content',
    thumbnailURL: VALID_THUMBNAIL_URL,
    publishedAt: serverTimestamp(),
    authorId: author.uid,
    authorName: author.name,
  };
}

export async function seedUserProfiles(testEnvironment) {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    for (const user of [READER, JOURNALIST, OTHER_JOURNALIST]) {
      await setDoc(doc(context.firestore(), 'users', user.uid), {
        name: user.name,
        email: user.email,
        createdAt: serverTimestamp(),
      });
    }
  });
}

export async function seedArticle(testEnvironment, articleId, author = JOURNALIST) {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'articles', articleId), buildValidArticle(author));
  });
}
