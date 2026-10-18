import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';
import { createTestEnvironment, firestoreAs, JOURNALIST, READER } from '../test_environment.js';

function buildValidAccount(user = READER) {
  return { email: user.email, notificationsEnabled: true };
}

describe('Firestore rules: users/{uid}/private/account', () => {
  let testEnvironment;

  before(async () => {
    testEnvironment = await createTestEnvironment();
  });

  beforeEach(async () => {
    await testEnvironment.clearFirestore();
  });

  after(async () => {
    await testEnvironment.cleanup();
  });

  const accountRefAs = (user, uid, documentId = 'account') =>
    doc(firestoreAs(testEnvironment, user), 'users', uid, 'private', documentId);

  const createReaderAccount = () => setDoc(accountRefAs(READER, READER.uid), buildValidAccount());

  it('allows a user to create their private account data', async () => {
    await assertSucceeds(createReaderAccount());
  });

  it('denies a private document with another id', async () => {
    await assertFails(setDoc(accountRefAs(READER, READER.uid, 'other'), buildValidAccount()));
  });

  it('denies an email different from the signed in account', async () => {
    await assertFails(setDoc(accountRefAs(READER, READER.uid), { ...buildValidAccount(), email: 'fake@test.com' }));
  });

  it('denies a notifications preference that is not a boolean', async () => {
    await assertFails(setDoc(accountRefAs(READER, READER.uid), { ...buildValidAccount(), notificationsEnabled: 'yes' }));
  });

  it('denies creating private data for another user', async () => {
    await assertFails(setDoc(accountRefAs(READER, JOURNALIST.uid), buildValidAccount(JOURNALIST)));
  });

  it('allows a user to read their private data', async () => {
    await createReaderAccount();
    await assertSucceeds(getDoc(accountRefAs(READER, READER.uid)));
  });

  it('denies reading another user private data', async () => {
    await createReaderAccount();
    await assertFails(getDoc(accountRefAs(JOURNALIST, READER.uid)));
  });

  it('allows a user to toggle notifications', async () => {
    await createReaderAccount();
    await assertSucceeds(updateDoc(accountRefAs(READER, READER.uid), { notificationsEnabled: false }));
  });

  it('denies a user changing their stored email', async () => {
    await createReaderAccount();
    await assertFails(updateDoc(accountRefAs(READER, READER.uid), { email: 'new@test.com' }));
  });

  it('allows a user to delete their private data', async () => {
    await createReaderAccount();
    await assertSucceeds(deleteDoc(accountRefAs(READER, READER.uid)));
  });
});
