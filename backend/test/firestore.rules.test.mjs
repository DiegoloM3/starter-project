import { readFileSync } from 'node:fs';
import { after, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getCountFromServer,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

const PROJECT_ID = 'demo-symmetry-news';
const ARTICLE_ID = 'Xy7Qp2LmT9aB3cD4eF5g';
const COMMENT_ID = 'Cm4Rt8NpQ2wE6yU1iO3a';
const STORAGE_BUCKET = 'symmetry-news-1d028.firebasestorage.app';
const AUTHOR_ID = 'janeDoeUid';
const AUTHOR_NAME = 'Jane Doe';

const testEnvironment = await initializeTestEnvironment({
  projectId: PROJECT_ID,
  firestore: { rules: readFileSync('firestore.rules', 'utf8') },
});

// The journalist signed in to the app; the token carries the name of the account.
const database = testEnvironment.authenticatedContext(AUTHOR_ID, { name: AUTHOR_NAME }).firestore();
const anonymousDatabase = testEnvironment.unauthenticatedContext().firestore();

function buildThumbnailURL({
  host = 'https://firebasestorage.googleapis.com',
  bucket = STORAGE_BUCKET,
  articleId = ARTICLE_ID,
  folder = 'media%2Farticles',
  extension = 'jpg',
} = {}) {
  return `${host}/v0/b/${bucket}/o/${folder}%2F${articleId}.${extension}`
    + '?alt=media&token=6f1c2a4e-9b3d-4c8e-a1f0-7d2e5b9c3a10';
}

function buildValidArticle(overrides = {}) {
  return {
    title: 'Local startup brings clean water to 10,000 homes',
    description: 'A team of engineers has designed a low-cost filter.',
    content: 'When the first prototype was installed last spring...\n\nIt worked.',
    author: AUTHOR_NAME,
    authorId: AUTHOR_ID,
    thumbnailURL: buildThumbnailURL(),
    publishedAt: serverTimestamp(),
    ...overrides,
  };
}

function createArticle(article, articleId = ARTICLE_ID) {
  return setDoc(doc(database, 'articles', articleId), article);
}

async function seedArticleBypassingRules() {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const articleWithFixedDate = buildValidArticle({ publishedAt: Timestamp.now() });
    await setDoc(doc(context.firestore(), 'articles', ARTICLE_ID), articleWithFixedDate);
  });
}

function buildValidComment(overrides = {}) {
  return {
    content: 'Great news for the rural towns. Will the filters reach the north too?',
    author: AUTHOR_NAME,
    authorId: AUTHOR_ID,
    createdAt: serverTimestamp(),
    ...overrides,
  };
}

function commentsOf(firestore, articleId = ARTICLE_ID) {
  return collection(firestore, 'articles', articleId, 'comments');
}

function createComment(comment, { firestore = database, articleId = ARTICLE_ID, commentId = COMMENT_ID } = {}) {
  return setDoc(doc(commentsOf(firestore, articleId), commentId), comment);
}

async function seedCommentBypassingRules() {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const commentWithFixedDate = buildValidComment({ createdAt: Timestamp.now() });
    await setDoc(doc(commentsOf(context.firestore()), COMMENT_ID), commentWithFixedDate);
  });
}

beforeEach(() => testEnvironment.clearFirestore());
after(() => testEnvironment.cleanup());

describe('articles: read', () => {
  test('a signed-in user can read an article', async () => {
    await seedArticleBypassingRules();
    await assertSucceeds(getDoc(doc(database, 'articles', ARTICLE_ID)));
  });

  test('rejects reading articles without signing in', async () => {
    await seedArticleBypassingRules();
    await assertFails(getDoc(doc(anonymousDatabase, 'articles', ARTICLE_ID)));
  });
});

describe('articles: create', () => {
  test('accepts an article that follows the schema', async () => {
    await assertSucceeds(createArticle(buildValidArticle()));
  });

  for (const host of ['http://127.0.0.1:9199', 'http://localhost:9199', 'http://10.0.2.2:9199']) {
    test(`accepts a thumbnail served by the Storage emulator at ${host}`, async () => {
      const thumbnailURL = buildThumbnailURL({ host });
      await assertSucceeds(createArticle(buildValidArticle({ thumbnailURL })));
    });
  }

  for (const extension of ['jpeg', 'png', 'webp']) {
    test(`accepts a .${extension} thumbnail`, async () => {
      const thumbnailURL = buildThumbnailURL({ extension });
      await assertSucceeds(createArticle(buildValidArticle({ thumbnailURL })));
    });
  }

  test('rejects publishing without signing in', async () => {
    await assertFails(setDoc(doc(anonymousDatabase, 'articles', ARTICLE_ID), buildValidArticle()));
  });

  test('rejects an article published in the name of another account', async () => {
    await assertFails(createArticle(buildValidArticle({ authorId: 'someoneElseUid' })));
  });

  test('rejects an author name that is not the name of the account', async () => {
    await assertFails(createArticle(buildValidArticle({ author: 'John Smith' })));
  });

  test('rejects publishing from an account without a name', async () => {
    const namelessDatabase = testEnvironment.authenticatedContext(AUTHOR_ID).firestore();
    await assertFails(setDoc(doc(namelessDatabase, 'articles', ARTICLE_ID), buildValidArticle()));
  });

  for (const field of ['title', 'description', 'content', 'author', 'authorId', 'thumbnailURL', 'publishedAt']) {
    test(`rejects an article without ${field}`, async () => {
      const article = buildValidArticle();
      delete article[field];
      await assertFails(createArticle(article));
    });
  }

  test('rejects an article with fields outside the schema', async () => {
    await assertFails(createArticle(buildValidArticle({ url: 'https://example.com' })));
  });

  test('rejects an article whose id is not alphanumeric', async () => {
    await assertFails(createArticle(buildValidArticle(), 'not.a-valid_id'));
  });

  const textFieldLimits = { title: 150, description: 300, content: 20000 };

  for (const [field, maxLength] of Object.entries(textFieldLimits)) {
    test(`accepts a ${field} of exactly ${maxLength} characters`, async () => {
      await assertSucceeds(createArticle(buildValidArticle({ [field]: 'a'.repeat(maxLength) })));
    });

    test(`rejects a ${field} longer than ${maxLength} characters`, async () => {
      await assertFails(createArticle(buildValidArticle({ [field]: 'a'.repeat(maxLength + 1) })));
    });

    test(`rejects an empty ${field}`, async () => {
      await assertFails(createArticle(buildValidArticle({ [field]: '' })));
    });

    test(`rejects a ${field} made only of whitespace`, async () => {
      await assertFails(createArticle(buildValidArticle({ [field]: ' \n\t ' })));
    });

    test(`rejects a ${field} that is not a string`, async () => {
      await assertFails(createArticle(buildValidArticle({ [field]: 42 })));
    });
  }

  test('rejects a thumbnail outside media/articles', async () => {
    const thumbnailURL = buildThumbnailURL({ folder: 'media%2Fusers' });
    await assertFails(createArticle(buildValidArticle({ thumbnailURL })));
  });

  test('rejects a thumbnail that belongs to another article', async () => {
    const thumbnailURL = buildThumbnailURL({ articleId: 'AnotherArticleId123' });
    await assertFails(createArticle(buildValidArticle({ thumbnailURL })));
  });

  test('rejects a thumbnail stored in another bucket', async () => {
    const thumbnailURL = buildThumbnailURL({ bucket: 'someone-else.firebasestorage.app' });
    await assertFails(createArticle(buildValidArticle({ thumbnailURL })));
  });

  test('rejects a thumbnail that is not served by Cloud Storage', async () => {
    const thumbnailURL = buildThumbnailURL({ host: 'https://example.com' });
    await assertFails(createArticle(buildValidArticle({ thumbnailURL })));
  });

  test('rejects a thumbnail that is not an image', async () => {
    const thumbnailURL = buildThumbnailURL({ extension: 'pdf' });
    await assertFails(createArticle(buildValidArticle({ thumbnailURL })));
  });

  test('rejects a publication date chosen by the client', async () => {
    await assertFails(createArticle(buildValidArticle({ publishedAt: Timestamp.now() })));
  });
});

describe('articles: update and delete', () => {
  test('rejects updating an article', async () => {
    await seedArticleBypassingRules();
    await assertFails(updateDoc(doc(database, 'articles', ARTICLE_ID), { title: 'Edited' }));
  });

  test('rejects deleting an article', async () => {
    await seedArticleBypassingRules();
    await assertFails(deleteDoc(doc(database, 'articles', ARTICLE_ID)));
  });
});

describe('comments: read', () => {
  beforeEach(async () => {
    await seedArticleBypassingRules();
    await seedCommentBypassingRules();
  });

  test('a signed-in user can read the comments of an article', async () => {
    await assertSucceeds(getDocs(commentsOf(database)));
  });

  test('a signed-in user can count the comments of an article', async () => {
    await assertSucceeds(getCountFromServer(commentsOf(database)));
  });

  test('rejects reading or counting comments without signing in', async () => {
    await assertFails(getDocs(commentsOf(anonymousDatabase)));
    await assertFails(getCountFromServer(commentsOf(anonymousDatabase)));
  });
});

describe('comments: create', () => {
  beforeEach(() => seedArticleBypassingRules());

  test('accepts a comment that follows the schema', async () => {
    await assertSucceeds(createComment(buildValidComment()));
  });

  test('rejects commenting without signing in', async () => {
    await assertFails(createComment(buildValidComment(), { firestore: anonymousDatabase }));
  });

  test('rejects a comment on an article that does not exist', async () => {
    await assertFails(createComment(buildValidComment(), { articleId: 'MissingArticleId123' }));
  });

  test('rejects a comment written in the name of another account', async () => {
    await assertFails(createComment(buildValidComment({ authorId: 'someoneElseUid' })));
  });

  test('rejects an author name that is not the name of the account', async () => {
    await assertFails(createComment(buildValidComment({ author: 'John Smith' })));
  });

  for (const field of ['content', 'author', 'authorId', 'createdAt']) {
    test(`rejects a comment without ${field}`, async () => {
      const comment = buildValidComment();
      delete comment[field];
      await assertFails(createComment(comment));
    });
  }

  test('rejects a comment with fields outside the schema', async () => {
    await assertFails(createComment(buildValidComment({ likes: 3 })));
  });

  test('rejects a comment whose id is not alphanumeric', async () => {
    await assertFails(createComment(buildValidComment(), { commentId: 'not.a-valid_id' }));
  });

  test('accepts a comment of exactly 1000 characters', async () => {
    await assertSucceeds(createComment(buildValidComment({ content: 'a'.repeat(1000) })));
  });

  test('rejects a comment longer than 1000 characters', async () => {
    await assertFails(createComment(buildValidComment({ content: 'a'.repeat(1001) })));
  });

  for (const [description, content] of [['an empty', ''], ['a whitespace-only', ' \n\t '], ['a non-string', 42]]) {
    test(`rejects ${description} comment`, async () => {
      await assertFails(createComment(buildValidComment({ content })));
    });
  }

  test('rejects a comment date chosen by the client', async () => {
    await assertFails(createComment(buildValidComment({ createdAt: Timestamp.now() })));
  });
});

describe('comments: update and delete', () => {
  beforeEach(async () => {
    await seedArticleBypassingRules();
    await seedCommentBypassingRules();
  });

  test('rejects updating a comment', async () => {
    await assertFails(updateDoc(doc(commentsOf(database), COMMENT_ID), { content: 'Edited' }));
  });

  test('rejects deleting a comment', async () => {
    await assertFails(deleteDoc(doc(commentsOf(database), COMMENT_ID)));
  });
});

describe('saved articles', () => {
  const OTHER_USER_ID = 'johnSmithUid';

  function savedArticle(firestore, { userId = AUTHOR_ID, articleId = ARTICLE_ID } = {}) {
    return doc(firestore, 'users', userId, 'savedArticles', articleId);
  }

  async function seedSavedArticleBypassingRules(userId = AUTHOR_ID) {
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await setDoc(savedArticle(context.firestore(), { userId }), { savedAt: Timestamp.now() });
    });
  }

  beforeEach(() => seedArticleBypassingRules());

  test('a journalist can save an article to their own list', async () => {
    await assertSucceeds(setDoc(savedArticle(database), { savedAt: serverTimestamp() }));
  });

  test('a journalist can read and remove their own saved articles', async () => {
    await seedSavedArticleBypassingRules();
    await assertSucceeds(getDocs(collection(database, 'users', AUTHOR_ID, 'savedArticles')));
    await assertSucceeds(getDoc(savedArticle(database)));
    await assertSucceeds(deleteDoc(savedArticle(database)));
  });

  test('rejects saving to the list of another account', async () => {
    await assertFails(setDoc(savedArticle(database, { userId: OTHER_USER_ID }), { savedAt: serverTimestamp() }));
  });

  test('rejects reading or removing the saved articles of another account', async () => {
    await seedSavedArticleBypassingRules(OTHER_USER_ID);
    await assertFails(getDocs(collection(database, 'users', OTHER_USER_ID, 'savedArticles')));
    await assertFails(deleteDoc(savedArticle(database, { userId: OTHER_USER_ID })));
  });

  test('rejects saving or reading without signing in', async () => {
    await assertFails(setDoc(savedArticle(anonymousDatabase), { savedAt: serverTimestamp() }));
    await assertFails(getDoc(savedArticle(anonymousDatabase)));
  });

  test('rejects saving an article that does not exist', async () => {
    const missingArticle = savedArticle(database, { articleId: 'MissingArticleId123' });
    await assertFails(setDoc(missingArticle, { savedAt: serverTimestamp() }));
  });

  test('rejects a saved date chosen by the client', async () => {
    await assertFails(setDoc(savedArticle(database), { savedAt: Timestamp.now() }));
  });

  test('rejects saved articles with fields outside the schema', async () => {
    await assertFails(setDoc(savedArticle(database), { savedAt: serverTimestamp(), title: 'A copy' }));
    await assertFails(setDoc(savedArticle(database), {}));
  });

  test('rejects saving an article that is already saved', async () => {
    await seedSavedArticleBypassingRules();
    await assertFails(setDoc(savedArticle(database), { savedAt: serverTimestamp() }));
  });
});

describe('other collections', () => {
  test('rejects reading and writing documents outside articles', async () => {
    await assertFails(getDoc(doc(database, 'users', AUTHOR_ID)));
    await assertFails(setDoc(doc(database, 'users', AUTHOR_ID), { name: 'Jane' }));
    await assertFails(getDoc(doc(database, 'reports', 'someone')));
  });
});
