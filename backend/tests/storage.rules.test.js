import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';
import { AUTHOR_UID, OTHER_UID, createTestEnvironment, fakeImageBytes } from './helpers.js';

const FIVE_MIB = 5 * 1024 * 1024;

let testEnv;

/** The object as seen by a signed-in journalist. */
function objectRef(path) {
  return ref(testEnv.authenticatedContext(AUTHOR_UID).storage(), path);
}

function anonymousRef(path) {
  return ref(testEnv.unauthenticatedContext().storage(), path);
}

/** Uploads bypassing rules so read/delete/replace tests start from an existing object. */
async function seedImage(path = `media/articles/${AUTHOR_UID}-seed.jpg`) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await uploadBytes(ref(context.storage(), path), fakeImageBytes(), {
      contentType: 'image/jpeg',
    });
  });
}

/**
 * The Storage emulator answers 403 for a few hundred milliseconds after new rules
 * are loaded. Poll a rules-allowed read until the runtime is ready so the first
 * real assertions are not racing against it.
 */
async function waitForStorageRules(timeoutMs = 10_000) {
  const deadline = Date.now() + timeoutMs;
  let lastError;
  while (Date.now() < deadline) {
    try {
      await seedImage(`media/articles/${AUTHOR_UID}-warmup.jpg`);
      await getBytes(objectRef(`media/articles/${AUTHOR_UID}-warmup.jpg`));
      return;
    } catch (error) {
      lastError = error;
      await new Promise((resolveDelay) => setTimeout(resolveDelay, 100));
    }
  }
  throw new Error(`Storage rules runtime did not become ready: ${lastError?.message}`);
}

before(async () => {
  testEnv = await createTestEnvironment();
  await waitForStorageRules();
});

beforeEach(async () => {
  await testEnv.clearStorage();
});

after(async () => {
  await testEnv.cleanup();
});

describe('media/articles: upload accepted images', () => {
  for (const contentType of ['image/jpeg', 'image/png', 'image/webp']) {
    it(`accepts a ${contentType} file`, async () => {
      await assertSucceeds(
        uploadBytes(objectRef(`media/articles/${AUTHOR_UID}-photo`), fakeImageBytes(), { contentType }),
      );
    });
  }

  it('accepts a file of exactly 5 MiB', async () => {
    await assertSucceeds(
      uploadBytes(objectRef(`media/articles/${AUTHOR_UID}-large.jpg`), fakeImageBytes(FIVE_MIB), {
        contentType: 'image/jpeg',
      }),
    );
  });

  it('accepts replacing an existing thumbnail with another valid image', async () => {
    await seedImage(`media/articles/${AUTHOR_UID}-seed.jpg`);
    await assertSucceeds(
      uploadBytes(objectRef(`media/articles/${AUTHOR_UID}-seed.jpg`), fakeImageBytes(), {
        contentType: 'image/png',
      }),
    );
  });
});

describe('media/articles: upload rejected files', () => {
  it('rejects a non-image content type', async () => {
    await assertFails(
      uploadBytes(objectRef(`media/articles/${AUTHOR_UID}-report.pdf`), fakeImageBytes(), {
        contentType: 'application/pdf',
      }),
    );
  });

  it('rejects an image type outside the allow-list (gif)', async () => {
    await assertFails(
      uploadBytes(objectRef(`media/articles/${AUTHOR_UID}-anim.gif`), fakeImageBytes(), {
        contentType: 'image/gif',
      }),
    );
  });

  it('rejects a file larger than 5 MiB', async () => {
    await assertFails(
      uploadBytes(objectRef(`media/articles/${AUTHOR_UID}-huge.jpg`), fakeImageBytes(FIVE_MIB + 1), {
        contentType: 'image/jpeg',
      }),
    );
  });

  it('rejects an upload into a sub-folder of media/articles/', async () => {
    await assertFails(
      uploadBytes(objectRef(`media/articles/2026/${AUTHOR_UID}-photo.jpg`), fakeImageBytes(), {
        contentType: 'image/jpeg',
      }),
    );
  });

  it('rejects an upload outside media/articles/', async () => {
    await assertFails(
      uploadBytes(objectRef('media/avatars/photo.jpg'), fakeImageBytes(), {
        contentType: 'image/jpeg',
      }),
    );
  });

  it('rejects an upload without a signed-in user', async () => {
    await assertFails(
      uploadBytes(anonymousRef(`media/articles/${AUTHOR_UID}-photo.jpg`), fakeImageBytes(), {
        contentType: 'image/jpeg',
      }),
    );
  });

  it('rejects an upload at the bucket root', async () => {
    await assertFails(
      uploadBytes(objectRef('photo.jpg'), fakeImageBytes(), { contentType: 'image/jpeg' }),
    );
  });
});

describe('media/articles: read and delete', () => {
  it('allows anyone, signed in or not, to download a thumbnail', async () => {
    await seedImage();
    await assertSucceeds(getBytes(anonymousRef(`media/articles/${AUTHOR_UID}-seed.jpg`)));
    await assertSucceeds(getBytes(objectRef(`media/articles/${AUTHOR_UID}-seed.jpg`)));
  });

  it('allows the owner to delete a thumbnail', async () => {
    await seedImage();
    await assertSucceeds(deleteObject(objectRef(`media/articles/${AUTHOR_UID}-seed.jpg`)));
  });

  it('rejects a delete without a signed-in user', async () => {
    await seedImage();
    await assertFails(deleteObject(anonymousRef(`media/articles/${AUTHOR_UID}-seed.jpg`)));
  });

  it('rejects a thumbnail whose name does not start with the caller uid', async () => {
    await assertFails(
      uploadBytes(objectRef('media/articles/photo.jpg'), fakeImageBytes(), { contentType: 'image/jpeg' }),
    );
    await assertFails(
      uploadBytes(objectRef(`media/articles/${OTHER_UID}-photo.jpg`), fakeImageBytes(), {
        contentType: 'image/jpeg',
      }),
    );
  });

  it('lets nobody but the owner replace or delete a thumbnail', async () => {
    const own = `media/articles/${AUTHOR_UID}-seed.jpg`;
    const other = ref(testEnv.authenticatedContext(OTHER_UID).storage(), own);
    await seedImage(own);
    await assertFails(uploadBytes(other, fakeImageBytes(), { contentType: 'image/png' }));
    await assertFails(deleteObject(other));
    await assertSucceeds(getBytes(other));
    await assertSucceeds(deleteObject(objectRef(own)));
  });

  it('denies reading objects outside media/articles/', async () => {
    await seedImage('media/private/secret.jpg');
    await assertFails(getBytes(objectRef('media/private/secret.jpg')));
  });
});

describe('media/avatars: profile photos', () => {
  const own = `media/avatars/${AUTHOR_UID}.jpg`;

  it('lets a signed-in user upload and replace their own photo', async () => {
    await assertSucceeds(uploadBytes(objectRef(own), fakeImageBytes(), { contentType: 'image/jpeg' }));
    await assertSucceeds(uploadBytes(objectRef(own), fakeImageBytes(), { contentType: 'image/png' }));
  });

  it('rejects a photo named after somebody else, an anonymous upload and a non-image', async () => {
    await assertFails(
      uploadBytes(objectRef(`media/avatars/${OTHER_UID}.jpg`), fakeImageBytes(), { contentType: 'image/jpeg' }),
    );
    await assertFails(uploadBytes(anonymousRef(own), fakeImageBytes(), { contentType: 'image/jpeg' }));
    await assertFails(uploadBytes(objectRef(own), fakeImageBytes(), { contentType: 'application/pdf' }));
  });

  it('is readable by anyone and deletable only by its owner', async () => {
    await seedImage(own);
    await assertSucceeds(getBytes(anonymousRef(own)));
    await assertFails(deleteObject(ref(testEnv.authenticatedContext(OTHER_UID).storage(), own)));
    await assertSucceeds(deleteObject(objectRef(own)));
  });
});
