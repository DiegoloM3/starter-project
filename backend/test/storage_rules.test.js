import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { getBytes, ref, uploadBytes } from 'firebase/storage';
import { createTestEnvironment, STORAGE_BUCKET } from './test_environment.js';

const SMALL_IMAGE = new Uint8Array([1, 2, 3]);
const JPEG_METADATA = { contentType: 'image/jpeg' };

describe('Storage rules: media/articles', () => {
  let testEnvironment;
  let storage;

  before(async () => {
    testEnvironment = await createTestEnvironment();
  });

  beforeEach(async () => {
    await testEnvironment.clearStorage();
    storage = testEnvironment.unauthenticatedContext().storage(`gs://${STORAGE_BUCKET}`);
  });

  after(async () => {
    await testEnvironment.cleanup();
  });

  const fileRef = (path) => ref(storage, path);

  async function uploadExistingThumbnail() {
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      const adminStorage = context.storage(`gs://${STORAGE_BUCKET}`);
      await uploadBytes(ref(adminStorage, 'media/articles/existing.jpg'), SMALL_IMAGE, JPEG_METADATA);
    });
  }

  it('allows uploading an image', async () => {
    await assertSucceeds(uploadBytes(fileRef('media/articles/new.jpg'), SMALL_IMAGE, JPEG_METADATA));
  });

  it('allows reading a thumbnail', async () => {
    await uploadExistingThumbnail();
    await assertSucceeds(getBytes(fileRef('media/articles/existing.jpg')));
  });

  it('denies overwriting an existing thumbnail', async () => {
    await uploadExistingThumbnail();
    await assertFails(uploadBytes(fileRef('media/articles/existing.jpg'), SMALL_IMAGE, JPEG_METADATA));
  });

  it('denies uploading a file that is not an image', async () => {
    await assertFails(uploadBytes(fileRef('media/articles/file.pdf'), SMALL_IMAGE, { contentType: 'application/pdf' }));
  });

  it('denies uploading an image of 5 MB or more', async () => {
    const largeImage = new Uint8Array(5 * 1024 * 1024);
    await assertFails(uploadBytes(fileRef('media/articles/large.jpg'), largeImage, JPEG_METADATA));
  });

  it('denies uploading outside the media/articles folder', async () => {
    await assertFails(uploadBytes(fileRef('media/other/new.jpg'), SMALL_IMAGE, JPEG_METADATA));
  });
});
