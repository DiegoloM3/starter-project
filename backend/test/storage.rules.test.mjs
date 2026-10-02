import { readFileSync } from 'node:fs';
import { after, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';

const PROJECT_ID = 'demo-symmetry-news';
const MAX_THUMBNAIL_BYTES = 5 * 1024 * 1024;
const THUMBNAIL_PATH = 'media/articles/Xy7Qp2LmT9aB3cD4eF5g.png';

const testEnvironment = await initializeTestEnvironment({
  projectId: PROJECT_ID,
  storage: { rules: readFileSync('storage.rules', 'utf8') },
});

// The journalist signed in to the app.
const storage = testEnvironment.authenticatedContext('janeDoeUid', { name: 'Jane Doe' }).storage();
const anonymousStorage = testEnvironment.unauthenticatedContext().storage();

function uploadFile(path, { sizeInBytes = 1024, contentType = 'image/png' } = {}) {
  return uploadBytes(ref(storage, path), new Uint8Array(sizeInBytes), { contentType });
}

async function seedThumbnailBypassingRules() {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const bytes = new Uint8Array(1024);
    await uploadBytes(ref(context.storage(), THUMBNAIL_PATH), bytes, { contentType: 'image/png' });
  });
}

// testEnvironment.clearStorage() only deletes files in the root of the bucket, not in folders.
async function deleteAllFilesIn(folder) {
  const { items, prefixes } = await folder.listAll();
  await Promise.all([...items.map((item) => item.delete()), ...prefixes.map(deleteAllFilesIn)]);
}

function clearAllStorage() {
  return testEnvironment.withSecurityRulesDisabled((context) => deleteAllFilesIn(context.storage().ref()));
}

beforeEach(() => clearAllStorage());
after(() => testEnvironment.cleanup());

describe('media/articles: read', () => {
  test('a signed-in user can read a thumbnail', async () => {
    await seedThumbnailBypassingRules();
    await assertSucceeds(getBytes(ref(storage, THUMBNAIL_PATH)));
  });

  test('rejects reading a thumbnail without signing in', async () => {
    await seedThumbnailBypassingRules();
    await assertFails(getBytes(ref(anonymousStorage, THUMBNAIL_PATH)));
  });
});

describe('media/articles: create', () => {
  test('rejects uploading a thumbnail without signing in', async () => {
    const bytes = new Uint8Array(1024);
    await assertFails(uploadBytes(ref(anonymousStorage, THUMBNAIL_PATH), bytes, { contentType: 'image/png' }));
  });

  for (const [extension, contentType] of [['jpg', 'image/jpeg'], ['jpeg', 'image/jpeg'], ['png', 'image/png'], ['webp', 'image/webp']]) {
    test(`accepts a ${contentType} thumbnail named {articleId}.${extension}`, async () => {
      await assertSucceeds(uploadFile(`media/articles/Xy7Qp2LmT9aB3cD4eF5g.${extension}`, { contentType }));
    });
  }

  test('accepts a thumbnail of exactly 5 MB', async () => {
    await assertSucceeds(uploadFile(THUMBNAIL_PATH, { sizeInBytes: MAX_THUMBNAIL_BYTES }));
  });

  test('rejects a thumbnail bigger than 5 MB', async () => {
    await assertFails(uploadFile(THUMBNAIL_PATH, { sizeInBytes: MAX_THUMBNAIL_BYTES + 1 }));
  });

  test('rejects a file that is not an image', async () => {
    await assertFails(uploadFile(THUMBNAIL_PATH, { contentType: 'application/pdf' }));
  });

  test('rejects an unsupported image type', async () => {
    await assertFails(uploadFile(THUMBNAIL_PATH, { contentType: 'image/svg+xml' }));
  });

  test('rejects a file name that is not {articleId}.{extension}', async () => {
    await assertFails(uploadFile('media/articles/not a valid name.png'));
  });

  test('rejects a file outside media/articles', async () => {
    await assertFails(uploadFile('media/users/Xy7Qp2LmT9aB3cD4eF5g.png'));
  });

  test('rejects a file in a subfolder of media/articles', async () => {
    await assertFails(uploadFile('media/articles/nested/Xy7Qp2LmT9aB3cD4eF5g.png'));
  });
});

describe('media/articles: update and delete', () => {
  test('rejects overwriting an existing thumbnail', async () => {
    await seedThumbnailBypassingRules();
    await assertFails(uploadFile(THUMBNAIL_PATH));
  });

  test('rejects deleting a thumbnail', async () => {
    await seedThumbnailBypassingRules();
    await assertFails(deleteObject(ref(storage, THUMBNAIL_PATH)));
  });
});
