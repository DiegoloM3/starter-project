// Creates demo data in the Firebase project: journalists with articles, readers who follow
// them and comment, so the app can be tried without writing everything by hand.
//
// Usage:
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json npm run seed
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json npm run seed -- --remove
//
// The ids are fixed, so running it again updates the demo data instead of duplicating it.
// All demo accounts use the password in demo_data.js.

import { randomUUID } from 'node:crypto';

import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

import { ARTICLES, COMMENTS, DEMO_PASSWORD, FOLLOWS, JOURNALISTS, READERS } from './demo_data.js';

const BUCKET = 'symmetry-technical-test-6230c.firebasestorage.app';
const HIGHLIGHT_COLOR = '#808080';
const HOUR_IN_MILLISECONDS = 60 * 60 * 1000;

initializeApp({ storageBucket: BUCKET });
const auth = getAuth();
const firestore = getFirestore();
const bucket = getStorage().bucket();

const ALL_USERS = [...JOURNALISTS, ...READERS];

async function main() {
  if (process.argv.includes('--remove')) {
    await removeDemoData();
    console.log('Demo data removed.');
    return;
  }
  await createUsers();
  await createArticles();
  await createComments();
  await createFollows();
  console.log(`Demo data ready. Sign in with any demo email and the password ${DEMO_PASSWORD}:`);
  for (const user of ALL_USERS) console.log(`  ${user.email} (${roleOf(user)})`);
}

// ---------- Users ----------

function roleOf(user) {
  return JOURNALISTS.includes(user) ? 'journalist' : 'reader';
}

function fullNameOf(uid) {
  const user = ALL_USERS.find((candidate) => candidate.uid === uid);
  return `${user.firstName} ${user.lastName}`;
}

async function createUsers() {
  for (const user of ALL_USERS) {
    await upsertAccount(user);
    const role = roleOf(user);
    await auth.setCustomUserClaims(user.uid, role === 'journalist' ? { role } : null);
    const profile = firestore.doc(`users/${user.uid}`);
    await profile.set({
      firstName: user.firstName,
      lastName: user.lastName,
      bio: user.bio,
      photoURL: null,
      role,
      createdAt: Timestamp.now(),
    });
    await profile.collection('private').doc('account').set({ email: user.email, notificationsEnabled: true });
  }
}

async function upsertAccount(user) {
  const account = { email: user.email, password: DEMO_PASSWORD, displayName: fullNameOf(user.uid) };
  try {
    await auth.updateUser(user.uid, account);
  } catch (error) {
    if (error.code !== 'auth/user-not-found') throw error;
    await auth.createUser({ uid: user.uid, ...account });
  }
}

// ---------- Articles ----------

async function createArticles() {
  for (const article of ARTICLES) {
    const thumbnailURL = await uploadThumbnail(article.id);
    await firestore.doc(`articles/${article.id}`).set({
      title: article.title,
      description: article.description,
      content: JSON.stringify(toDelta(article.content)),
      thumbnailURL,
      topics: article.topics,
      publishedAt: Timestamp.fromMillis(publishedAtOf(article)),
      authorId: article.authorId,
      authorName: fullNameOf(article.authorId),
    });
    console.log(`Published "${article.title}"`);
  }
}

function publishedAtOf(article) {
  return Date.now() - article.daysAgo * 24 * HOUR_IN_MILLISECONDS;
}

// The app expects download URLs of files in media/articles/, as the security rules require.
async function uploadThumbnail(articleId) {
  const response = await fetch(`https://picsum.photos/seed/${articleId}/1200/675`);
  if (!response.ok) throw new Error(`Could not download the image for ${articleId}: ${response.status}`);
  const path = `media/articles/${articleId}.jpg`;
  const token = randomUUID();
  await bucket.file(path).save(Buffer.from(await response.arrayBuffer()), {
    contentType: 'image/jpeg',
    metadata: { metadata: { firebaseStorageDownloadTokens: token } },
  });
  return `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
}

// Converts the blocks of demo_data.js into Quill Delta, the format of the app editor.
function toDelta(blocks) {
  const operations = [];
  for (const block of blocks) {
    if (block.p) operations.push(...block.p.map(toInsert), { insert: '\n' });
    if (block.h) operations.push({ insert: block.h }, { insert: '\n', attributes: { header: 2 } });
    if (block.quote) operations.push({ insert: block.quote }, { insert: '\n', attributes: { blockquote: true } });
    for (const item of block.list ?? []) {
      operations.push({ insert: item }, { insert: '\n', attributes: { list: 'bullet' } });
    }
  }
  return operations;
}

function toInsert(segment) {
  if (typeof segment === 'string') return { insert: segment };
  if (segment.bold) return { insert: segment.bold, attributes: { bold: true } };
  return { insert: segment.highlight, attributes: { background: HIGHLIGHT_COLOR } };
}

// ---------- Comments and follows ----------

async function createComments() {
  for (const [index, comment] of COMMENTS.entries()) {
    const article = ARTICLES.find((candidate) => candidate.id === comment.articleId);
    const createdAt = Math.min(publishedAtOf(article) + comment.hoursAfter * HOUR_IN_MILLISECONDS, Date.now());
    await firestore.doc(`articles/${comment.articleId}/comments/demo-comment-${index + 1}`).set({
      authorId: comment.authorId,
      authorName: fullNameOf(comment.authorId),
      text: comment.text,
      createdAt: Timestamp.fromMillis(createdAt),
    });
  }
}

async function createFollows() {
  for (const [followerId, followedId] of FOLLOWS) {
    await firestore.doc(`follows/${followerId}_${followedId}`).set({ followerId, followedId, createdAt: Timestamp.now() });
  }
}

// ---------- Removal ----------

// Also removes the follows of real users to demo users, which would point to missing profiles.
async function removeDemoData() {
  const demoUserIds = ALL_USERS.map((user) => user.uid);
  for (const article of ARTICLES) await firestore.recursiveDelete(firestore.doc(`articles/${article.id}`));
  for (const uid of demoUserIds) await firestore.recursiveDelete(firestore.doc(`users/${uid}`));
  await deleteFollowsOf(demoUserIds);
  await bucket.deleteFiles({ prefix: 'media/articles/demo-article-' });
  await auth.deleteUsers(demoUserIds);
}

async function deleteFollowsOf(uids) {
  for (const field of ['followerId', 'followedId']) {
    const follows = await firestore.collection('follows').where(field, 'in', uids).get();
    await Promise.all(follows.docs.map((follow) => follow.ref.delete()));
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
