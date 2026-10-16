import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';
import { createTestEnvironment } from './test_environment.mjs';

const MAX_THUMBNAIL_SIZE_IN_BYTES = 5 * 1024 * 1024;
const SMALL_IMAGE = new Uint8Array([0xff, 0xd8, 0xff, 0xe0]);
const JPEG_METADATA = { contentType: 'image/jpeg' };

describe('Storage rules: media/articles', () => {
  let testEnvironment;
  let storage;

  before(async () => {
    testEnvironment = await createTestEnvironment();
  });

  beforeEach(async () => {
    await testEnvironment.clearStorage();
    storage = testEnvironment.unauthenticatedContext().storage();
  });

  after(async () => {
    await testEnvironment.cleanup();
  });

  let uniqueFileCounter = 0;

  function createUniqueThumbnailPath(extension = 'jpg') {
    uniqueFileCounter += 1;
    return `media/articles/article${uniqueFileCounter}.${extension}`;
  }

  function getThumbnailReference(path) {
    return ref(storage, path);
  }

  async function seedThumbnail(path) {
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await uploadBytes(ref(context.storage(), path), SMALL_IMAGE, JPEG_METADATA);
    });
  }

  it('allows anyone to read a thumbnail', async () => {
    const path = createUniqueThumbnailPath();
    await seedThumbnail(path);
    await assertSucceeds(getBytes(getThumbnailReference(path)));
  });

  it('allows uploading a valid thumbnail', async () => {
    await assertSucceeds(uploadBytes(getThumbnailReference(createUniqueThumbnailPath()), SMALL_IMAGE, JPEG_METADATA));
  });

  it('allows png and webp thumbnails', async () => {
    await assertSucceeds(uploadBytes(getThumbnailReference(createUniqueThumbnailPath('png')), SMALL_IMAGE, { contentType: 'image/png' }));
    await assertSucceeds(uploadBytes(getThumbnailReference(createUniqueThumbnailPath('webp')), SMALL_IMAGE, { contentType: 'image/webp' }));
  });

  it('allows a thumbnail of exactly 5 MB', async () => {
    const image = new Uint8Array(MAX_THUMBNAIL_SIZE_IN_BYTES);
    await assertSucceeds(uploadBytes(getThumbnailReference(createUniqueThumbnailPath()), image, JPEG_METADATA));
  });

  it('rejects a thumbnail larger than 5 MB', async () => {
    const image = new Uint8Array(MAX_THUMBNAIL_SIZE_IN_BYTES + 1);
    await assertFails(uploadBytes(getThumbnailReference(createUniqueThumbnailPath()), image, JPEG_METADATA));
  });

  it('rejects a file that is not an image', async () => {
    await assertFails(uploadBytes(getThumbnailReference(createUniqueThumbnailPath()), SMALL_IMAGE, { contentType: 'application/pdf' }));
  });

  it('rejects a file name with an unsupported extension', async () => {
    await assertFails(uploadBytes(getThumbnailReference(createUniqueThumbnailPath('gif')), SMALL_IMAGE, { contentType: 'image/gif' }));
  });

  it('rejects uploads outside the media/articles folder', async () => {
    await assertFails(uploadBytes(getThumbnailReference('media/other/article123.jpg'), SMALL_IMAGE, JPEG_METADATA));
  });

  it('rejects overwriting an existing thumbnail', async () => {
    const path = createUniqueThumbnailPath();
    await seedThumbnail(path);
    await assertFails(uploadBytes(getThumbnailReference(path), SMALL_IMAGE, JPEG_METADATA));
  });

  it('rejects deleting a thumbnail', async () => {
    const path = createUniqueThumbnailPath();
    await seedThumbnail(path);
    await assertFails(deleteObject(getThumbnailReference(path)));
  });
});
