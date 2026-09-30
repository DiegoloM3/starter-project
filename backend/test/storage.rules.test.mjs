import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { Timestamp, doc, setDoc } from 'firebase/firestore';
import { BUCKET, createTestEnvironment, newArticleId, validArticle } from './helpers.mjs';

const SMALL_IMAGE = new Uint8Array([0xff, 0xd8, 0xff, 0xe0]);
const MAX_SIZE = 5 * 1024 * 1024;

let testEnv;
let storage;

function thumbnailRef(fileName) {
  return storage.ref(`media/articles/${fileName}`);
}

// UploadTask is only a thenable; the assertions need a real Promise.
function upload(path, bytes, contentType) {
  return Promise.resolve(storage.ref(path).put(bytes, { contentType }));
}

function uploadThumbnail(fileName, contentType, bytes = SMALL_IMAGE) {
  return upload(`media/articles/${fileName}`, bytes, contentType);
}

async function seedThumbnailBypassingRules(fileName) {
  await testEnv.withSecurityRulesDisabled((context) =>
    Promise.resolve(context.storage(`gs://${BUCKET}`).ref(`media/articles/${fileName}`).put(SMALL_IMAGE, { contentType: 'image/jpeg' })),
  );
}

// testEnv.clearStorage() only empties the legacy default bucket ({projectId}.appspot.com),
// not the {projectId}.firebasestorage.app bucket this project uses.
async function clearThumbnailsFolder() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const { items } = await context.storage(`gs://${BUCKET}`).ref('media/articles').listAll();
    await Promise.all(items.map((item) => item.delete()));
  });
}

async function publishArticleBypassingRules(articleId) {
  await testEnv.withSecurityRulesDisabled((context) =>
    setDoc(doc(context.firestore(), 'articles', articleId), { ...validArticle(articleId), publishedAt: Timestamp.now() }),
  );
}

before(async () => {
  testEnv = await createTestEnvironment();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await clearThumbnailsFolder();
  storage = testEnv.unauthenticatedContext().storage(`gs://${BUCKET}`);
});

after(async () => {
  await clearThumbnailsFolder();
  await testEnv.cleanup();
});

describe('thumbnails: upload', () => {
  const validTypes = [
    { extension: 'jpg', contentType: 'image/jpeg' },
    { extension: 'png', contentType: 'image/png' },
    { extension: 'webp', contentType: 'image/webp' },
  ];

  for (const { extension, contentType } of validTypes) {
    it(`allows a .${extension} with ${contentType}`, async () => {
      await assertSucceeds(uploadThumbnail(`${newArticleId()}.${extension}`, contentType));
    });
  }

  it('allows exactly 5 MB', async () => {
    await assertSucceeds(uploadThumbnail(`${newArticleId()}.jpg`, 'image/jpeg', new Uint8Array(MAX_SIZE)));
  });

  it('denies more than 5 MB', async () => {
    await assertFails(uploadThumbnail(`${newArticleId()}.jpg`, 'image/jpeg', new Uint8Array(MAX_SIZE + 1)));
  });

  it('denies a content type that does not match the extension', async () => {
    await assertFails(uploadThumbnail(`${newArticleId()}.jpg`, 'image/png'));
  });

  it('denies non-image content', async () => {
    await assertFails(uploadThumbnail(`${newArticleId()}.jpg`, 'text/plain'));
  });

  it('denies unsupported image formats', async () => {
    await assertFails(uploadThumbnail(`${newArticleId()}.gif`, 'image/gif'));
  });

  it('denies a file name that is not an article id', async () => {
    await assertFails(uploadThumbnail('cat.jpg', 'image/jpeg'));
  });

  it('denies files outside media/articles', async () => {
    await assertFails(upload(`media/other/${newArticleId()}.jpg`, SMALL_IMAGE, 'image/jpeg'));
  });

  it('denies overwriting an existing thumbnail', async () => {
    const fileName = `${newArticleId()}.jpg`;
    await seedThumbnailBypassingRules(fileName);
    await assertFails(uploadThumbnail(fileName, 'image/jpeg'));
  });

  it('denies uploading a thumbnail for an already published article', async () => {
    const articleId = newArticleId();
    await publishArticleBypassingRules(articleId);
    await assertFails(uploadThumbnail(`${articleId}.png`, 'image/png'));
  });
});

describe('thumbnails: read', () => {
  it('allows public reads', async () => {
    const fileName = `${newArticleId()}.jpg`;
    await seedThumbnailBypassingRules(fileName);
    await assertSucceeds(thumbnailRef(fileName).getDownloadURL());
  });
});

describe('thumbnails: delete', () => {
  it('allows deleting an orphaned thumbnail (no article document)', async () => {
    const fileName = `${newArticleId()}.jpg`;
    await seedThumbnailBypassingRules(fileName);
    await assertSucceeds(thumbnailRef(fileName).delete());
  });

  it('denies deleting the thumbnail of a published article', async () => {
    const articleId = newArticleId();
    await seedThumbnailBypassingRules(`${articleId}.jpg`);
    await publishArticleBypassingRules(articleId);
    await assertFails(thumbnailRef(`${articleId}.jpg`).delete());
  });
});
