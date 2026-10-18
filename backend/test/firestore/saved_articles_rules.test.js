import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, serverTimestamp, setDoc, Timestamp } from 'firebase/firestore';
import {
  createTestEnvironment, firestoreAs, JOURNALIST, READER, seedArticle, seedUserProfiles,
} from '../test_environment.js';

describe('Firestore rules: saved articles', () => {
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

  const savedArticleRefAs = (user, ownerUid, articleId) =>
    doc(firestoreAs(testEnvironment, user), 'users', ownerUid, 'savedArticles', articleId);

  const saveArticleAs = (user, ownerUid, articleId = 'existing') =>
    setDoc(savedArticleRefAs(user, ownerUid, articleId), { savedAt: serverTimestamp() });

  it('allows a reader to save an article', async () => {
    await assertSucceeds(saveArticleAs(READER, READER.uid));
  });

  it('allows a journalist to save an article', async () => {
    await assertSucceeds(saveArticleAs(JOURNALIST, JOURNALIST.uid));
  });

  it('denies saving an article that does not exist', async () => {
    await assertFails(saveArticleAs(READER, READER.uid, 'missing'));
  });

  it('denies saving into another user list', async () => {
    await assertFails(saveArticleAs(READER, JOURNALIST.uid));
  });

  it('denies saving without signing in', async () => {
    await assertFails(saveArticleAs(null, READER.uid));
  });

  it('denies extra fields', async () => {
    await assertFails(setDoc(savedArticleRefAs(READER, READER.uid, 'existing'), { savedAt: serverTimestamp(), note: 'x' }));
  });

  it('denies a saved date set by the client', async () => {
    await assertFails(setDoc(savedArticleRefAs(READER, READER.uid, 'existing'), { savedAt: Timestamp.now() }));
  });

  it('allows a user to read their saved articles', async () => {
    await saveArticleAs(READER, READER.uid);
    await assertSucceeds(getDoc(savedArticleRefAs(READER, READER.uid, 'existing')));
  });

  it('denies reading another user saved articles', async () => {
    await saveArticleAs(READER, READER.uid);
    await assertFails(getDoc(savedArticleRefAs(JOURNALIST, READER.uid, 'existing')));
  });

  it('allows a user to remove a saved article', async () => {
    await saveArticleAs(READER, READER.uid);
    await assertSucceeds(deleteDoc(savedArticleRefAs(READER, READER.uid, 'existing')));
  });

  it('denies removing another user saved article', async () => {
    await saveArticleAs(READER, READER.uid);
    await assertFails(deleteDoc(savedArticleRefAs(JOURNALIST, READER.uid, 'existing')));
  });
});
