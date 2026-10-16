import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from 'firebase/firestore';
import { createTestEnvironment } from './test_environment.mjs';

const ARTICLE_ID = 'article123';

function buildValidArticle(overrides = {}) {
  return {
    title: 'Breaking News!',
    content: 'This is breaking news!',
    thumbnailURL: `media/articles/${ARTICLE_ID}.jpg`,
    publishedAt: serverTimestamp(),
    ...overrides,
  };
}

describe('Firestore rules: articles', () => {
  let testEnvironment;
  let database;

  before(async () => {
    testEnvironment = await createTestEnvironment();
  });

  beforeEach(async () => {
    await testEnvironment.clearFirestore();
    database = testEnvironment.unauthenticatedContext().firestore();
  });

  after(async () => {
    await testEnvironment.cleanup();
  });

  function getArticleReference(articleId = ARTICLE_ID) {
    return doc(database, 'articles', articleId);
  }

  async function seedArticle() {
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'articles', ARTICLE_ID), buildValidArticle());
    });
  }

  it('allows anyone to read an article', async () => {
    await seedArticle();
    await assertSucceeds(getDoc(getArticleReference()));
  });

  it('allows creating an article that matches the schema', async () => {
    await assertSucceeds(setDoc(getArticleReference(), buildValidArticle()));
  });

  it('accepts every allowed thumbnail extension', async () => {
    for (const extension of ['jpeg', 'png', 'webp']) {
      const articleId = `article${extension}`;
      const article = buildValidArticle({ thumbnailURL: `media/articles/${articleId}.${extension}` });
      await assertSucceeds(setDoc(getArticleReference(articleId), article));
    }
  });

  it('accepts a title of exactly 100 characters', async () => {
    await assertSucceeds(setDoc(getArticleReference(), buildValidArticle({ title: 'a'.repeat(100) })));
  });

  it('accepts a content of exactly 5000 characters', async () => {
    await assertSucceeds(setDoc(getArticleReference(), buildValidArticle({ content: 'a'.repeat(5000) })));
  });

  it('rejects an article with a missing field', async () => {
    const { content, ...articleWithoutContent } = buildValidArticle();
    await assertFails(setDoc(getArticleReference(), articleWithoutContent));
  });

  it('rejects an article with an unknown field', async () => {
    await assertFails(setDoc(getArticleReference(), buildValidArticle({ author: 'Anonymous' })));
  });

  it('rejects a blank title', async () => {
    await assertFails(setDoc(getArticleReference(), buildValidArticle({ title: '   ' })));
  });

  it('rejects a title longer than 100 characters', async () => {
    await assertFails(setDoc(getArticleReference(), buildValidArticle({ title: 'a'.repeat(101) })));
  });

  it('rejects a title that is not a string', async () => {
    await assertFails(setDoc(getArticleReference(), buildValidArticle({ title: 42 })));
  });

  it('rejects a blank content', async () => {
    await assertFails(setDoc(getArticleReference(), buildValidArticle({ content: '' })));
  });

  it('rejects a content longer than 5000 characters', async () => {
    await assertFails(setDoc(getArticleReference(), buildValidArticle({ content: 'a'.repeat(5001) })));
  });

  it('rejects a thumbnail outside the media/articles folder', async () => {
    const article = buildValidArticle({ thumbnailURL: `media/other/${ARTICLE_ID}.jpg` });
    await assertFails(setDoc(getArticleReference(), article));
  });

  it('rejects a thumbnail that belongs to another article', async () => {
    const article = buildValidArticle({ thumbnailURL: 'media/articles/anotherArticle.jpg' });
    await assertFails(setDoc(getArticleReference(), article));
  });

  it('rejects a thumbnail with an unsupported extension', async () => {
    const article = buildValidArticle({ thumbnailURL: `media/articles/${ARTICLE_ID}.gif` });
    await assertFails(setDoc(getArticleReference(), article));
  });

  it('rejects a full download URL instead of a storage path', async () => {
    const article = buildValidArticle({
      thumbnailURL: `https://firebasestorage.googleapis.com/media/articles/${ARTICLE_ID}.jpg`,
    });
    await assertFails(setDoc(getArticleReference(), article));
  });

  it('rejects a publication date chosen by the client', async () => {
    const article = buildValidArticle({ publishedAt: Timestamp.fromDate(new Date('2020-01-01')) });
    await assertFails(setDoc(getArticleReference(), article));
  });

  it('rejects updating an article', async () => {
    await seedArticle();
    await assertFails(updateDoc(getArticleReference(), { title: 'Edited title' }));
  });

  it('rejects deleting an article', async () => {
    await seedArticle();
    await assertFails(deleteDoc(getArticleReference()));
  });

  it('rejects writing to any other collection', async () => {
    await assertFails(setDoc(doc(database, 'users', 'someone'), { name: 'Someone' }));
  });
});
