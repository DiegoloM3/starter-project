import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, serverTimestamp, setDoc, Timestamp, updateDoc } from 'firebase/firestore';
import {
  createTestEnvironment, firestoreAs, JOURNALIST, OTHER_JOURNALIST, READER, seedUserProfiles,
} from '../test_environment.js';

const followIdOf = (follower, followed) => `${follower.uid}_${followed.uid}`;
const UNREGISTERED_USER = { uid: 'unregistered' };

function buildValidFollow(follower = READER, followed = JOURNALIST) {
  return { followerId: follower.uid, followedId: followed.uid, createdAt: serverTimestamp() };
}

describe('Firestore rules: follows', () => {
  let testEnvironment;

  before(async () => {
    testEnvironment = await createTestEnvironment();
  });

  beforeEach(async () => {
    await testEnvironment.clearFirestore();
    await seedUserProfiles(testEnvironment);
  });

  after(async () => {
    await testEnvironment.cleanup();
  });

  const followRefAs = (user, followId) => doc(firestoreAs(testEnvironment, user), 'follows', followId);

  const followAs = (follower, followed, follow = buildValidFollow(follower, followed)) =>
    setDoc(followRefAs(follower, followIdOf(follower, followed)), follow);

  it('allows a reader to follow a journalist', async () => {
    await assertSucceeds(followAs(READER, JOURNALIST));
  });

  it('allows a journalist to follow another journalist', async () => {
    await assertSucceeds(followAs(JOURNALIST, OTHER_JOURNALIST));
  });

  it('allows following a reader', async () => {
    await assertSucceeds(followAs(JOURNALIST, READER));
  });

  it('denies following a user that does not exist', async () => {
    await assertFails(followAs(READER, UNREGISTERED_USER));
  });

  it('denies following yourself', async () => {
    await assertFails(followAs(JOURNALIST, JOURNALIST));
  });

  it('denies following without signing in', async () => {
    await assertFails(setDoc(followRefAs(null, followIdOf(READER, JOURNALIST)), buildValidFollow()));
  });

  it('denies following on behalf of another user', async () => {
    await assertFails(setDoc(followRefAs(OTHER_JOURNALIST, followIdOf(READER, JOURNALIST)), buildValidFollow()));
  });

  it('denies a document id that does not match the follow', async () => {
    await assertFails(setDoc(followRefAs(READER, 'random-id'), buildValidFollow()));
  });

  it('denies a follow date set by the client', async () => {
    await assertFails(followAs(READER, JOURNALIST, { ...buildValidFollow(), createdAt: Timestamp.now() }));
  });

  it('allows anyone to read follows, so followers can be counted', async () => {
    await followAs(READER, JOURNALIST);
    await assertSucceeds(getDoc(followRefAs(null, followIdOf(READER, JOURNALIST))));
  });

  it('denies editing a follow', async () => {
    await followAs(READER, JOURNALIST);
    await assertFails(updateDoc(followRefAs(READER, followIdOf(READER, JOURNALIST)), { followedId: OTHER_JOURNALIST.uid }));
  });

  it('allows the follower to unfollow', async () => {
    await followAs(READER, JOURNALIST);
    await assertSucceeds(deleteDoc(followRefAs(READER, followIdOf(READER, JOURNALIST))));
  });

  it('denies removing another user follow', async () => {
    await followAs(READER, JOURNALIST);
    await assertFails(deleteDoc(followRefAs(JOURNALIST, followIdOf(READER, JOURNALIST))));
  });
});
