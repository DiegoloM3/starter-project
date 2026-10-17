import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  deleteDoc, doc, getDoc, serverTimestamp, setDoc, Timestamp, updateDoc,
} from 'firebase/firestore';
import { createTestEnvironment, STORAGE_BUCKET } from './test_environment.js';

const VALID_THUMBNAIL_URL = `https://firebasestorage.googleapis.com/v0/b/${STORAGE_BUCKET}/o/media%2Farticles%2F123.jpg?alt=media&token=abc`;

function buildValidArticle() {
  return {
    title: 'Title',
    description: 'Description',
    content: 'Content',
    authorName: 'Jane Doe',
    thumbnailURL: VALID_THUMBNAIL_URL,
    publishedAt: serverTimestamp(),
  };
}

describe('Firestore rules: articles', () => {
  let testEnvironment;
  let firestore;

  before(async () => {
    testEnvironment = await createTestEnvironment();
  });

  beforeEach(async () => {
    await testEnvironment.clearFirestore();
    firestore = testEnvironment.unauthenticatedContext().firestore();
  });

  after(async () => {
    await testEnvironment.cleanup();
  });

  const articleRef = (articleId) => doc(firestore, 'articles', articleId);

  async function createExistingArticle() {
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'articles', 'existing'), buildValidArticle());
    });
  }

  it('allows creating a valid article', async () => {
    await assertSucceeds(setDoc(articleRef('new'), buildValidArticle()));
  });

  it('allows reading articles', async () => {
    await createExistingArticle();
    await assertSucceeds(getDoc(articleRef('existing')));
  });

  it('denies updating an article', async () => {
    await createExistingArticle();
    await assertFails(updateDoc(articleRef('existing'), { title: 'Changed' }));
  });

  it('denies deleting an article', async () => {
    await createExistingArticle();
    await assertFails(deleteDoc(articleRef('existing')));
  });

  it('denies an article with extra fields', async () => {
    await assertFails(setDoc(articleRef('new'), { ...buildValidArticle(), extraField: true }));
  });

  it('denies an article with missing fields', async () => {
    const { content, ...articleWithoutContent } = buildValidArticle();
    await assertFails(setDoc(articleRef('new'), articleWithoutContent));
  });

  it('denies an empty title', async () => {
    await assertFails(setDoc(articleRef('new'), { ...buildValidArticle(), title: '' }));
  });

  it('allows a title of exactly 150 characters', async () => {
    await assertSucceeds(setDoc(articleRef('new'), { ...buildValidArticle(), title: 'a'.repeat(150) }));
  });

  it('denies a title longer than 150 characters', async () => {
    await assertFails(setDoc(articleRef('new'), { ...buildValidArticle(), title: 'a'.repeat(151) }));
  });

  it('denies a title that is not a string', async () => {
    await assertFails(setDoc(articleRef('new'), { ...buildValidArticle(), title: 5 }));
  });

  it('denies a publication date set by the client', async () => {
    await assertFails(setDoc(articleRef('new'), { ...buildValidArticle(), publishedAt: Timestamp.now() }));
  });

  it('denies a thumbnail hosted outside Firebase Storage', async () => {
    await assertFails(setDoc(articleRef('new'), { ...buildValidArticle(), thumbnailURL: 'https://example.com/image.jpg' }));
  });

  it('denies a thumbnail from another bucket', async () => {
    const otherBucketURL = VALID_THUMBNAIL_URL.replace(STORAGE_BUCKET, 'other-project.firebasestorage.app');
    await assertFails(setDoc(articleRef('new'), { ...buildValidArticle(), thumbnailURL: otherBucketURL }));
  });

  it('denies a thumbnail outside the media/articles folder', async () => {
    const otherFolderURL = VALID_THUMBNAIL_URL.replace('media%2Farticles', 'media%2Fusers');
    await assertFails(setDoc(articleRef('new'), { ...buildValidArticle(), thumbnailURL: otherFolderURL }));
  });

  it('denies writing to any other collection', async () => {
    await assertFails(setDoc(doc(firestore, 'users', 'someone'), { name: 'Someone' }));
  });
});
