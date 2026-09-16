// Updating and deleting articles, and everything outside the schema.
import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { Timestamp, collection, deleteDoc, doc, getDoc, getDocs, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';
import {
  AUTHOR_UID,
  OTHER_UID,
  articleRefAs,
  createTestEnvironment,
  seedArticle as seed,
  stringOfLength,
  thumbnailUrlFor,
  validArticle,
  without,
} from './helpers.js';

let testEnv;

const articleRef = (id) => articleRefAs(testEnv, AUTHOR_UID, id);
const asOther = (id) => articleRefAs(testEnv, OTHER_UID, id);
const asAnonymous = (id) => articleRefAs(testEnv, null, id);
const seedArticle = (id, overrides) => seed(testEnv, id, overrides);

before(async () => {
  testEnv = await createTestEnvironment();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

describe('articles: update', () => {
  it('allows the author to edit content when updatedAt is refreshed from the server', async () => {
    await seedArticle();
    await assertSucceeds(
      updateDoc(articleRef(), { content: 'Corrected body.', updatedAt: serverTimestamp() }),
    );
  });

  it('allows the author to drop the thumbnail', async () => {
    await seedArticle();
    await assertSucceeds(
      updateDoc(articleRef(), {
        thumbnailURL: null,
        thumbnailPath: null,
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('rejects an update by somebody who is not the author', async () => {
    await seedArticle();
    await assertFails(
      updateDoc(asOther(), { content: 'Vandalised.', updatedAt: serverTimestamp() }),
    );
  });

  it('rejects an update without a signed-in user', async () => {
    await seedArticle();
    await assertFails(
      updateDoc(asAnonymous(), { content: 'Vandalised.', updatedAt: serverTimestamp() }),
    );
  });

  it('rejects handing the article to another author', async () => {
    await seedArticle();
    await assertFails(
      updateDoc(articleRef(), { authorId: OTHER_UID, updatedAt: serverTimestamp() }),
    );
  });

  it('rejects an update that does not refresh updatedAt', async () => {
    await seedArticle();
    await assertFails(updateDoc(articleRef(), { content: 'Corrected body.' }));
  });

  it('rejects an update that changes createdAt', async () => {
    await seedArticle();
    await assertFails(
      updateDoc(articleRef(), {
        createdAt: Timestamp.fromDate(new Date('2030-01-01')),
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('rejects an update that breaks a schema constraint', async () => {
    await seedArticle();
    await assertFails(
      updateDoc(articleRef(), { title: stringOfLength(151), updatedAt: serverTimestamp() }),
    );
  });

  it('rejects an update that adds an unknown field', async () => {
    await seedArticle();
    await assertFails(updateDoc(articleRef(), { views: 1, updatedAt: serverTimestamp() }));
  });
});

describe('articles: delete', () => {
  it('allows the author to delete their article', async () => {
    await seedArticle();
    await assertSucceeds(deleteDoc(articleRef()));
  });

  it('rejects a delete by somebody else or by an anonymous caller', async () => {
    await seedArticle();
    await assertFails(deleteDoc(asOther()));
    await assertFails(deleteDoc(asAnonymous()));
  });
});

describe('other collections', () => {
  it('denies writes to collections that are not part of the schema', async () => {
    const db = testEnv.authenticatedContext(AUTHOR_UID).firestore();
    await assertFails(setDoc(doc(db, 'users', 'u1'), { name: 'Mallory' }));
  });

  it('denies reads from collections that are not part of the schema', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'users', 'u1')));
  });
});
