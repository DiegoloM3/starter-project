import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, serverTimestamp, setDoc, Timestamp, updateDoc } from 'firebase/firestore';
import {
  buildValidArticle, createTestEnvironment, firestoreAs, JOURNALIST, OTHER_JOURNALIST, READER,
  seedArticle, seedUserProfiles, STORAGE_BUCKET, VALID_THUMBNAIL_URL,
} from '../test_environment.js';

describe('Firestore rules: articles', () => {
  let testEnvironment;

  before(async () => {
    testEnvironment = await createTestEnvironment();
  });

  beforeEach(async () => {
    await testEnvironment.clearFirestore();
    await seedUserProfiles(testEnvironment);
    await seedArticle(testEnvironment, 'existing');
  });

  after(async () => {
    await testEnvironment.cleanup();
  });

  const articleRefAs = (user, articleId) => doc(firestoreAs(testEnvironment, user), 'articles', articleId);
  const createArticleAs = (user, article) => setDoc(articleRefAs(user, 'new'), article);

  describe('read', () => {
    it('allows anyone to read articles, even without signing in', async () => {
      await assertSucceeds(getDoc(articleRefAs(null, 'existing')));
    });
  });

  describe('create', () => {
    it('allows a journalist to publish a valid article', async () => {
      await assertSucceeds(createArticleAs(JOURNALIST, buildValidArticle()));
    });

    it('denies a reader publishing an article', async () => {
      await assertFails(createArticleAs(READER, buildValidArticle(READER)));
    });

    it('denies publishing without signing in', async () => {
      await assertFails(createArticleAs(null, buildValidArticle()));
    });

    it('denies a journalist publishing on behalf of another journalist', async () => {
      await assertFails(createArticleAs(JOURNALIST, buildValidArticle(OTHER_JOURNALIST)));
    });

    it('denies an author name different from the journalist profile name', async () => {
      await assertFails(createArticleAs(JOURNALIST, { ...buildValidArticle(), authorName: 'Famous Writer' }));
    });

    it('denies an article with extra fields', async () => {
      await assertFails(createArticleAs(JOURNALIST, { ...buildValidArticle(), extraField: true }));
    });

    it('denies an article with missing fields', async () => {
      const { content, ...articleWithoutContent } = buildValidArticle();
      await assertFails(createArticleAs(JOURNALIST, articleWithoutContent));
    });

    it('denies an empty title', async () => {
      await assertFails(createArticleAs(JOURNALIST, { ...buildValidArticle(), title: '' }));
    });

    it('allows a title of exactly 150 characters', async () => {
      await assertSucceeds(createArticleAs(JOURNALIST, { ...buildValidArticle(), title: 'a'.repeat(150) }));
    });

    it('denies a title longer than 150 characters', async () => {
      await assertFails(createArticleAs(JOURNALIST, { ...buildValidArticle(), title: 'a'.repeat(151) }));
    });

    it('denies a title that is not a string', async () => {
      await assertFails(createArticleAs(JOURNALIST, { ...buildValidArticle(), title: 5 }));
    });

    it('denies a publication date set by the client', async () => {
      await assertFails(createArticleAs(JOURNALIST, { ...buildValidArticle(), publishedAt: Timestamp.now() }));
    });

    it('denies a thumbnail hosted outside Firebase Storage', async () => {
      await assertFails(createArticleAs(JOURNALIST, { ...buildValidArticle(), thumbnailURL: 'https://example.com/image.jpg' }));
    });

    it('denies a thumbnail from another bucket', async () => {
      const otherBucketURL = VALID_THUMBNAIL_URL.replace(STORAGE_BUCKET, 'other-project.firebasestorage.app');
      await assertFails(createArticleAs(JOURNALIST, { ...buildValidArticle(), thumbnailURL: otherBucketURL }));
    });

    it('denies a thumbnail outside the media/articles folder', async () => {
      const otherFolderURL = VALID_THUMBNAIL_URL.replace('media%2Farticles', 'media%2Fusers');
      await assertFails(createArticleAs(JOURNALIST, { ...buildValidArticle(), thumbnailURL: otherFolderURL }));
    });
  });

  describe('update', () => {
    const updateArticleAs = (user, changes) => updateDoc(articleRefAs(user, 'existing'), changes);

    it('allows the author to edit the title, description, content and thumbnail', async () => {
      await assertSucceeds(updateArticleAs(JOURNALIST, {
        title: 'New title',
        description: 'New description',
        content: 'New content',
        thumbnailURL: VALID_THUMBNAIL_URL.replace('123.jpg', '456.jpg'),
      }));
    });

    it('denies the author an invalid edit', async () => {
      await assertFails(updateArticleAs(JOURNALIST, { title: '' }));
    });

    it('denies the author changing the authorship', async () => {
      await assertFails(updateArticleAs(JOURNALIST, { authorId: OTHER_JOURNALIST.uid }));
    });

    it('denies the author changing the publication date', async () => {
      await assertFails(updateArticleAs(JOURNALIST, { publishedAt: serverTimestamp() }));
    });

    it('denies another journalist editing the article', async () => {
      await assertFails(updateArticleAs(OTHER_JOURNALIST, { title: 'New title' }));
    });

    it('denies a reader editing the article', async () => {
      await assertFails(updateArticleAs(READER, { title: 'New title' }));
    });
  });

  describe('delete', () => {
    it('allows the author to delete the article', async () => {
      await assertSucceeds(deleteDoc(articleRefAs(JOURNALIST, 'existing')));
    });

    it('denies another journalist deleting the article', async () => {
      await assertFails(deleteDoc(articleRefAs(OTHER_JOURNALIST, 'existing')));
    });

    it('denies a reader deleting the article', async () => {
      await assertFails(deleteDoc(articleRefAs(READER, 'existing')));
    });
  });

  describe('other collections', () => {
    it('denies writing to an unknown collection', async () => {
      await assertFails(setDoc(doc(firestoreAs(testEnvironment, JOURNALIST), 'unknown', 'doc'), { field: 1 }));
    });
  });
});
