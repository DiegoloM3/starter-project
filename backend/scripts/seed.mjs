// Creates the demo journalist accounts and the `articles` collection, with its thumbnails and comments, in the
// Firebase Local Emulator Suite. Each article and comment is written by its author's account and every write goes
// through firestore.rules and storage.rules, so the seed data always follows the schema.
//
// Usage: start the emulators (`npm run emulators`) and, in another terminal, run `npm run seed`.

import { readFileSync } from 'node:fs';
import { crc32, deflateSync } from 'node:zlib';
import { initializeApp } from 'firebase/app';
import {
  connectAuthEmulator,
  createUserWithEmailAndPassword,
  getAuth,
  signInWithEmailAndPassword,
  updateProfile,
} from 'firebase/auth';
import {
  addDoc,
  collection,
  connectFirestoreEmulator,
  doc,
  getFirestore,
  serverTimestamp,
  setDoc,
} from 'firebase/firestore';
import {
  connectStorageEmulator,
  getDownloadURL,
  getStorage,
  ref,
  uploadBytes,
} from 'firebase/storage';

const EMULATOR_HOST = '127.0.0.1';
const AUTH_EMULATOR_PORT = 9099;
const FIRESTORE_EMULATOR_PORT = 8080;
const STORAGE_EMULATOR_PORT = 9199;
const THUMBNAIL_WIDTH = 640;
const THUMBNAIL_HEIGHT = 352;

function readJson(relativePath) {
  return JSON.parse(readFileSync(new URL(relativePath, import.meta.url), 'utf8'));
}

// The Firebase SDK retries forever when an emulator is down, so fail fast with a clear message instead.
async function ensureEmulatorsAreRunning() {
  for (const port of [AUTH_EMULATOR_PORT, FIRESTORE_EMULATOR_PORT, STORAGE_EMULATOR_PORT]) {
    try {
      await fetch(`http://${EMULATOR_HOST}:${port}/`, { signal: AbortSignal.timeout(2000) });
    } catch {
      throw new Error(`No emulator is listening on ${EMULATOR_HOST}:${port}.`);
    }
  }
}

function connectToEmulators() {
  const projectId = readJson('../.firebaserc').projects.default;
  const app = initializeApp({ projectId, apiKey: 'emulator-only', storageBucket: `${projectId}.firebasestorage.app` });
  const auth = getAuth(app);
  const firestore = getFirestore(app);
  const storage = getStorage(app);
  connectAuthEmulator(auth, `http://${EMULATOR_HOST}:${AUTH_EMULATOR_PORT}`, { disableWarnings: true });
  connectFirestoreEmulator(firestore, EMULATOR_HOST, FIRESTORE_EMULATOR_PORT);
  connectStorageEmulator(storage, EMULATOR_HOST, STORAGE_EMULATOR_PORT);
  return { auth, firestore, storage };
}

function buildPngChunk(type, data) {
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const typeAndData = Buffer.concat([Buffer.from(type, 'ascii'), data]);
  const checksum = Buffer.alloc(4);
  checksum.writeUInt32BE(crc32(typeAndData));
  return Buffer.concat([length, typeAndData, checksum]);
}

function buildGradientPixels([startColor, endColor]) {
  const bytesPerRow = 1 + THUMBNAIL_WIDTH * 3;
  const pixels = Buffer.alloc(bytesPerRow * THUMBNAIL_HEIGHT);
  for (let y = 0; y < THUMBNAIL_HEIGHT; y++) {
    for (let x = 0; x < THUMBNAIL_WIDTH; x++) {
      const progress = (x + y) / (THUMBNAIL_WIDTH + THUMBNAIL_HEIGHT);
      const offset = y * bytesPerRow + 1 + x * 3;
      startColor.forEach((channel, i) => {
        pixels[offset + i] = Math.round(channel + (endColor[i] - channel) * progress);
      });
    }
  }
  return pixels;
}

// Generates the thumbnail locally so the repository does not need to store binary images.
function createGradientThumbnail(colors) {
  const signature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  const header = Buffer.alloc(13);
  header.writeUInt32BE(THUMBNAIL_WIDTH, 0);
  header.writeUInt32BE(THUMBNAIL_HEIGHT, 4);
  header.set([8, 2, 0, 0, 0], 8); // 8-bit depth, RGB colour, default compression, filter and interlace.
  return Buffer.concat([
    signature,
    buildPngChunk('IHDR', header),
    buildPngChunk('IDAT', deflateSync(buildGradientPixels(colors))),
    buildPngChunk('IEND', Buffer.alloc(0)),
  ]);
}

async function uploadThumbnail(storage, articleId, colors) {
  const thumbnailRef = ref(storage, `media/articles/${articleId}.png`);
  await uploadBytes(thumbnailRef, createGradientThumbnail(colors), { contentType: 'image/png' });
  return getDownloadURL(thumbnailRef);
}

// Signs in with the demo account, creating it the first time. The token is refreshed after setting the
// name, because firestore.rules check that the author of an article is the name of the account.
async function signInAs(auth, { name, email, password }) {
  try {
    await createUserWithEmailAndPassword(auth, email, password);
    await updateProfile(auth.currentUser, { displayName: name });
    await auth.currentUser.getIdToken(true);
  } catch (error) {
    if (error.code !== 'auth/email-already-in-use') throw error;
    await signInWithEmailAndPassword(auth, email, password);
  }
  return auth.currentUser;
}

async function signInAsAuthor(auth, users, authorName) {
  return signInAs(auth, users.find((user) => user.name === authorName));
}

async function seedComment({ auth, firestore }, users, articleId, { author, content }) {
  const journalist = await signInAsAuthor(auth, users, author);
  await addDoc(collection(firestore, 'articles', articleId, 'comments'), {
    content,
    author: journalist.displayName,
    authorId: journalist.uid,
    createdAt: serverTimestamp(),
  });
  console.log(`  ✔ comment by ${journalist.displayName}`);
}

async function seedArticle(services, users, { thumbnailColors, author, comments, ...article }) {
  const { auth, firestore, storage } = services;
  const journalist = await signInAsAuthor(auth, users, author);
  const articleRef = doc(collection(firestore, 'articles'));
  const thumbnailURL = await uploadThumbnail(storage, articleRef.id, thumbnailColors);
  await setDoc(articleRef, {
    ...article,
    author: journalist.displayName,
    authorId: journalist.uid,
    thumbnailURL,
    publishedAt: serverTimestamp(),
  });
  console.log(`✔ articles/${articleRef.id} — ${article.title} (by ${journalist.displayName})`);
  // One after the other, so their creation dates keep the order of the seed data.
  for (const comment of comments) {
    await seedComment(services, users, articleRef.id, comment);
  }
}

async function seedArticles() {
  await ensureEmulatorsAreRunning();
  const services = connectToEmulators();
  const users = readJson('./seed-data/users.json');
  for (const article of readJson('./seed-data/articles.json')) {
    await seedArticle(services, users, article);
  }
  process.exit(0);
}

seedArticles().catch((error) => {
  console.error('✖ Seeding failed. Are the emulators running (`npm run emulators`)?\n', error.message);
  process.exit(1);
});
