import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp, collection, deleteDoc, doc, getDoc, getDocs, orderBy, query,
  setDoc, serverTimestamp, updateDoc,
} from 'firebase/firestore';
import { deleteObject, getBytes, listAll, ref, uploadBytes } from 'firebase/storage';

const projectId = 'demo-symmetry-rules';
const bucket = `gs://${projectId}.appspot.com`;
const maxImageBytes = 5 * 1024 * 1024;
let environment;
let database;
let storage;

// Fail closed when invoked outside emulators:exec or with non-local endpoints.
function localEmulator(variable, port) {
  const endpoint = process.env[variable];
  assert.ok(
    endpoint === `127.0.0.1:${port}` || endpoint === `localhost:${port}`,
    `Run npm test: ${variable} must point to the local emulator on ${port}`,
  );
  return { host: '127.0.0.1', port };
}

before(async () => {
  assert.equal(process.env.GCLOUD_PROJECT, projectId);
  environment = await initializeTestEnvironment({
    projectId,
    firestore: {
      ...localEmulator('FIRESTORE_EMULATOR_HOST', 18080),
      rules: await readFile(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
    storage: {
      ...localEmulator('FIREBASE_STORAGE_EMULATOR_HOST', 19199),
      rules: await readFile(new URL('../storage.rules', import.meta.url), 'utf8'),
    },
  });
  const publicContext = environment.unauthenticatedContext();
  database = publicContext.firestore();
  storage = publicContext.storage(bucket);
});

beforeEach(async () => {
  await environment.clearFirestore();
  // clearStorage() in rules-unit-testing 5.0.2 only deletes root-level items.
  // Our fixtures are nested and use an explicit bucket, so traverse it fully.
  await environment.withSecurityRulesDisabled(async (context) => {
    await clearFolder(ref(context.storage(bucket)));
  });
});

async function clearFolder(folder) {
  const { items, prefixes } = await listAll(folder);
  await Promise.all(items.map((item) => deleteObject(item)));
  await Promise.all(prefixes.map((prefix) => clearFolder(prefix)));
}

after(async () => {
  await environment?.cleanup();
});

function validArticle() {
  return {
    author: 'Jane Doe',
    title: 'A local news article',
    description: 'An article created for a rules test.',
    content: 'The complete article content.',
    thumbnailURL: `https://firebasestorage.googleapis.com/v0/b/${projectId}.appspot.com/o/media%2Farticles%2Farticle-1%2Fthumbnail.jpg?alt=media`,
    publishedAt: Timestamp.fromMillis(0),
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };
}

function articleReference() {
  return doc(database, 'articles/article-1');
}

describe('Firestore rules (unauthenticated client)', () => {
  test('allow a valid article to be created', async () => {
    await assertSucceeds(setDoc(articleReference(), validArticle()));
  });

  test('allow public reading of an existing article', async () => {
    await assertSucceeds(setDoc(articleReference(), validArticle()));
    const snapshot = await assertSucceeds(getDoc(articleReference()));
    assert.equal(snapshot.data().title, 'A local news article');
  });

  test('allow listing articles ordered by publication date', async () => {
    await assertSucceeds(setDoc(doc(database, 'articles/older'), {
      ...validArticle(), publishedAt: Timestamp.fromMillis(0),
    }));
    await assertSucceeds(setDoc(doc(database, 'articles/newer'), {
      ...validArticle(), publishedAt: Timestamp.fromMillis(1),
    }));
    const snapshot = await assertSucceeds(getDocs(query(
      collection(database, 'articles'),
      orderBy('publishedAt', 'desc'),
    )));
    assert.deepEqual(snapshot.docs.map((article) => article.id), ['newer', 'older']);
  });

  for (const field of Object.keys(validArticle())) {
    test(`reject a missing required field: ${field}`, async () => {
      const article = validArticle();
      delete article[field];
      await assertFails(setDoc(articleReference(), article));
    });
    test(`reject an incorrect type: ${field}`, async () => {
      await assertFails(setDoc(articleReference(), { ...validArticle(), [field]: 42 }));
    });
  }

  test('reject an additional field', async () => {
    await assertFails(setDoc(articleReference(), { ...validArticle(), extra: true }));
  });

  for (const [field, maximum] of Object.entries({
    author: 100, title: 200, description: 500, content: 50000,
  })) {
    for (const length of [0, maximum + 1]) {
      test(`reject ${field} with ${length} characters`, async () => {
        await assertFails(setDoc(articleReference(), {
          ...validArticle(), [field]: 'x'.repeat(length),
        }));
      });
    }
    test(`allow ${field} at its ${maximum}-character limit`, async () => {
      await assertSucceeds(setDoc(articleReference(), {
        ...validArticle(), [field]: 'x'.repeat(maximum),
      }));
    });
  }

  for (const thumbnailURL of [
    '',
    'https://example.com/image.jpg',
    'http://firebasestorage.googleapis.com/image.jpg',
    'https://firebasestorage.googleapis.com.evil.example/image.jpg',
  ]) {
    test(`reject invalid thumbnailURL: ${thumbnailURL || '(empty)'}`, async () => {
      await assertFails(setDoc(articleReference(), { ...validArticle(), thumbnailURL }));
    });
  }

  for (const field of ['createdAt', 'updatedAt']) {
    test(`reject ${field} that is not the server request time`, async () => {
      await assertFails(setDoc(articleReference(), {
        ...validArticle(), [field]: Timestamp.fromMillis(0),
      }));
    });
  }

  test('reject a future publication date', async () => {
    await assertFails(setDoc(articleReference(), {
      ...validArticle(), publishedAt: Timestamp.fromMillis(Date.now() + 86400000),
    }));
  });

  test('reject updating an existing article', async () => {
    await assertSucceeds(setDoc(articleReference(), validArticle()));
    await assertFails(updateDoc(articleReference(), { title: 'Changed title' }));
  });

  test('reject deleting an existing article', async () => {
    await assertSucceeds(setDoc(articleReference(), validArticle()));
    await assertFails(deleteDoc(articleReference()));
  });
});

// Synthetic bytes intentionally test the rules' MIME/size contract, not decoding.
function uploadImage(path = 'media/articles/article-1/thumbnail.jpg', {
  contentType = 'image/jpeg', size = 128,
} = {}) {
  return uploadBytes(ref(storage, path), new Uint8Array(size), { contentType });
}

describe('Storage rules (unauthenticated client)', () => {
  test('allow public reading of an existing image', async () => {
    const uploaded = await assertSucceeds(uploadImage());
    const bytes = await assertSucceeds(getBytes(uploaded.ref));
    assert.equal(bytes.byteLength, 128);
  });

  for (const [extension, contentType] of [
    ['jpg', 'image/jpeg'], ['png', 'image/png'], ['webp', 'image/webp'],
  ]) {
    test(`allow ${contentType} below 5 MiB`, async () => {
      await assertSucceeds(uploadImage(`media/articles/article-1/image.${extension}`, { contentType }));
    });
  }

  for (const path of [
    'other/article-1/image.jpg',
    'media/articles/image.jpg',
    'media/articles/article-1/nested/image.jpg',
  ]) {
    test(`reject an upload outside the exact article path: ${path}`, async () => {
      await assertFails(uploadImage(path));
    });
  }

  test('reject application/pdf even with a jpg extension', async () => {
    await assertFails(uploadImage(undefined, { contentType: 'application/pdf' }));
  });

  test('allow exactly 5 MiB', async () => {
    await assertSucceeds(uploadImage(undefined, { size: maxImageBytes }));
  });

  test('reject one byte above 5 MiB', async () => {
    await assertFails(uploadImage(undefined, { size: maxImageBytes + 1 }));
  });

  test('reject replacing an existing image', async () => {
    await assertSucceeds(uploadImage());
    await assertFails(uploadImage(undefined, { size: 256 }));
  });

  test('reject deleting an existing image', async () => {
    const uploaded = await assertSucceeds(uploadImage());
    await assertFails(deleteObject(uploaded.ref));
  });
});
