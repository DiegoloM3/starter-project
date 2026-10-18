import { randomUUID } from 'node:crypto';
import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';
import { createTestEnvironment, JOURNALIST, READER, storageAs, STORAGE_BUCKET } from '../test_environment.js';

const SMALL_IMAGE = new Uint8Array([1, 2, 3]);
const JPEG_METADATA = { contentType: 'image/jpeg' };

// Unique names keep tests independent from files uploaded by previous tests.
const newPhotoPathOf = (user) => `media/users/${user.uid}/${randomUUID()}.jpg`;
const EXISTING_READER_PHOTO = `media/users/${READER.uid}/existing.jpg`;

describe('Storage rules: media/users', () => {
  let testEnvironment;

  before(async () => {
    testEnvironment = await createTestEnvironment();
  });

  beforeEach(async () => {
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      const adminStorage = context.storage(`gs://${STORAGE_BUCKET}`);
      await uploadBytes(ref(adminStorage, EXISTING_READER_PHOTO), SMALL_IMAGE, JPEG_METADATA);
    });
  });

  after(async () => {
    await testEnvironment.cleanup();
  });

  const fileRefAs = (user, path) => ref(storageAs(testEnvironment, user), path);
  const uploadAs = (user, path, data = SMALL_IMAGE, metadata = JPEG_METADATA) =>
    uploadBytes(fileRefAs(user, path), data, metadata);

  it('allows a user to upload their profile photo', async () => {
    await assertSucceeds(uploadAs(READER, newPhotoPathOf(READER)));
  });

  it('denies uploading a photo into another user folder', async () => {
    await assertFails(uploadAs(JOURNALIST, newPhotoPathOf(READER)));
  });

  it('denies uploading without signing in', async () => {
    await assertFails(uploadAs(null, newPhotoPathOf(READER)));
  });

  it('denies uploading a file that is not an image', async () => {
    await assertFails(uploadAs(READER, `media/users/${READER.uid}/${randomUUID()}.pdf`, SMALL_IMAGE, { contentType: 'application/pdf' }));
  });

  it('denies uploading an image of 5 MB or more', async () => {
    await assertFails(uploadAs(READER, newPhotoPathOf(READER), new Uint8Array(5 * 1024 * 1024)));
  });

  it('allows anyone to see a profile photo, even without signing in', async () => {
    await assertSucceeds(getBytes(fileRefAs(null, EXISTING_READER_PHOTO)));
  });

  it('allows a user to delete their profile photo', async () => {
    await assertSucceeds(deleteObject(fileRefAs(READER, EXISTING_READER_PHOTO)));
  });

  it('denies deleting another user profile photo', async () => {
    await assertFails(deleteObject(fileRefAs(JOURNALIST, EXISTING_READER_PHOTO)));
  });
});
