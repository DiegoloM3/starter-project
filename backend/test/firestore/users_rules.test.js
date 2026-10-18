import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc, Timestamp, updateDoc } from 'firebase/firestore';
import {
  buildValidProfile, createTestEnvironment, firestoreAs, JOURNALIST, READER, userPhotoURLOf,
} from '../test_environment.js';

describe('Firestore rules: users (public profile)', () => {
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
  const createProfileAs = (user, profile) => setDoc(profileRefAs(user, user?.uid ?? READER.uid), profile);
  const createReaderProfile = () => createProfileAs(READER, buildValidProfile());

  describe('create', () => {
    it('allows a user to create their own profile', async () => {
      await assertSucceeds(createReaderProfile());
    });

    it('allows a profile with a bio and a photo of their own', async () => {
      await assertSucceeds(createProfileAs(READER, { ...buildValidProfile(), bio: 'Hi!', photoURL: userPhotoURLOf(READER) }));
    });

    it('denies creating a profile for another user', async () => {
      await assertFails(setDoc(profileRefAs(READER, JOURNALIST.uid), buildValidProfile(JOURNALIST)));
    });

    it('denies creating a profile without signing in', async () => {
      await assertFails(createProfileAs(null, buildValidProfile()));
    });

    it('denies a user creating their profile as a journalist', async () => {
      await assertFails(createProfileAs(READER, { ...buildValidProfile(), role: 'journalist' }));
    });

    it('denies an empty first name', async () => {
      await assertFails(createProfileAs(READER, { ...buildValidProfile(), firstName: '' }));
    });

    it('denies a last name longer than 40 characters', async () => {
      await assertFails(createProfileAs(READER, { ...buildValidProfile(), lastName: 'a'.repeat(41) }));
    });

    it('denies a bio longer than 300 characters', async () => {
      await assertFails(createProfileAs(READER, { ...buildValidProfile(), bio: 'a'.repeat(301) }));
    });

    it('denies a photo stored in another user folder', async () => {
      await assertFails(createProfileAs(READER, { ...buildValidProfile(), photoURL: userPhotoURLOf(JOURNALIST) }));
    });

    it('denies the email in the public profile', async () => {
      await assertFails(createProfileAs(READER, { ...buildValidProfile(), email: READER.email }));
    });

    it('denies a creation date set by the client', async () => {
      await assertFails(createProfileAs(READER, { ...buildValidProfile(), createdAt: Timestamp.now() }));
    });
  });

  describe('read', () => {
    it('allows anyone to read a profile, even without signing in', async () => {
      await createReaderProfile();
      await assertSucceeds(getDoc(profileRefAs(null, READER.uid)));
    });
  });

  describe('update', () => {
    it('allows a user to edit their name, bio and photo', async () => {
      await createReaderProfile();
      await assertSucceeds(updateDoc(profileRefAs(READER, READER.uid), {
        firstName: 'New', lastName: 'Name', bio: 'New bio', photoURL: userPhotoURLOf(READER),
      }));
    });

    it('denies a user promoting themselves to journalist', async () => {
      await createReaderProfile();
      await assertFails(updateDoc(profileRefAs(READER, READER.uid), { role: 'journalist' }));
    });

    it('denies editing another user profile', async () => {
      await createReaderProfile();
      await assertFails(updateDoc(profileRefAs(JOURNALIST, READER.uid), { bio: 'Hacked' }));
    });

    it('denies an invalid edit', async () => {
      await createReaderProfile();
      await assertFails(updateDoc(profileRefAs(READER, READER.uid), { firstName: '' }));
    });
  });

  describe('delete', () => {
    it('allows a user to delete their own profile', async () => {
      await createReaderProfile();
      await assertSucceeds(deleteDoc(profileRefAs(READER, READER.uid)));
    });

    it('denies deleting another user profile', async () => {
      await createReaderProfile();
      await assertFails(deleteDoc(profileRefAs(JOURNALIST, READER.uid)));
    });
  });
});
