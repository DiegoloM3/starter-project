import { randomUUID } from 'node:crypto';
import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';
import { createTestEnvironment, JOURNALIST, READER, storageAs, STORAGE_BUCKET } from '../test_environment.js';

const SMALL_IMAGE = new Uint8Array([1, 2, 3]);
const JPEG_METADATA = { contentType: 'image/jpeg' };

// Unique names keep tests independent from files uploaded by previous tests.
const newArticleThumbnailPath = () => `media/articles/${randomUUID()}.jpg`;

describe('Storage rules: media/articles', () => {
  let testEnvironment;

  before(async () => {
    testEnvironment = await createTestEnvironment();
  });

  beforeEach(async () => {
    await testEnvironment.clearStorage();
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      const adminStorage = context.storage(`gs://${STORAGE_BUCKET}`);
      await uploadBytes(ref(adminStorage, 'media/articles/existing.jpg'), SMALL_IMAGE, JPEG_METADATA);
    });
  });

  after(async () => {
    await testEnvironment.cleanup();
  });

  const fileRefAs = (user, path) => ref(storageAs(testEnvironment, user), path);
  const uploadAs = (user, path, data = SMALL_IMAGE, metadata = JPEG_METADATA) =>
    uploadBytes(fileRefAs(user, path), data, metadata);

  it('allows a journalist to upload an image', async () => {
    await assertSucceeds(uploadAs(JOURNALIST, newArticleThumbnailPath()));
  });

  it('denies a reader uploading an image', async () => {
    await assertFails(uploadAs(READER, newArticleThumbnailPath()));
  });

  it('denies uploading without signing in', async () => {
    await assertFails(uploadAs(null, newArticleThumbnailPath()));
  });

  it('allows anyone to read a thumbnail, even without signing in', async () => {
    await assertSucceeds(getBytes(fileRefAs(null, 'media/articles/existing.jpg')));
  });

  it('denies overwriting an existing thumbnail', async () => {
    await assertFails(uploadAs(JOURNALIST, 'media/articles/existing.jpg'));
  });

  it('denies deleting a thumbnail', async () => {
    await assertFails(deleteObject(fileRefAs(JOURNALIST, 'media/articles/existing.jpg')));
  });

  it('denies uploading a file that is not an image', async () => {
    await assertFails(uploadAs(JOURNALIST, `media/articles/${randomUUID()}.pdf`, SMALL_IMAGE, { contentType: 'application/pdf' }));
  });

  it('denies uploading an image of 5 MB or more', async () => {
    await assertFails(uploadAs(JOURNALIST, newArticleThumbnailPath(), new Uint8Array(5 * 1024 * 1024)));
  });

  it('denies uploading outside the media/articles folder', async () => {
    await assertFails(uploadAs(JOURNALIST, `media/other/${randomUUID()}.jpg`));
  });
});
