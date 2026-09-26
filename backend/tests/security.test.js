const assert = require('node:assert/strict');
const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');
const { initializeApp, deleteApp } = require('firebase/app');
const {
  connectAuthEmulator,
  createUserWithEmailAndPassword,
  getAuth,
} = require('firebase/auth');
const {
  collection,
  connectFirestoreEmulator,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  getFirestore,
  limit,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  where,
} = require('firebase/firestore');
const {
  connectStorageEmulator,
  deleteObject,
  getBytes,
  getStorage,
  ref,
  updateMetadata,
  uploadBytes,
} = require('firebase/storage');

const PROJECT_ID = 'case-study-symmetry';
const DATABASE_ID = 'articles';
const FIRESTORE_HOST = '127.0.0.1';
const STORAGE_HOST = '127.0.0.1';
const RUN_ID = `${Date.now()}-${process.pid}-${Math.random().toString(36).slice(2, 8)}`;
const clients = [];

/**
 * The Firestore emulator currently starts one rules watcher for (default),
 * even when firebase.json names another database. Load the exact checked-in
 * rules into the named database before every test run so these assertions
 * cannot accidentally exercise a stale/default ruleset.
 */
async function loadNamedFirestoreRules(rulesPath = path.join(__dirname, '..', 'firestore.rules')) {
  const content = fs.readFileSync(
    rulesPath,
    'utf8',
  );
  const body = JSON.stringify({
    ignore_errors: false,
    rules: { files: [{ name: 'security.rules', content }] },
  });
  await new Promise((resolve, reject) => {
    const request = http.request({
      hostname: FIRESTORE_HOST,
      port: 8080,
      path: `/emulator/v1/projects/${PROJECT_ID}/databases/${DATABASE_ID}:securityRules`,
      method: 'PUT',
      headers: {
        'content-type': 'application/json',
        'content-length': Buffer.byteLength(body),
      },
    }, (response) => {
      let responseBody = '';
      response.on('data', (chunk) => { responseBody += chunk; });
      response.on('end', () => {
        if (response.statusCode !== 200) {
          reject(new Error(`named rules load failed (${response.statusCode}): ${responseBody}`));
          return;
        }
        resolve();
      });
    });
    request.on('error', reject);
    request.write(body);
    request.end();
  });
}

// A complete 1x1 PNG, used to prove the positive Storage fixture is a real
// raster image. Rules intentionally validate metadata/size only; they cannot
// inspect binary bytes or prove a Firestore document exists cross-service.
const TINY_PNG = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  'base64',
);

function idFor(label) {
  return `article-${RUN_ID}-${label}`;
}

function makeClient(label) {
  const app = initializeApp(
    {
      apiKey: 'demo-key',
      authDomain: `${PROJECT_ID}.firebaseapp.com`,
      projectId: PROJECT_ID,
    },
    `${label}-${RUN_ID}-${Math.random().toString(36).slice(2)}`,
  );
  const auth = getAuth(app);
  connectAuthEmulator(auth, `http://${FIRESTORE_HOST}:9099`, {
    disableWarnings: true,
  });
  // Always use the named Enterprise database; never fall back to (default).
  const firestore = getFirestore(app, DATABASE_ID);
  connectFirestoreEmulator(firestore, FIRESTORE_HOST, 8080);
  const storage = getStorage(app, `gs://${PROJECT_ID}.firebasestorage.app`);
  connectStorageEmulator(storage, STORAGE_HOST, 9199);
  const client = { app, auth, firestore, storage };
  clients.push(client);
  return client;
}

async function signedInClient(label) {
  const client = makeClient(label);
  const email = `${label}-${RUN_ID}@example.test`;
  const credential = await createUserWithEmailAndPassword(
    client.auth,
    email,
    'Valid-password-123',
  );
  return { ...client, uid: credential.user.uid };
}

async function assertDenied(promise, expectedCode = 'permission-denied') {
  await assert.rejects(
    promise,
    (error) => error && error.code === expectedCode,
    `expected ${expectedCode}`,
  );
}

function storageUrl(articleId, ownerUid, fileName, origin = 'production') {
  const prefix = origin === 'production'
    ? `https://firebasestorage.googleapis.com/v0/b/${PROJECT_ID}.firebasestorage.app/o/`
    : `http://${origin}:9199/v0/b/${PROJECT_ID}.firebasestorage.app/o/`;
  const encodedPath = `media%2Farticles%2F${ownerUid}%2F${articleId}%2F${fileName}`;
  return `${prefix}${encodedPath}?alt=media&token=test-token`;
}

function validArticle(ownerUid, articleId) {
  return {
    author: 'Reporter',
    title: 'A valid article title',
    description: 'A short generated description for this article.',
    url: '',
    urlToImage: storageUrl(articleId, ownerUid, 'image.png'),
    publishedAt: serverTimestamp(),
    content: 'This article contains enough body text to satisfy the publication contract.',
    thumbnailPath: `media/articles/${ownerUid}/${articleId}/image.png`,
    payloadHash: 'a'.repeat(64),
    ownerUid,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };
}

async function createArticle(client, articleId, overrides = {}) {
  const payload = { ...validArticle(client.uid, articleId), ...overrides };
  return setDoc(doc(client.firestore, 'articles', articleId), payload);
}

describe('Firestore and Storage security rules (named articles database)', () => {
  before(async () => loadNamedFirestoreRules());

  after(async () => {
    await Promise.all(clients.map((client) => deleteApp(client.app)));
    // Leave local browser verification on the emulator-only overlay. Production
    // rules were loaded for every assertion above and remain the deploy target.
    await loadNamedFirestoreRules(path.join(__dirname, 'firestore.emulator.rules'));
  });

  it('allows anonymous bounded ordered feed reads and rejects unbounded/oversized lists', async () => {
    const owner = await signedInClient('feed-owner');
    const articleId = idFor('feed');
    await createArticle(owner, articleId);

    const visitor = makeClient('feed-visitor');
    const direct = await getDoc(doc(visitor.firestore, 'articles', articleId));
    assert.equal(direct.exists(), true);
    assert.equal(direct.data().title, 'A valid article title');

    const feed = await getDocs(query(
      collection(visitor.firestore, 'articles'),
      where('publishedAt', '<=', Timestamp.now()),
      orderBy('publishedAt', 'desc'),
      limit(50),
    ));
    assert.ok(feed.docs.some((article) => article.id === articleId));
    assert.ok(feed.docs.length <= 50);

    await assertDenied(getDocs(query(
      collection(visitor.firestore, 'articles'),
      orderBy('publishedAt', 'desc'),
      limit(51),
    )));
    await assertDenied(getDocs(query(
      collection(visitor.firestore, 'articles'),
      orderBy('publishedAt', 'desc'),
    )));
  });

  it('allows only an authenticated owner to create a valid article', async () => {
    const owner = await signedInClient('owner');
    const foreign = await signedInClient('foreign-owner');
    const anonymous = makeClient('anonymous-writer');
    const articleId = idFor('ownership');

    await assertDenied(setDoc(
      doc(foreign.firestore, 'articles', articleId),
      validArticle(owner.uid, articleId),
    ));
    await assertDenied(setDoc(
      doc(anonymous.firestore, 'articles', idFor('anonymous')),
      validArticle(owner.uid, idFor('anonymous')),
    ));
    await assert.doesNotReject(createArticle(owner, articleId));
  });

  it('rejects unknown fields, wrong types, missing/mismatched thumbnails, and forged timestamps', async () => {
    const owner = await signedInClient('schema');
    const extra = validArticle(owner.uid, idFor('extra'));
    extra.unexpected = true;
    await assertDenied(setDoc(doc(owner.firestore, 'articles', idFor('extra')), extra));

    await assertDenied(createArticle(owner, idFor('wrong-type'), { title: 42 }));
    const missingPath = (() => {
      const payload = validArticle(owner.uid, idFor('missing-path'));
      delete payload.thumbnailPath;
      return payload;
    })();
    await assertDenied(setDoc(
      doc(owner.firestore, 'articles', idFor('missing-path')),
      missingPath,
    ));
    await assertDenied(createArticle(owner, idFor('mismatched-path'), {
      thumbnailPath: `media/articles/${owner.uid}/${idFor('mismatched-path')}/different.png`,
    }));
    await assertDenied(createArticle(owner, idFor('mismatched-url'), {
      urlToImage: storageUrl(idFor('mismatched-url'), owner.uid, 'different.png'),
    }));
    await assertDenied(createArticle(owner, idFor('arbitrary-url'), {
      urlToImage: 'https://attacker.example/image.png?token=bad',
    }));
    for (const origin of ['localhost', '127.0.0.1']) {
      const loopbackId = idFor(`loopback-${origin}`);
      await assertDenied(createArticle(owner, loopbackId, {
        urlToImage: storageUrl(loopbackId, owner.uid, 'image.png', origin),
      }));
    }
    await assertDenied(createArticle(owner, idFor('future'), {
      createdAt: Timestamp.fromMillis(Date.now() + 60_000),
      publishedAt: Timestamp.fromMillis(Date.now() + 60_000),
      updatedAt: Timestamp.fromMillis(Date.now() + 60_000),
    }));
    await assertDenied(createArticle(owner, idFor('past'), {
      createdAt: Timestamp.fromMillis(Date.now() - 60_000),
      publishedAt: Timestamp.fromMillis(Date.now() - 60_000),
      updatedAt: Timestamp.fromMillis(Date.now() - 60_000),
    }));
  });

  it('allows authenticated missing-document preflight before first publish', async () => {
    const owner = await signedInClient('preflight-owner');
    const anonymous = makeClient('preflight-anonymous');
    const articleId = idFor('first-publish');

    const missing = await getDoc(doc(owner.firestore, 'articles', articleId));
    assert.equal(missing.exists(), false);
    await assertDenied(getDoc(doc(anonymous.firestore, 'articles', articleId)));

    await assert.doesNotReject(createArticle(owner, articleId));
    const committed = await getDoc(doc(makeClient('preflight-reader').firestore, 'articles', articleId));
    assert.equal(committed.exists(), true);
    assert.equal(committed.data().ownerUid, owner.uid);
  });

  it('denies Firestore update/delete bypasses after an immutable publish', async () => {
    const owner = await signedInClient('immutable-owner');
    const foreign = await signedInClient('immutable-foreign');
    const articleId = idFor('immutable');
    await createArticle(owner, articleId);

    await assertDenied(updateDoc(
      doc(owner.firestore, 'articles', articleId),
      { title: 'Changed title' },
    ));
    await assertDenied(updateDoc(
      doc(foreign.firestore, 'articles', articleId),
      { ownerUid: foreign.uid },
    ));
    await assertDenied(deleteDoc(doc(owner.firestore, 'articles', articleId)));
  });

  it('enforces one immutable like per authenticated UID and a published parent', async () => {
    const owner = await signedInClient('like-owner');
    const foreign = await signedInClient('like-foreign');
    const anonymous = makeClient('like-anonymous');
    const visitor = makeClient('like-visitor');
    const articleId = idFor('likes');
    await createArticle(owner, articleId);

    const ownerLike = doc(
      owner.firestore,
      'articles', articleId, 'likes', owner.uid,
    );
    await setDoc(ownerLike, {
      uid: owner.uid,
      createdAt: serverTimestamp(),
    });

    const publicLikes = await getDocs(collection(
      visitor.firestore,
      'articles', articleId, 'likes',
    ));
    assert.equal(publicLikes.size, 1);
    assert.equal(publicLikes.docs[0].data().uid, owner.uid);

    // Reusing the same UID document is an update, not a second like, and all
    // updates are denied. A different UID cannot impersonate the owner path.
    await assertDenied(setDoc(ownerLike, {
      uid: owner.uid,
      createdAt: serverTimestamp(),
    }));
    await assertDenied(setDoc(
      doc(foreign.firestore, 'articles', articleId, 'likes', owner.uid),
      { uid: owner.uid, createdAt: serverTimestamp() },
    ));
    await assertDenied(setDoc(
      doc(foreign.firestore, 'articles', articleId, 'likes', foreign.uid),
      { uid: owner.uid, createdAt: serverTimestamp() },
    ));
    await assertDenied(setDoc(
      doc(anonymous.firestore, 'articles', articleId, 'likes', 'anonymous'),
      { uid: 'anonymous', createdAt: serverTimestamp() },
    ));

    await assertDenied(setDoc(
      doc(owner.firestore, 'articles', articleId, 'likes', idFor('malformed')),
      { uid: owner.uid, createdAt: serverTimestamp(), extra: true },
    ));
    await assertDenied(updateDoc(ownerLike, { uid: foreign.uid }));
    await assertDenied(deleteDoc(doc(
      foreign.firestore,
      'articles', articleId, 'likes', owner.uid,
    )));
    await assert.doesNotReject(deleteDoc(ownerLike));

    const missingArticleId = idFor('orphan-like');
    await assertDenied(setDoc(
      doc(owner.firestore, 'articles', missingArticleId, 'likes', owner.uid),
      { uid: owner.uid, createdAt: serverTimestamp() },
    ));
    await assertDenied(getDocs(collection(
      visitor.firestore,
      'articles', missingArticleId, 'likes',
    )));
  });

  it('validates comment schema, ownership, parent, and bounded list queries', async () => {
    const owner = await signedInClient('comment-owner');
    const foreign = await signedInClient('comment-foreign');
    const anonymous = makeClient('comment-anonymous');
    const visitor = makeClient('comment-visitor');
    const articleId = idFor('comments');
    await createArticle(owner, articleId);

    const commentRef = doc(
      owner.firestore,
      'articles', articleId, 'comments', 'comment-one',
    );
    await setDoc(commentRef, {
      authorUid: owner.uid,
      authorName: 'Article Owner',
      body: 'A valid comment from the article owner.',
      createdAt: serverTimestamp(),
    });

    const publicComment = await getDoc(doc(
      visitor.firestore,
      'articles', articleId, 'comments', 'comment-one',
    ));
    assert.equal(publicComment.exists(), true);
    assert.equal(publicComment.data().authorUid, owner.uid);

    const boundedComments = await getDocs(query(
      collection(visitor.firestore, 'articles', articleId, 'comments'),
      orderBy('createdAt', 'asc'),
      limit(100),
    ));
    assert.equal(boundedComments.size, 1);
    await assertDenied(getDocs(query(
      collection(visitor.firestore, 'articles', articleId, 'comments'),
      limit(101),
    )));
    await assertDenied(getDocs(collection(
      visitor.firestore,
      'articles', articleId, 'comments',
    )));

    await assertDenied(setDoc(
      doc(anonymous.firestore, 'articles', articleId, 'comments', 'anonymous'),
      {
        authorUid: 'anonymous',
        authorName: 'Anonymous',
        body: 'Unauthenticated comment.',
        createdAt: serverTimestamp(),
      },
    ));
    await assertDenied(setDoc(
      doc(foreign.firestore, 'articles', articleId, 'comments', 'spoofed'),
      {
        authorUid: owner.uid,
        authorName: 'Impersonator',
        body: 'This must not be accepted.',
        createdAt: serverTimestamp(),
      },
    ));
    await assertDenied(setDoc(
      doc(owner.firestore, 'articles', articleId, 'comments', 'wrong-name'),
      {
        authorUid: owner.uid,
        authorName: 42,
        body: 'Wrong author name type.',
        createdAt: serverTimestamp(),
      },
    ));
    await assertDenied(setDoc(
      doc(owner.firestore, 'articles', articleId, 'comments', 'too-long'),
      {
        authorUid: owner.uid,
        authorName: 'Article Owner',
        body: 'x'.repeat(1001),
        createdAt: serverTimestamp(),
      },
    ));
    await assertDenied(setDoc(
      doc(owner.firestore, 'articles', articleId, 'comments', 'extra-field'),
      {
        authorUid: owner.uid,
        authorName: 'Article Owner',
        body: 'This has an undocumented field.',
        createdAt: serverTimestamp(),
        extra: true,
      },
    ));
    await assertDenied(setDoc(
      doc(owner.firestore, 'articles', articleId, 'comments', 'wrong-time'),
      {
        authorUid: owner.uid,
        authorName: 'Article Owner',
        body: 'This timestamp is not the server timestamp.',
        createdAt: Timestamp.now(),
      },
    ));
    await assertDenied(updateDoc(commentRef, { body: 'Edited comment.' }));
    await assertDenied(deleteDoc(doc(
      foreign.firestore,
      'articles', articleId, 'comments', 'comment-one',
    )));
    await assert.doesNotReject(deleteDoc(commentRef));

    const missingArticleId = idFor('orphan-comment');
    await assertDenied(setDoc(
      doc(owner.firestore, 'articles', missingArticleId, 'comments', 'comment'),
      {
        authorUid: owner.uid,
        authorName: 'Article Owner',
        body: 'An orphan comment must be rejected.',
        createdAt: serverTimestamp(),
      },
    ));
    await assertDenied(getDocs(query(
      collection(visitor.firestore, 'articles', missingArticleId, 'comments'),
      limit(100),
    )));
  });

  it('allows valid public thumbnail reads but denies Storage write/update/delete abuse', async () => {
    const owner = await signedInClient('storage-owner');
    const foreign = await signedInClient('storage-foreign');
    const visitor = makeClient('storage-visitor');
    const articleId = idFor('image');
    const goodPath = `media/articles/${owner.uid}/${articleId}/image.png`;
    const metadata = {
      contentType: 'image/png',
      customMetadata: { payloadHash: 'a'.repeat(64) },
    };

    await assert.doesNotReject(uploadBytes(
      ref(owner.storage, goodPath),
      TINY_PNG,
      metadata,
    ));
    const downloaded = await getBytes(ref(visitor.storage, goodPath));
    assert.deepEqual(Buffer.from(downloaded), TINY_PNG);

    await assertDenied(
      uploadBytes(ref(visitor.storage, goodPath), TINY_PNG, metadata),
      'storage/unauthorized',
    );
    await assertDenied(
      updateMetadata(ref(owner.storage, goodPath), { cacheControl: 'no-cache' }),
      'storage/unauthorized',
    );
    await assertDenied(
      deleteObject(ref(owner.storage, goodPath)),
      'storage/unauthorized',
    );
    await assertDenied(
      deleteObject(ref(foreign.storage, goodPath)),
      'storage/unauthorized',
    );
    await assertDenied(
      getBytes(ref(visitor.storage, `private/${articleId}.png`)),
      'storage/unauthorized',
    );
    await assertDenied(
      uploadBytes(ref(visitor.storage, `media/articles/${owner.uid}/${articleId}/foreign.png`), TINY_PNG, metadata),
      'storage/unauthorized',
    );

    await assertDenied(uploadBytes(
      ref(owner.storage, `media/articles/${owner.uid}/${idFor('text')}/file.txt`),
      Buffer.from('not an image'),
      { contentType: 'text/plain', customMetadata: { payloadHash: 'a'.repeat(64) } },
    ), 'storage/unauthorized');
    await assertDenied(uploadBytes(
      ref(owner.storage, `media/articles/${owner.uid}/${idFor('metadata')}/image.png`),
      TINY_PNG,
      { contentType: 'image/png', customMetadata: { payloadHash: 'a'.repeat(64), extra: 'deny' } },
    ), 'storage/unauthorized');
    await assertDenied(uploadBytes(
      ref(owner.storage, `media/articles/${owner.uid}/${idFor('hash')}/image.png`),
      TINY_PNG,
      { contentType: 'image/png', customMetadata: { payloadHash: 'not-a-sha' } },
    ), 'storage/unauthorized');
    await assertDenied(uploadBytes(
      ref(owner.storage, `media/articles/${owner.uid}/${idFor('large')}/image.png`),
      Buffer.alloc(5 * 1024 * 1024 + 1),
      metadata,
    ), 'storage/unauthorized');
    await assertDenied(uploadBytes(
      ref(owner.storage, `unknown/${idFor('unknown')}.png`),
      TINY_PNG,
      metadata,
    ), 'storage/unauthorized');
  });
});
