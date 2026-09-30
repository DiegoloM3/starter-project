// Seeds the `articles` collection and `media/articles` folder with sample data.
//
// It uses the Firebase *client* SDK on purpose: every write goes through the
// same security rules as the mobile app, so a successful seed is also a smoke
// test of `firestore.rules` and `storage.rules`.
//
// Usage: npm run seed:emulator     (requires `npm run emulators` in another shell)
//        npm run seed:production   (requires the rules to be deployed first)
//
// Schema: see ../docs/DB_SCHEMA.md

import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeApp } from 'firebase/app';
import {
  collection,
  connectFirestoreEmulator,
  doc,
  getFirestore,
  serverTimestamp,
  setDoc,
  terminate,
} from 'firebase/firestore';
import {
  connectStorageEmulator,
  deleteObject,
  getDownloadURL,
  getStorage,
  ref,
  uploadBytes,
} from 'firebase/storage';

const PROJECT_ID = 'backend-news-symmetry';
const SEED_DATA_DIR = path.join(path.dirname(fileURLToPath(import.meta.url)), 'seed-data');
const DESCRIPTION_MAX_LENGTH = 300;
const CONTENT_TYPE_BY_EXTENSION = {
  '.jpg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
};

const TARGETS = {
  emulator: {
    firebaseConfig: {
      apiKey: 'emulator-fake-api-key',
      projectId: PROJECT_ID,
      storageBucket: `${PROJECT_ID}.firebasestorage.app`,
    },
    connectToEmulators(firestore, storage) {
      connectFirestoreEmulator(firestore, '127.0.0.1', 8080);
      connectStorageEmulator(storage, '127.0.0.1', 9199);
    },
    // Download URLs come back as http://127.0.0.1:9199/..., but 127.0.0.1 inside the Android
    // emulator is the device itself. Store them with the host the app reaches the emulator at:
    // 10.0.2.2 (Android emulator) or 127.0.0.1 (physical device with `adb reverse tcp:9199 tcp:9199`).
    thumbnailOrigin: `http://${process.env.EMULATOR_THUMBNAIL_HOST ?? '10.0.2.2'}:9199`,
  },
  // Web app "news-backend-scripts". Firebase client config is a public identifier, not a secret:
  // access is controlled by the security rules.
  production: {
    firebaseConfig: {
      apiKey: 'AIzaSyDux56Xf6bZou5F3ottUk1Mm_qf_-rPovU',
      authDomain: `${PROJECT_ID}.firebaseapp.com`,
      projectId: PROJECT_ID,
      storageBucket: `${PROJECT_ID}.firebasestorage.app`,
      messagingSenderId: '995237750372',
      appId: '1:995237750372:web:aa22fa99a35fe4bdc4e171',
    },
  },
};

function readTargetName() {
  const argument = process.argv.find((arg) => arg.startsWith('--target='));
  const targetName = argument?.split('=')[1] ?? 'emulator';
  if (!TARGETS[targetName]) {
    throw new Error(`Unknown target "${targetName}". Available: ${Object.keys(TARGETS).join(', ')}`);
  }
  return targetName;
}

function connectToTarget(target) {
  const app = initializeApp(target.firebaseConfig);
  const firestore = getFirestore(app);
  const storage = getStorage(app);
  target.connectToEmulators?.(firestore, storage);
  return { firestore, storage, thumbnailOrigin: target.thumbnailOrigin };
}

async function readSeedArticles() {
  const json = await readFile(path.join(SEED_DATA_DIR, 'articles.json'), 'utf8');
  return JSON.parse(json);
}

// Keep in sync with ArticleDraftEntity.description in the Flutter app
// (frontend/lib/features/journalist_articles/domain/entities/article_draft.dart):
// strip Markdown syntax, collapse whitespace, keep the first 300 UTF-16 code units
// without splitting an emoji in half.
function deriveDescription(markdown) {
  const plainText = markdown
    .replace(/!\[[^\]]*\]\([^)]*\)/g, '')
    .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/^\s{0,3}(#{1,6}|>|[-*+]|\d+\.)\s+/gm, '')
    .replace(/(\*\*|__|\*|_|~~|`)/g, '')
    .replace(/\s+/g, ' ')
    .trim();
  return truncateWithoutSplittingCharacters(plainText, DESCRIPTION_MAX_LENGTH);
}

function truncateWithoutSplittingCharacters(text, maxLength) {
  if (text.length <= maxLength) return text;
  const lastCodeUnit = text.charCodeAt(maxLength - 1);
  const endsInsideSurrogatePair = lastCodeUnit >= 0xd800 && lastCodeUnit <= 0xdbff;
  return text.slice(0, endsInsideSurrogatePair ? maxLength - 1 : maxLength);
}

async function uploadThumbnail(storage, articleId, imageFileName) {
  const extension = path.extname(imageFileName).toLowerCase();
  const thumbnailRef = ref(storage, `media/articles/${articleId}${extension}`);
  const bytes = await readFile(path.join(SEED_DATA_DIR, 'images', imageFileName));
  await uploadBytes(thumbnailRef, bytes, { contentType: CONTENT_TYPE_BY_EXTENSION[extension] });
  return thumbnailRef;
}

function withOrigin(url, origin) {
  return origin ? url.replace(/^https?:\/\/[^/]+/, origin) : url;
}

function buildArticleDocument(seedArticle, thumbnailURL) {
  return {
    title: seedArticle.title,
    content: seedArticle.content,
    description: deriveDescription(seedArticle.content),
    author: seedArticle.author,
    thumbnailURL,
    publishedAt: serverTimestamp(),
  };
}

async function writeArticleOrRemoveThumbnail(articleRef, articleDocument, thumbnailRef) {
  try {
    await setDoc(articleRef, articleDocument);
  } catch (error) {
    await deleteObject(thumbnailRef);
    throw error;
  }
}

async function publishSeedArticle({ firestore, storage, thumbnailOrigin }, seedArticle) {
  const articleRef = doc(collection(firestore, 'articles'));
  const thumbnailRef = await uploadThumbnail(storage, articleRef.id, seedArticle.image);
  const thumbnailURL = withOrigin(await getDownloadURL(thumbnailRef), thumbnailOrigin);
  await writeArticleOrRemoveThumbnail(articleRef, buildArticleDocument(seedArticle, thumbnailURL), thumbnailRef);
  console.log(`✔ articles/${articleRef.id}  "${seedArticle.title}"`);
}

async function main() {
  const targetName = readTargetName();
  const connection = connectToTarget(TARGETS[targetName]);
  console.log(`Seeding ${targetName} (${PROJECT_ID})...`);
  for (const seedArticle of await readSeedArticles()) {
    await publishSeedArticle(connection, seedArticle);
  }
  await terminate(connection.firestore);
}

main().catch((error) => {
  console.error(`✘ Seed failed: ${error.code ?? ''} ${error.message}`);
  process.exit(1);
});
