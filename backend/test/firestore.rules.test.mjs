import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  limit,
  query,
  setDoc,
  updateDoc,
} from 'firebase/firestore';
import { createTestEnvironment, newArticleId, thumbnailURLFor, validArticle } from './helpers.mjs';

let testEnv;
let db;

function createArticle(articleId, article) {
  return setDoc(doc(db, 'articles', articleId), article);
}

function createArticleWith(overrides) {
  const articleId = newArticleId();
  return createArticle(articleId, { ...validArticle(articleId), ...overrides });
}

async function seedArticleBypassingRules(articleId) {
  await testEnv.withSecurityRulesDisabled((context) =>
    setDoc(doc(context.firestore(), 'articles', articleId), { ...validArticle(articleId), publishedAt: Timestamp.now() }),
  );
}

before(async () => {
  testEnv = await createTestEnvironment();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  db = testEnv.unauthenticatedContext().firestore();
});

after(async () => {
  await testEnv.cleanup();
});

describe('articles: read', () => {
  it('allows reading a single article', async () => {
    const articleId = newArticleId();
    await seedArticleBypassingRules(articleId);
    await assertSucceeds(getDoc(doc(db, 'articles', articleId)));
  });

  it('allows listing with a limit of up to 50', async () => {
    await assertSucceeds(getDocs(query(collection(db, 'articles'), limit(50))));
  });

  it('denies listing without a limit', async () => {
    await assertFails(getDocs(collection(db, 'articles')));
  });

  it('denies listing with a limit above 50', async () => {
    await assertFails(getDocs(query(collection(db, 'articles'), limit(51))));
  });
});

describe('articles: create', () => {
  it('allows a valid article', async () => {
    const articleId = newArticleId();
    await assertSucceeds(createArticle(articleId, validArticle(articleId)));
  });

  it('denies a document id that is not auto-generated', async () => {
    await assertFails(createArticle('my-article', validArticle('my-article')));
  });

  for (const field of ['title', 'content', 'description', 'author', 'thumbnailURL', 'publishedAt']) {
    it(`denies a missing ${field}`, async () => {
      const articleId = newArticleId();
      const { [field]: _removed, ...article } = validArticle(articleId);
      await assertFails(createArticle(articleId, article));
    });
  }

  it('denies unknown fields', async () => {
    await assertFails(createArticleWith({ likes: 1000 }));
  });
});

describe('articles: text fields', () => {
  const limits = [
    { field: 'title', maxLength: 100 },
    { field: 'content', maxLength: 10000 },
    { field: 'author', maxLength: 60 },
  ];

  for (const { field, maxLength } of limits) {
    it(`allows a ${field} of exactly ${maxLength} characters`, async () => {
      await assertSucceeds(createArticleWith({ [field]: 'a'.repeat(maxLength) }));
    });

    it(`denies a ${field} longer than ${maxLength} characters`, async () => {
      await assertFails(createArticleWith({ [field]: 'a'.repeat(maxLength + 1) }));
    });

    it(`denies an empty ${field}`, async () => {
      await assertFails(createArticleWith({ [field]: '' }));
    });

    it(`denies a whitespace-only ${field}`, async () => {
      await assertFails(createArticleWith({ [field]: '  \n\t ' }));
    });

    it(`denies a non-string ${field}`, async () => {
      await assertFails(createArticleWith({ [field]: 42 }));
    });
  }

  it('allows an empty description', async () => {
    await assertSucceeds(createArticleWith({ description: '' }));
  });

  it('allows a description of exactly 300 characters', async () => {
    await assertSucceeds(createArticleWith({ description: 'a'.repeat(300) }));
  });

  it('denies a description longer than 300 characters', async () => {
    await assertFails(createArticleWith({ description: 'a'.repeat(301) }));
  });

  // Rules measure UTF-16 code units, exactly like Dart's String.length: an emoji counts as 2.
  it('allows a title of 50 emoji (100 UTF-16 code units)', async () => {
    await assertSucceeds(createArticleWith({ title: '😀'.repeat(50) }));
  });

  it('denies a title of 51 emoji (102 UTF-16 code units)', async () => {
    await assertFails(createArticleWith({ title: '😀'.repeat(51) }));
  });
});

describe('articles: publishedAt', () => {
  it('denies a client-provided timestamp', async () => {
    await assertFails(createArticleWith({ publishedAt: Timestamp.now() }));
  });

  it('denies a backdated timestamp', async () => {
    await assertFails(createArticleWith({ publishedAt: Timestamp.fromDate(new Date('2020-01-01')) }));
  });

  it('denies a string date', async () => {
    await assertFails(createArticleWith({ publishedAt: new Date().toISOString() }));
  });
});

describe('articles: thumbnailURL', () => {
  function createArticleWithThumbnail(buildURL) {
    const articleId = newArticleId();
    return createArticle(articleId, { ...validArticle(articleId), thumbnailURL: buildURL(articleId) });
  }

  for (const extension of ['jpg', 'png', 'webp']) {
    it(`allows a .${extension} thumbnail`, async () => {
      await assertSucceeds(createArticleWithThumbnail((id) => thumbnailURLFor(id, { extension })));
    });
  }

  for (const host of ['http://127.0.0.1:9199', 'http://localhost:9199', 'http://10.0.2.2:9199']) {
    it(`allows the local Storage emulator at ${host}`, async () => {
      await assertSucceeds(createArticleWithThumbnail((id) => thumbnailURLFor(id, { host })));
    });
  }

  it('denies a thumbnail of another article', async () => {
    await assertFails(createArticleWithThumbnail(() => thumbnailURLFor(newArticleId())));
  });

  it('denies an unsupported extension', async () => {
    await assertFails(createArticleWithThumbnail((id) => thumbnailURLFor(id, { extension: 'gif' })));
  });

  it('denies an external host', async () => {
    await assertFails(createArticleWithThumbnail((id) => thumbnailURLFor(id, { host: 'https://evil.example.com' })));
  });

  it('denies a file outside media/articles', async () => {
    await assertFails(
      createArticleWithThumbnail((id) => thumbnailURLFor(id).replace('media%2Farticles%2F', 'media%2Fother%2F')),
    );
  });

  it('denies another bucket', async () => {
    await assertFails(
      createArticleWithThumbnail((id) => thumbnailURLFor(id).replace('backend-news-symmetry', 'someone-else')),
    );
  });

  it('denies a URL without download token', async () => {
    await assertFails(createArticleWithThumbnail((id) => thumbnailURLFor(id).replace(/&token=.*/, '')));
  });
});

describe('articles: immutability', () => {
  it('denies updates', async () => {
    const articleId = newArticleId();
    await seedArticleBypassingRules(articleId);
    await assertFails(updateDoc(doc(db, 'articles', articleId), { title: 'Edited' }));
  });

  it('denies deletes', async () => {
    const articleId = newArticleId();
    await seedArticleBypassingRules(articleId);
    await assertFails(deleteDoc(doc(db, 'articles', articleId)));
  });
});

describe('other collections', () => {
  it('denies writes outside articles', async () => {
    await assertFails(setDoc(doc(db, 'users', 'alice'), { name: 'Alice' }));
  });
});
