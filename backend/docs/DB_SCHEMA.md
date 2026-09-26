# Articles database schema

The app uses the named Firestore Enterprise database `articles` in `europe-southwest1`.
The public `articles` collection contains no email address, password, or private profile
information. Every accepted article is published immediately; public reads intentionally
support the community feed.

## `articles/{articleId}`

| Field | Type | Required | Constraints / ownership |
| --- | --- | --- | --- |
| `author` | string | yes | 2–100 characters; public display name copied from Auth |
| `title` | string | yes | 5–120 characters |
| `description` | string | yes | 1–240 characters; generated from `content` |
| `url` | string | yes | Must be empty in community publications; reserved for NewsAPI-compatible links |
| `urlToImage` | string | yes | Firebase Storage `getDownloadURL()` whose encoded object path exactly matches `thumbnailPath`; deployable production rules accept only `https://firebasestorage.googleapis.com/v0/b/case-study-symmetry.firebasestorage.app/o/`. The emulator-only overlay in `tests/firestore.emulator.rules` additionally accepts `http://localhost:9199/v0/b/case-study-symmetry.firebasestorage.app/o/` and `127.0.0.1`. |
| `publishedAt` | timestamp | yes | Must equal the server `request.time` at creation |
| `content` | string | yes | 20–10,000 characters |
| `thumbnailPath` | string | yes | `media/articles/{ownerUid}/{articleId}/{fileName}` |
| `payloadHash` | string | yes | Lowercase SHA-256 of title, body, and image bytes; supports safe retries |
| `ownerUid` | string | yes | Firebase Auth UID; immutable and must equal creator |
| `createdAt` | timestamp | yes | Must equal `request.time`; immutable |
| `updatedAt` | timestamp | yes | Must equal `request.time`; immutable in this first slice |

The document ID is a collision-resistant client request ID (`article-{microseconds}-{random}`),
not a user email or secret. It is reused while retrying one draft so a lost response can be
retried idempotently. Existing documents are returned only when owner and payload hash both
match; a changed retry is rejected.

## Realtime social interactions

Social data is stored in subcollections below a published article. The parent article must
exist and pass the same committed-publication validation used by the feed before any social
document can be read or written. The parent article remains immutable; counts are derived from
the subcollection listeners rather than trusted client-controlled counter fields.

### `articles/{articleId}/likes/{uid}`

| Field | Type | Required | Constraints / ownership |
| --- | --- | --- | --- |
| `uid` | string | yes | Must equal both the document ID and the authenticated Firebase Auth UID; immutable |
| `createdAt` | timestamp | yes | Must equal the Firestore server `request.time`; immutable |

There can be at most one like per authenticated user because the user UID is the like document
ID. Authenticated users can create and delete only their own like. Updates are denied. Public
`get` and unbounded `list` reads are allowed only while the parent article is a valid published
article; the unrestricted list supports a realtime like count.

### `articles/{articleId}/comments/{commentId}`

| Field | Type | Required | Constraints / ownership |
| --- | --- | --- | --- |
| `authorUid` | string | yes | 1–128 characters; must equal the authenticated Firebase Auth UID; immutable |
| `authorName` | string | yes | 1–100 characters; public display name supplied by the authenticated client; immutable |
| `body` | string | yes | 1–1,000 characters; immutable |
| `createdAt` | timestamp | yes | Must equal the Firestore server `request.time`; immutable |

Comment IDs must be safe client-generated IDs (1–128 ASCII letters, numbers, `_`, or `-`).
Authenticated users can create comments only as themselves and can delete only comments whose
`authorUid` matches their UID. Comment updates are denied. Public direct reads require a valid
parent article; collection reads require an explicit `limit` of no more than 100 documents so a
realtime listener cannot request an unbounded comment feed.

### Sharing

Sharing is an external share-sheet action for the article URL and does not write a Firestore
document in this slice. Consequently, there is no client-controlled share counter to secure.

## Storage

Article thumbnails are **required** and live at
`media/articles/{ownerUid}/{articleId}/{fileName}`. Only JPEG, PNG, and WebP objects up to
5 MiB are accepted. The app inspects raster magic bytes before upload, while Storage rules
validate authenticated owner, MIME metadata, size, path, and payload hash. Rules cannot
inspect binary bytes or prove Firestore/Storage cross-service existence; trusted byte
processing is therefore an explicit operational limitation, not claimed proof.

Public reads are limited to this exact article-image path because public browsing renders
thumbnails; all other Storage paths are denied. Firestore stores both canonical URL and path.

## Write sequence and failure handling

1. Require Auth and validate title/body/image bounds and raster signature.
2. Reuse the deterministic document ID and payload hash. If a matching document exists,
   return it; if its owner or hash differs, reject.
3. Reuse a matching existing Storage object or upload the image to its deterministic path.
4. Create the immutable Firestore document with all three server timestamps.

If the Firestore write returns an ambiguous network error, the client never deletes the
thumbnail: Firestore may have committed. Retrying the same request ID/hash reuses the object
and returns the committed document. A pre-commit orphan requires an operational cleanup job.

## Access and indexes

- Every accepted document is published immediately (`publishedAt == request.time` at create).
  Authenticated clients may read a missing document during an ID preflight; anonymous
  missing-document reads are denied. Existing anonymous direct reads require a valid
  committed article; anonymous list reads require a positive query limit no greater than 50.
  The app's feed supplies `where(publishedAt <= now)`, `orderBy(publishedAt DESC)`, and
  `limit(50)`.
- Authenticated users can create only their own fully validated article.
- Updates and deletes are denied in this first slice.
- Likes and comments are readable in realtime only beneath valid published articles. Likes are
  keyed by UID and comments are bounded to 100 documents per listener; both interaction types
  are immutable after creation except that the author may delete their own document.
- The feed orders by `publishedAt DESC` before limiting to 50. `backend/firestore.indexes.json`
  declares that query index explicitly.
