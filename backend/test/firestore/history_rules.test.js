import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, serverTimestamp, setDoc, Timestamp } from 'firebase/firestore';
import {
  createTestEnvironment, firestoreAs, JOURNALIST, READER, seedArticle, seedUserProfiles,
} from '../test_environment.js';

describe('Firestore rules: users/{uid}/history', () => {
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

  const historyEntryRefAs = (user, ownerUid, articleId = 'existing') =>
    doc(firestoreAs(testEnvironment, user), 'users', ownerUid, 'history', articleId);

  const recordViewAs = (user, ownerUid, articleId = 'existing') =>
    setDoc(historyEntryRefAs(user, ownerUid, articleId), { viewedAt: serverTimestamp() });

  it('allows a user to record a viewed article', async () => {
    await assertSucceeds(recordViewAs(READER, READER.uid));
  });

  it('allows a user to record the same article again', async () => {
    await recordViewAs(READER, READER.uid);
    await assertSucceeds(recordViewAs(READER, READER.uid));
  });

  it('denies recording an article that does not exist', async () => {
    await assertFails(recordViewAs(READER, READER.uid, 'missing'));
  });

  it('denies recording into another user history', async () => {
    await assertFails(recordViewAs(READER, JOURNALIST.uid));
  });

  it('denies a view date set by the client', async () => {
    await assertFails(setDoc(historyEntryRefAs(READER, READER.uid), { viewedAt: Timestamp.now() }));
  });

  it('allows a user to read their history', async () => {
    await recordViewAs(READER, READER.uid);
    await assertSucceeds(getDoc(historyEntryRefAs(READER, READER.uid)));
  });

  it('denies reading another user history', async () => {
    await recordViewAs(READER, READER.uid);
    await assertFails(getDoc(historyEntryRefAs(JOURNALIST, READER.uid)));
  });

  it('allows a user to delete a history entry', async () => {
    await recordViewAs(READER, READER.uid);
    await assertSucceeds(deleteDoc(historyEntryRefAs(READER, READER.uid)));
  });
});
