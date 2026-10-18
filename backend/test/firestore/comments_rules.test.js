import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, serverTimestamp, setDoc, Timestamp, updateDoc } from 'firebase/firestore';
import {
  createTestEnvironment, firestoreAs, fullNameOf, JOURNALIST, READER, seedArticle, seedUserProfiles,
} from '../test_environment.js';

function buildValidComment(author = READER) {
  return {
    authorId: author.uid,
    authorName: fullNameOf(author),
    text: 'Great article!',
    createdAt: serverTimestamp(),
  };
}

describe('Firestore rules: comments', () => {
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

  const commentRefAs = (user, commentId, articleId = 'existing') =>
    doc(firestoreAs(testEnvironment, user), 'articles', articleId, 'comments', commentId);

  const commentAs = (user, comment, articleId = 'existing') =>
    setDoc(commentRefAs(user, 'new', articleId), comment);

  async function seedReaderComment() {
    await setDoc(commentRefAs(READER, 'existing'), buildValidComment());
  }

  describe('create', () => {
    it('allows a reader to comment', async () => {
      await assertSucceeds(commentAs(READER, buildValidComment()));
    });

    it('allows a journalist to comment', async () => {
      await assertSucceeds(commentAs(JOURNALIST, buildValidComment(JOURNALIST)));
    });

    it('denies commenting without signing in', async () => {
      await assertFails(commentAs(null, buildValidComment()));
    });

    it('denies commenting on behalf of another user', async () => {
      await assertFails(commentAs(READER, buildValidComment(JOURNALIST)));
    });

    it('denies an author name different from the profile name', async () => {
      await assertFails(commentAs(READER, { ...buildValidComment(), authorName: 'Admin' }));
    });

    it('denies commenting on an article that does not exist', async () => {
      await assertFails(commentAs(READER, buildValidComment(), 'missing'));
    });

    it('denies an empty comment', async () => {
      await assertFails(commentAs(READER, { ...buildValidComment(), text: '' }));
    });

    it('allows a comment of exactly 500 characters', async () => {
      await assertSucceeds(commentAs(READER, { ...buildValidComment(), text: 'a'.repeat(500) }));
    });

    it('denies a comment longer than 500 characters', async () => {
      await assertFails(commentAs(READER, { ...buildValidComment(), text: 'a'.repeat(501) }));
    });

    it('denies extra fields', async () => {
      await assertFails(commentAs(READER, { ...buildValidComment(), likes: 100 }));
    });

    it('denies a creation date set by the client', async () => {
      await assertFails(commentAs(READER, { ...buildValidComment(), createdAt: Timestamp.now() }));
    });
  });

  describe('read', () => {
    it('allows anyone to read comments, even without signing in', async () => {
      await seedReaderComment();
      await assertSucceeds(getDoc(commentRefAs(null, 'existing')));
    });
  });

  describe('update and delete', () => {
    it('denies editing a comment, even by its author', async () => {
      await seedReaderComment();
      await assertFails(updateDoc(commentRefAs(READER, 'existing'), { text: 'Edited' }));
    });

    it('allows the author to delete their comment', async () => {
      await seedReaderComment();
      await assertSucceeds(deleteDoc(commentRefAs(READER, 'existing')));
    });

    it('denies deleting another user comment', async () => {
      await seedReaderComment();
      await assertFails(deleteDoc(commentRefAs(JOURNALIST, 'existing')));
    });
  });
});
