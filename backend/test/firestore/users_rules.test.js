import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, serverTimestamp, setDoc, Timestamp, updateDoc } from 'firebase/firestore';
import { createTestEnvironment, firestoreAs, JOURNALIST, READER } from '../test_environment.js';

function buildValidProfile(user = READER) {
  return { name: user.name, email: user.email, createdAt: serverTimestamp() };
}

describe('Firestore rules: users', () => {
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

  const profileRefAs = (user, uid) => doc(firestoreAs(testEnvironment, user), 'users', uid);

  async function createReaderProfile() {
    await setDoc(profileRefAs(READER, READER.uid), buildValidProfile());
  }

  describe('create', () => {
    it('allows a user to create their own profile', async () => {
      await assertSucceeds(createReaderProfile());
    });

    it('denies creating a profile for another user', async () => {
      await assertFails(setDoc(profileRefAs(READER, JOURNALIST.uid), buildValidProfile(JOURNALIST)));
    });

    it('denies creating a profile without signing in', async () => {
      await assertFails(setDoc(profileRefAs(null, READER.uid), buildValidProfile()));
    });

    it('denies a user granting themselves a role', async () => {
      await assertFails(setDoc(profileRefAs(READER, READER.uid), { ...buildValidProfile(), role: 'journalist' }));
    });

    it('denies an email different from the signed in account', async () => {
      await assertFails(setDoc(profileRefAs(READER, READER.uid), { ...buildValidProfile(), email: 'fake@test.com' }));
    });

    it('denies an empty name', async () => {
      await assertFails(setDoc(profileRefAs(READER, READER.uid), { ...buildValidProfile(), name: '' }));
    });

    it('denies a name longer than 80 characters', async () => {
      await assertFails(setDoc(profileRefAs(READER, READER.uid), { ...buildValidProfile(), name: 'a'.repeat(81) }));
    });

    it('denies a creation date set by the client', async () => {
      await assertFails(setDoc(profileRefAs(READER, READER.uid), { ...buildValidProfile(), createdAt: Timestamp.now() }));
    });
  });

  describe('read', () => {
    it('allows a user to read their own profile', async () => {
      await createReaderProfile();
      await assertSucceeds(getDoc(profileRefAs(READER, READER.uid)));
    });

    it('denies a user reading another user profile', async () => {
      await createReaderProfile();
      await assertFails(getDoc(profileRefAs(JOURNALIST, READER.uid)));
    });
  });

  describe('update and delete', () => {
    it('allows a user to change their name', async () => {
      await createReaderProfile();
      await assertSucceeds(updateDoc(profileRefAs(READER, READER.uid), { name: 'New name' }));
    });

    it('denies a user changing their email', async () => {
      await createReaderProfile();
      await assertFails(updateDoc(profileRefAs(READER, READER.uid), { email: 'new@test.com' }));
    });

    it('denies a user adding a role to their profile', async () => {
      await createReaderProfile();
      await assertFails(updateDoc(profileRefAs(READER, READER.uid), { role: 'journalist' }));
    });

    it('denies deleting a profile', async () => {
      await createReaderProfile();
      await assertFails(deleteDoc(profileRefAs(READER, READER.uid)));
    });
  });
});
