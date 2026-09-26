#!/usr/bin/env node
/**
 * Safe, idempotent seed for the Community feed.
 *
 * Default mode is a local dry-run. Production Auth, Storage and Firestore writes
 * are only possible with:
 *
 *   node backend/seed/seed-community.mjs --apply --project case-study-symmetry
 *
 * This script never deletes or updates existing article documents.
 */
import { createHash, randomUUID } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';

const PROJECT_ID = 'case-study-symmetry';
const DATABASE_ID = 'articles';
const STORAGE_BUCKET = 'case-study-symmetry.firebasestorage.app';
const AUTHOR_UID = 'symmetry-demo-editorial';
const AUTHOR_NAME = 'Symmetry Demo Editorial';
const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));
const IMAGE_DIR = path.join(SCRIPT_DIR, 'images');
const MANIFEST_PATH = path.join(SCRIPT_DIR, 'manifest.json');
const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const EXPECTED_ASPECT_RATIO = 1.82;
const ASPECT_TOLERANCE = 0.03;

function parseArgs(argv) {
  let apply = false;
  let help = false;
  let project;
  let projectProvided = false;

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === '--apply') {
      if (apply) throw new Error('Duplicate --apply flag');
      apply = true;
      continue;
    }
    if (argument === '--help' || argument === '-h') {
      if (help) throw new Error('Duplicate help flag');
      help = true;
      continue;
    }
    if (argument === '--project') {
      if (projectProvided) throw new Error('Duplicate --project flag');
      const value = argv[index + 1];
      if (!value || value.startsWith('-')) {
        throw new Error('--project requires a value');
      }
      project = value;
      projectProvided = true;
      index += 1;
      continue;
    }
    if (argument.startsWith('--project=')) {
      if (projectProvided) throw new Error('Duplicate --project flag');
      const value = argument.slice('--project='.length);
      if (!value) throw new Error('--project requires a value');
      project = value;
      projectProvided = true;
      continue;
    }
    throw new Error('Unknown argument: ' + argument);
  }

  if (help && argv.length !== 1) {
    throw new Error('--help must be used by itself');
  }
  if (projectProvided && project !== PROJECT_ID) {
    throw new Error('Unsupported project: expected ' + PROJECT_ID + ', received ' + project);
  }
  if (apply && !projectProvided) {
    throw new Error('Refusing to apply: --apply requires explicit --project ' + PROJECT_ID);
  }

  return {
    apply,
    project: project ?? PROJECT_ID,
    projectProvided,
    help,
  };
}

function descriptionFor(content) {
  if (content.length <= 240) return content;
  const preview = [];
  let codeUnits = 0;
  for (const character of content) {
    const width = character.codePointAt(0) > 0xffff ? 2 : 1;
    if (codeUnits + width > 239) break;
    preview.push(character);
    codeUnits += width;
  }
  return preview.join('') + '…';
}

function payloadHash(title, content, imageBytes) {
  const separator = Buffer.from([0]);
  return createHash('sha256')
    .update(Buffer.concat([
      Buffer.from(title, 'utf8'),
      separator,
      Buffer.from(content, 'utf8'),
      separator,
      imageBytes,
    ]))
    .digest('hex');
}

function parsePngDimensions(bytes) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  if (!bytes.subarray(0, 8).equals(signature)) {
    throw new Error('image is not a PNG');
  }
  if (bytes.toString('ascii', 12, 16) !== 'IHDR') {
    throw new Error('PNG is missing an IHDR chunk');
  }
  return {
    width: bytes.readUInt32BE(16),
    height: bytes.readUInt32BE(20),
  };
}

async function readManifest() {
  const source = await readFile(MANIFEST_PATH, 'utf8');
  const manifest = JSON.parse(source);
  if (!Array.isArray(manifest) || manifest.length !== 2) {
    throw new Error('manifest must contain exactly 2 articles');
  }
  return manifest;
}

async function buildPlan() {
  const manifest = await readManifest();
  const plan = [];
  for (const article of manifest) {
    const imagePath = path.join(IMAGE_DIR, article.image);
    const [imageBytes, imageStat] = await Promise.all([
      readFile(imagePath),
      stat(imagePath),
    ]);
    const { width, height } = parsePngDimensions(imageBytes);
    const ratio = width / height;
    const hash = payloadHash(article.title, article.content, imageBytes);
    const thumbnailPath = 'media/articles/' + AUTHOR_UID + '/' + article.id + '/' + article.image;
    plan.push({
      ...article,
      imagePath,
      imageBytes,
      imageBytesOnDisk: imageStat.size,
      width,
      height,
      ratio,
      payloadHash: hash,
      thumbnailPath,
      description: descriptionFor(article.content),
    });
  }

  validatePlan(plan);
  return plan;
}

function validatePlan(plan) {
  const ids = new Set();
  for (const article of plan) {
    if (ids.has(article.id)) throw new Error('duplicate article id: ' + article.id);
    ids.add(article.id);
    if (!/^symmetry-demo-[a-z0-9-]+$/.test(article.id)) {
      throw new Error('unsafe article id: ' + article.id);
    }
    if (article.title.length < 5 || article.title.length > 120) {
      throw new Error('title length invalid for ' + article.id);
    }
    if (article.content.length < 20 || article.content.length > 10000) {
      throw new Error('content length invalid for ' + article.id);
    }
    if (article.description.length < 1 || article.description.length > 240) {
      throw new Error('description length invalid for ' + article.id);
    }
    if (article.imageBytesOnDisk <= 0 || article.imageBytesOnDisk > MAX_IMAGE_BYTES) {
      throw new Error('image size invalid for ' + article.id);
    }
    if (article.ratio < EXPECTED_ASPECT_RATIO - ASPECT_TOLERANCE ||
        article.ratio > EXPECTED_ASPECT_RATIO + ASPECT_TOLERANCE) {
      throw new Error('image ratio invalid for ' + article.id + ': ' + article.ratio);
    }
    if (!/^[a-f0-9]{64}$/.test(article.payloadHash)) {
      throw new Error('payload hash invalid for ' + article.id);
    }
  }
}

function planSummary(plan, apply) {
  return {
    mode: apply ? 'apply' : 'dry-run',
    project: PROJECT_ID,
    database: DATABASE_ID,
    bucket: STORAGE_BUCKET,
    author: { uid: AUTHOR_UID, displayName: AUTHOR_NAME },
    count: plan.length,
    articles: plan.map((article) => ({
      id: article.id,
      title: article.title,
      image: article.image,
      bytes: article.imageBytesOnDisk,
      dimensions: article.width + 'x' + article.height,
      ratio: Number(article.ratio.toFixed(4)),
      payloadHash: article.payloadHash,
      thumbnailPath: article.thumbnailPath,
      descriptionLength: article.description.length,
      contentLength: article.content.length,
    })),
  };
}

async function ensureDemoAuthor(auth) {
  try {
    const user = await auth.getUser(AUTHOR_UID);
    if (user.displayName !== AUTHOR_NAME) {
      throw new Error('Auth user ' + AUTHOR_UID + ' exists with an unexpected display name');
    }
    return user;
  } catch (error) {
    if (error?.code !== 'auth/user-not-found') throw error;
    return auth.createUser({ uid: AUTHOR_UID, displayName: AUTHOR_NAME });
  }
}

function downloadUrl(storagePath, token) {
  return 'https://firebasestorage.googleapis.com/v0/b/' + STORAGE_BUCKET +
    '/o/' + encodeURIComponent(storagePath) + '?alt=media&token=' +
    encodeURIComponent(token);
}

async function ensureStorageObject(bucket, article) {
  const file = bucket.file(article.thumbnailPath);
  const [exists] = await file.exists();
  if (!exists) {
    const token = randomUUID();
    await file.save(article.imageBytes, {
      resumable: false,
      metadata: {
        contentType: 'image/png',
        metadata: {
          payloadHash: article.payloadHash,
          firebaseStorageDownloadTokens: token,
        },
      },
    });
    return { token, created: true };
  }

  const [metadata] = await file.getMetadata();
  const customMetadata = metadata.metadata ?? {};
  if (customMetadata.payloadHash !== article.payloadHash) {
    throw new Error('Storage payload hash conflict at ' + article.thumbnailPath);
  }
  if (metadata.contentType !== 'image/png') {
    throw new Error('Storage content type conflict at ' + article.thumbnailPath);
  }
  let token = customMetadata.firebaseStorageDownloadTokens;
  if (!token) {
    token = randomUUID();
    await file.setMetadata({
      metadata: {
        ...customMetadata,
        firebaseStorageDownloadTokens: token,
      },
    });
  }
  return { token, created: false };
}

async function applyPlan(plan) {
  const { initializeApp, applicationDefault, getApps } = await import('firebase-admin/app');
  const { getAuth } = await import('firebase-admin/auth');
  const { FieldValue, getFirestore } = await import('firebase-admin/firestore');
  const { getStorage } = await import('firebase-admin/storage');

  const app = getApps().find((candidate) => candidate.name === 'community-seed')
    ?? initializeApp({
      credential: applicationDefault(),
      projectId: PROJECT_ID,
      storageBucket: STORAGE_BUCKET,
    }, 'community-seed');

  const auth = getAuth(app);
  const firestore = getFirestore(app, DATABASE_ID);
  const bucket = getStorage(app).bucket(STORAGE_BUCKET);
  const author = await ensureDemoAuthor(auth);
  const results = [];

  for (const article of plan) {
    const document = firestore.collection('articles').doc(article.id);
    const existing = await document.get();
    if (existing.exists) {
      const data = existing.data() ?? {};
      if (data.ownerUid !== AUTHOR_UID || data.payloadHash !== article.payloadHash) {
        throw new Error('Firestore payload conflict at articles/' + article.id);
      }
      results.push({ id: article.id, status: 'skipped-existing' });
      continue;
    }

    const object = await ensureStorageObject(bucket, article);
    await document.create({
      author: AUTHOR_NAME,
      title: article.title,
      description: article.description,
      url: '',
      urlToImage: downloadUrl(article.thumbnailPath, object.token),
      publishedAt: FieldValue.serverTimestamp(),
      content: article.content,
      thumbnailPath: article.thumbnailPath,
      payloadHash: article.payloadHash,
      ownerUid: AUTHOR_UID,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    results.push({
      id: article.id,
      status: 'created',
      storage: object.created ? 'uploaded' : 'reused',
    });
  }

  console.log(JSON.stringify({
    mode: 'apply',
    project: PROJECT_ID,
    database: DATABASE_ID,
    bucket: STORAGE_BUCKET,
    author: { uid: author.uid, displayName: author.displayName },
    count: plan.length,
    results,
  }, null, 2));
}

function printHelp() {
  console.log([
    'Community demo seed',
    '',
    'Dry-run (default, no network or Firebase writes):',
    '  node backend/seed/seed-community.mjs',
    '',
    'Apply (explicit production writes; requires Firebase Admin ADC):',
    '  node backend/seed/seed-community.mjs --apply --project case-study-symmetry',
    '',
    'The apply mode is idempotent and never deletes or updates existing article documents.',
  ].join('\n'));
}

try {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    process.exit(0);
  }
  const plan = await buildPlan();
  console.log(JSON.stringify(planSummary(plan, args.apply), null, 2));
  if (args.apply) {
    await applyPlan(plan);
  } else {
    console.error('Dry-run only. No Firebase Admin modules were loaded and no network writes were attempted.');
  }
} catch (error) {
  console.error('Community seed failed: ' + error.message);
  process.exitCode = 1;
}
