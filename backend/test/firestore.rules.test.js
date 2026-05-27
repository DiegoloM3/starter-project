const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const { readFileSync } = require('fs');
const { resolve } = require('path');

const PROJECT_ID = 'symmetry-news-app-46777';

let testEnv;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function getFirestore(auth) {
  if (auth) {
    return testEnv.authenticatedContext(auth.uid, auth.token || {}).firestore();
  }
  return testEnv.unauthenticatedContext().firestore();
}

function articleRef(db, id) {
  return db.collection('articles').doc(id || 'article-1');
}

function commentRef(db, articleId, commentId) {
  return db
    .collection('articles')
    .doc(articleId || 'article-1')
    .collection('comments')
    .doc(commentId || 'comment-1');
}

function savedArticleRef(db, uid, articleId) {
  return db
    .collection('users')
    .doc(uid)
    .collection('savedArticles')
    .doc(articleId || 'article-1');
}

function serverTimestamp() {
  // The modular SDK re-exported by rules-unit-testing
  const { serverTimestamp: st } = require('firebase/firestore');
  return st();
}

function validArticleData(overrides) {
  return {
    id: 'article-1',
    title: 'Test Article Title',
    description: 'A short description of the article',
    content: 'Full article content goes here with enough words.',
    authorId: 'user-1',
    authorName: 'Test Author',
    thumbnailUrl: '',
    thumbnailPath: '',
    publishedAt: null,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    status: 'draft',
    isDeleted: false,
    readingTimeMinutes: 3,
    ...overrides,
  };
}

function validCommentData(overrides) {
  return {
    id: 'comment-1',
    articleId: 'article-1',
    authorId: 'user-1',
    authorName: 'Test Author',
    content: 'This is a test comment.',
    createdAt: serverTimestamp(),
    isDeleted: false,
    ...overrides,
  };
}

async function seedArticle(data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await db
      .collection('articles')
      .doc(data.id || 'article-1')
      .set({
        id: 'article-1',
        title: 'Seeded Article',
        description: 'Seeded description',
        content: 'Seeded content body',
        authorId: 'user-1',
        authorName: 'Test Author',
        thumbnailUrl: '',
        thumbnailPath: '',
        publishedAt: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        status: 'draft',
        isDeleted: false,
        readingTimeMinutes: 2,
        ...data,
      });
  });
}

async function seedComment(data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await db
      .collection('articles')
      .doc(data.articleId || 'article-1')
      .collection('comments')
      .doc(data.id || 'comment-1')
      .set({
        id: 'comment-1',
        articleId: 'article-1',
        authorId: 'user-1',
        authorName: 'Test Author',
        content: 'Seeded comment content',
        createdAt: new Date(),
        isDeleted: false,
        ...data,
      });
  });
}

// ---------------------------------------------------------------------------
// Setup / Teardown
// ---------------------------------------------------------------------------

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(resolve(__dirname, '../firestore.rules'), 'utf8'),
      host: 'localhost',
      port: 8080,
    },
  });
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

// ===========================================================================
// ARTICLES
// ===========================================================================

describe('Articles — Authentication', () => {
  it('denies unauthenticated read', async () => {
    await seedArticle({});
    const db = getFirestore(null);
    await assertFails(articleRef(db).get());
  });

  it('denies unauthenticated create', async () => {
    const db = getFirestore(null);
    await assertFails(articleRef(db).set(validArticleData()));
  });

  it('allows authenticated read', async () => {
    await seedArticle({});
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(articleRef(db).get());
  });
});

describe('Articles — Create', () => {
  it('allows creating article with valid data', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(articleRef(db).set(validArticleData()));
  });

  it('denies create with missing title', async () => {
    const db = getFirestore({ uid: 'user-1' });
    const data = validArticleData();
    delete data.title;
    await assertFails(articleRef(db).set(data));
  });

  it('denies create with missing content', async () => {
    const db = getFirestore({ uid: 'user-1' });
    const data = validArticleData();
    delete data.content;
    await assertFails(articleRef(db).set(data));
  });

  it('denies create with missing authorId', async () => {
    const db = getFirestore({ uid: 'user-1' });
    const data = validArticleData();
    delete data.authorId;
    await assertFails(articleRef(db).set(data));
  });

  it('denies create with extra fields', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ extraField: 'not allowed' }))
    );
  });

  it('denies create with numeric title (wrong type)', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(articleRef(db).set(validArticleData({ title: 123 })));
  });

  it('denies create with string isDeleted (wrong type)', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ isDeleted: 'no' }))
    );
  });

  it('denies create with string readingTimeMinutes (wrong type)', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ readingTimeMinutes: 'five' }))
    );
  });

  it('denies title over 200 characters', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ title: 'x'.repeat(201) }))
    );
  });

  it('allows title at exactly 200 characters', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(
      articleRef(db).set(validArticleData({ title: 'x'.repeat(200) }))
    );
  });

  it('denies empty title', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(articleRef(db).set(validArticleData({ title: '' })));
  });

  it('denies description over 500 characters', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ description: 'x'.repeat(501) }))
    );
  });

  it('denies content over 50000 characters', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ content: 'x'.repeat(50001) }))
    );
  });

  it('denies readingTimeMinutes less than 1', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ readingTimeMinutes: 0 }))
    );
  });
});

describe('Articles — Ownership on Create', () => {
  it('denies create with authorId != auth.uid', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ authorId: 'user-2' }))
    );
  });

  it('denies create with id != document ID', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db, 'article-1').set(validArticleData({ id: 'wrong-id' }))
    );
  });
});

describe('Articles — Create Constraints', () => {
  it('denies create with status != draft', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ status: 'published' }))
    );
  });

  it('denies create with isDeleted = true', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ isDeleted: true }))
    );
  });

  it('denies create with non-null publishedAt', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).set(validArticleData({ publishedAt: serverTimestamp() }))
    );
  });
});

describe('Articles — Update', () => {
  it('allows owner to update article with valid data', async () => {
    await seedArticle({});
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(
      articleRef(db).update({
        title: 'Updated Title',
        description: 'Updated description',
        content: 'Updated content body',
        authorName: 'Test Author',
        thumbnailUrl: '',
        thumbnailPath: '',
        publishedAt: null,
        updatedAt: serverTimestamp(),
        status: 'draft',
        isDeleted: false,
        readingTimeMinutes: 4,
      })
    );
  });

  it('denies update by non-owner', async () => {
    await seedArticle({ authorId: 'user-1' });
    const db = getFirestore({ uid: 'user-2' });
    await assertFails(
      articleRef(db).update({
        title: 'Hijacked Title',
        updatedAt: serverTimestamp(),
      })
    );
  });
});

describe('Articles — Immutable Fields', () => {
  it('denies changing authorId on update', async () => {
    await seedArticle({});
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).update({
        authorId: 'user-2',
        updatedAt: serverTimestamp(),
      })
    );
  });

  it('denies changing id on update', async () => {
    await seedArticle({});
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).update({
        id: 'different-id',
        updatedAt: serverTimestamp(),
      })
    );
  });
});

describe('Articles — Status Transitions', () => {
  it('allows draft → published', async () => {
    await seedArticle({ status: 'draft' });
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(
      articleRef(db).update({
        status: 'published',
        publishedAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      })
    );
  });

  it('allows published → archived', async () => {
    await seedArticle({ status: 'published', publishedAt: new Date() });
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(
      articleRef(db).update({
        status: 'archived',
        updatedAt: serverTimestamp(),
      })
    );
  });

  it('allows same status on update (draft → draft)', async () => {
    await seedArticle({ status: 'draft' });
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(
      articleRef(db).update({
        title: 'Edited draft title',
        updatedAt: serverTimestamp(),
      })
    );
  });

  it('denies draft → archived', async () => {
    await seedArticle({ status: 'draft' });
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).update({
        status: 'archived',
        updatedAt: serverTimestamp(),
      })
    );
  });

  it('denies archived → published', async () => {
    await seedArticle({ status: 'archived', publishedAt: new Date() });
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).update({
        status: 'published',
        updatedAt: serverTimestamp(),
      })
    );
  });

  it('denies archived → draft', async () => {
    await seedArticle({ status: 'archived', publishedAt: new Date() });
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).update({
        status: 'draft',
        updatedAt: serverTimestamp(),
      })
    );
  });

  it('denies published → draft', async () => {
    await seedArticle({ status: 'published', publishedAt: new Date() });
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      articleRef(db).update({
        status: 'draft',
        updatedAt: serverTimestamp(),
      })
    );
  });
});

describe('Articles — Soft Delete', () => {
  it('allows setting isDeleted to true (soft delete)', async () => {
    await seedArticle({});
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(
      articleRef(db).update({
        isDeleted: true,
        updatedAt: serverTimestamp(),
      })
    );
  });

  it('denies hard delete', async () => {
    await seedArticle({});
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(articleRef(db).delete());
  });
});

// ===========================================================================
// COMMENTS
// ===========================================================================

describe('Comments — Authentication', () => {
  it('denies unauthenticated read', async () => {
    await seedComment({});
    const db = getFirestore(null);
    await assertFails(commentRef(db).get());
  });

  it('allows authenticated read', async () => {
    await seedComment({});
    const db = getFirestore({ uid: 'user-2' });
    await assertSucceeds(commentRef(db).get());
  });
});

describe('Comments — Create', () => {
  it('allows creating comment with valid data', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(commentRef(db).set(validCommentData()));
  });

  it('denies create with authorId != auth.uid', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      commentRef(db).set(validCommentData({ authorId: 'user-2' }))
    );
  });

  it('denies create with mismatched articleId', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      commentRef(db, 'article-1', 'comment-1').set(
        validCommentData({ articleId: 'wrong-article' })
      )
    );
  });

  it('denies create with mismatched comment id', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      commentRef(db, 'article-1', 'comment-1').set(
        validCommentData({ id: 'wrong-id' })
      )
    );
  });

  it('denies create with empty content', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      commentRef(db).set(validCommentData({ content: '' }))
    );
  });

  it('denies create with content over 2000 characters', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      commentRef(db).set(validCommentData({ content: 'x'.repeat(2001) }))
    );
  });

  it('denies create with isDeleted = true', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      commentRef(db).set(validCommentData({ isDeleted: true }))
    );
  });
});

describe('Comments — Update (append-only + soft-delete)', () => {
  it('allows author to soft-delete own comment', async () => {
    await seedComment({ authorId: 'user-1' });
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(
      commentRef(db).update({ isDeleted: true })
    );
  });

  it('denies non-author soft-delete', async () => {
    await seedComment({ authorId: 'user-1' });
    const db = getFirestore({ uid: 'user-2' });
    await assertFails(
      commentRef(db).update({ isDeleted: true })
    );
  });

  it('denies editing comment content', async () => {
    await seedComment({ authorId: 'user-1' });
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      commentRef(db).update({ content: 'Edited content' })
    );
  });

  it('denies hard-deleting a comment', async () => {
    await seedComment({ authorId: 'user-1' });
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(commentRef(db).delete());
  });
});

// ===========================================================================
// SAVED ARTICLES
// ===========================================================================

describe('Saved Articles', () => {
  it('allows user to save article to own collection', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(
      savedArticleRef(db, 'user-1').set({
        articleId: 'article-1',
        savedAt: serverTimestamp(),
      })
    );
  });

  it('denies saving to another user collection', async () => {
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      savedArticleRef(db, 'user-2').set({
        articleId: 'article-1',
        savedAt: serverTimestamp(),
      })
    );
  });

  it('allows user to read own saved articles', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await savedArticleRef(db, 'user-1').set({
        articleId: 'article-1',
        savedAt: new Date(),
      });
    });
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(savedArticleRef(db, 'user-1').get());
  });

  it('denies reading another user saved articles', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await savedArticleRef(db, 'user-2').set({
        articleId: 'article-1',
        savedAt: new Date(),
      });
    });
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(savedArticleRef(db, 'user-2').get());
  });

  it('allows user to delete own saved article (unsave)', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await savedArticleRef(db, 'user-1').set({
        articleId: 'article-1',
        savedAt: new Date(),
      });
    });
    const db = getFirestore({ uid: 'user-1' });
    await assertSucceeds(savedArticleRef(db, 'user-1').delete());
  });

  it('denies update on saved articles (immutable)', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await savedArticleRef(db, 'user-1').set({
        articleId: 'article-1',
        savedAt: new Date(),
      });
    });
    const db = getFirestore({ uid: 'user-1' });
    await assertFails(
      savedArticleRef(db, 'user-1').update({
        articleId: 'article-2',
      })
    );
  });
});
