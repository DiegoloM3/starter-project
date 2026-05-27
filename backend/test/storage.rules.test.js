const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const { readFileSync } = require('fs');
const { resolve } = require('path');

const PROJECT_ID = 'symmetry-news-app-46777';
const THUMBNAIL_PATH = 'media/articles/user-1/article-1/thumbnail';
const OTHER_USER_PATH = 'media/articles/user-2/article-1/thumbnail';

let testEnv;

// ---------------------------------------------------------------------------
// Setup / Teardown
// ---------------------------------------------------------------------------

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    storage: {
      rules: readFileSync(resolve(__dirname, '../storage.rules'), 'utf8'),
      host: 'localhost',
      port: 9199,
    },
  });
});

afterEach(async () => {
  await testEnv.clearStorage();
});

after(async () => {
  await testEnv.cleanup();
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function getStorage(auth) {
  if (auth) {
    return testEnv.authenticatedContext(auth.uid).storage();
  }
  return testEnv.unauthenticatedContext().storage();
}

function createFile(sizeBytes) {
  return new Uint8Array(sizeBytes);
}

// ===========================================================================
// STORAGE RULES TESTS
// ===========================================================================

describe('Storage — Authentication', () => {
  it('denies unauthenticated upload', async () => {
    const storage = getStorage(null);
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertFails(
      ref.put(createFile(1024), { contentType: 'image/jpeg' })
    );
  });

  it('denies unauthenticated read', async () => {
    // Seed a file first
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const storage = ctx.storage();
      const ref = storage.ref(THUMBNAIL_PATH);
      await ref.put(createFile(1024), { contentType: 'image/jpeg' });
    });

    const storage = getStorage(null);
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertFails(ref.getDownloadURL());
  });

  it('allows authenticated read', async () => {
    // Seed a file first
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const storage = ctx.storage();
      const ref = storage.ref(THUMBNAIL_PATH);
      await ref.put(createFile(1024), { contentType: 'image/jpeg' });
    });

    const storage = getStorage({ uid: 'user-2' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertSucceeds(ref.getDownloadURL());
  });
});

describe('Storage — Ownership', () => {
  it('allows upload to own path', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertSucceeds(
      ref.put(createFile(1024), { contentType: 'image/jpeg' })
    );
  });

  it('denies upload to another user path', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(OTHER_USER_PATH);
    await assertFails(
      ref.put(createFile(1024), { contentType: 'image/jpeg' })
    );
  });

  it('allows owner to delete their thumbnail', async () => {
    // Seed a file
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const storage = ctx.storage();
      await storage.ref(THUMBNAIL_PATH).put(createFile(1024), {
        contentType: 'image/jpeg',
      });
    });

    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertSucceeds(ref.delete());
  });
});

describe('Storage — MIME Type Validation', () => {
  it('allows image/jpeg', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertSucceeds(
      ref.put(createFile(1024), { contentType: 'image/jpeg' })
    );
  });

  it('allows image/png', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertSucceeds(
      ref.put(createFile(1024), { contentType: 'image/png' })
    );
  });

  it('allows image/webp', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertSucceeds(
      ref.put(createFile(1024), { contentType: 'image/webp' })
    );
  });

  it('denies application/pdf', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertFails(
      ref.put(createFile(1024), { contentType: 'application/pdf' })
    );
  });

  it('denies image/gif', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertFails(
      ref.put(createFile(1024), { contentType: 'image/gif' })
    );
  });

  it('denies text/plain', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertFails(
      ref.put(createFile(1024), { contentType: 'text/plain' })
    );
  });
});

describe('Storage — Size Limits', () => {
  it('allows file under 5MB', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertSucceeds(
      ref.put(createFile(1024 * 1024), { contentType: 'image/jpeg' })
    );
  });

  it('allows file at exactly 5MB', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertSucceeds(
      ref.put(createFile(5 * 1024 * 1024), { contentType: 'image/jpeg' })
    );
  });

  it('denies file over 5MB', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref(THUMBNAIL_PATH);
    await assertFails(
      ref.put(createFile(6 * 1024 * 1024), { contentType: 'image/jpeg' })
    );
  });
});

describe('Storage — Unmatched Paths', () => {
  it('denies access to unmatched path', async () => {
    const storage = getStorage({ uid: 'user-1' });
    const ref = storage.ref('random/unmatched/path');
    await assertFails(
      ref.put(createFile(1024), { contentType: 'image/jpeg' })
    );
  });
});
