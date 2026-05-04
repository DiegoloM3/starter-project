# Symmetry News — Database Schema

> Source of truth for Firestore + Cloud Storage layout.
> Maps to: `backend/.firebaserc` → `symmetry-news-test` (us-central1 / nam5).
> Region is **locked**: Vector Search requires `nam5` or `eur3` — cannot be changed post-creation.
> Requires: `cloud_firestore ^5.4.0` (native Vector field type for `embedding`).

## Implementation status

This document mixes the **deployed schema** with **reserved field names** for future changes. Each field is marked:

- ✅ **Deployed** — written by current production code
- 🔜 **Reserved** — name reserved; implementation deferred to a named follow-up change
- ⚠️ **Partial** — partly written (e.g., field exists but counters aren't reconciled server-side)

Collections marked ✅ at the heading level are fully deployed; ⚠️ have at least one production write path; 🔜 are not yet created.

---

## Conventions

- **Field markers**: `REQUIRED` / `OPTIONAL` / `FUTURE`
- **Types**: `string`, `number`, `bool`, `Timestamp`, `GeoPoint`, `Vector`, `reference`, `array<T>`
- All `Timestamp` fields are server-side via `FieldValue.serverTimestamp()` unless explicitly noted.
- All counters are denormalized; the truth-source is a reconciliation Cloud Function, not the client.
- `FUTURE` fields are documented to reserve the name — they are NOT created by this change.

---

## Collections Diagram

```mermaid
erDiagram
  USERS ||--o{ ARTICLES : "authors"
  USERS ||--o{ USER_FAVORITES : "tracks"
  ARTICLES ||--o{ ARTICLE_FAVORITES : "received_from"
  ARTICLES ||--o{ ARTICLE_VIEWS : "received"
  USER_FAVORITES }o--|| ARTICLES : "refs"
  ARTICLE_FAVORITES }o--|| USERS : "from"
  RECOMMENDATIONS }o--|| USERS : "for"
  USERNAMES }o--|| USERS : "reserves"

  USERS {
    string userId PK
    string email
    string username UK
    bool isAnonymous
    string timezone
    int currentStreak
  }
  ARTICLES {
    string articleId PK
    string title
    string source
    string status
    Vector embedding
  }
  ARTICLE_FAVORITES {
    string userId PK
    Timestamp favoritedAt
  }
  USER_FAVORITES {
    string articleId PK
    Timestamp favoritedAt
    string articleTitle
  }
  ARTICLE_VIEWS {
    string viewId PK
    string userId
    Timestamp viewedAt
  }
  RECOMMENDATIONS {
    string userId PK
    Timestamp expiresAt
  }
  USERNAMES {
    string usernameLowercase PK
    string userId
  }
```

---

## Collections

### `users/{userId}` ⚠️

Auth-derived profile fields. Streak + engagement counters are reserved for the deferred `analytics-dashboard` change.

| Field | Type | Status | Notes |
|-------|------|--------|-------|
| `email` | string | ✅ | from FirebaseAuth |
| `displayName` | string | ✅ | |
| `photoURL` | string | ✅ | URL to Storage `media/users/{userId}/avatar.jpg` or external |
| `providerId` | string | ✅ | enum: `"google.com"` \| `"password"` \| `"anonymous"` |
| `isAnonymous` | bool | ✅ | `true` for anonymous users, `false` after identity conversion |
| `createdAt` | Timestamp | ✅ | server-side |
| `username` | string | 🔜 (`username-uniqueness`) | unique, validated against `usernames/{lowercase}` |
| `bio` | string | 🔜 (`profile-v2`) | maxLength 280 |
| `verified` | bool | 🔜 (`profile-v2`) | default `false` |
| `timezone` | string | 🔜 (`analytics-dashboard`) | IANA tz id, e.g. `"America/Mexico_City"` |
| `currentStreak` | number | 🔜 (`analytics-dashboard`) | resets at 00:00 in user-local time |
| `longestStreak` | number | 🔜 (`analytics-dashboard`) | |
| `lastPublishDate` | string | 🔜 (`analytics-dashboard`) | `YYYY-MM-DD` in user's timezone |
| `articlesPublished` | number | 🔜 (`analytics-dashboard`) | denormalized counter |
| `totalReads` | number | 🔜 (`analytics-dashboard`) | denormalized counter |
| `totalFavoritesReceived` | number | 🔜 (`analytics-dashboard`) | denormalized counter |

**Deployed fields**: 6. **Reserved**: 10.

---

### `articles/{articleId}`

Core content document. Groups: NewsAPI parity, Symmetry-aligned, authorship, source, AI, lifecycle, engagement.

**Naming convention for cross-collection references**: FK fields are named after the target collection (e.g., `userId` for `users/{userId}`). Denormalized snapshot fields share the same prefix (`userDisplayName`, `userPhotoUrl`). Role prefixes (e.g., `authorId`) are reserved for documents that reference the same collection from multiple distinct roles. See engram observation #403.

| Field | Type | Marker | Notes |
|-------|------|--------|-------|
| `title` | string | REQUIRED | 5..200 chars |
| `description` | string | REQUIRED | 20..500 chars |
| `content` | string | REQUIRED | minLength 50 |
| `url` | string | OPTIONAL | external URL for newsapi-sourced articles |
| `urlToImage` | string | REQUIRED | mandatory thumbnail; points to Storage path or external URL |
| `publishedAt` | Timestamp | REQUIRED | server-side |
| `userId` | reference | REQUIRED | FK → `users/{userId}` — Firebase Auth UID of the article author |
| `userDisplayName` | string | REQUIRED | denormalized from `users/{userId}.displayName`; see [Open Questions](#open-questions) |
| `userPhotoUrl` | string | OPTIONAL | denormalized from `users/{userId}.photoURL` |
| `source` | string | REQUIRED | enum: `"journalist"` \| `"newsapi"` |
| `category` | string | REQUIRED | enum: `"fitness"` \| `"news"` \| `"lifestyle"` \| `"tech"` \| `"other"` |
| `tags` | array\<string\> | OPTIONAL | maxItems 10 |
| `language` | string | REQUIRED | ISO 639-1 (e.g. `"es"`, `"en"`) |
| `readingTimeMinutes` | number | REQUIRED | calculated by Cloud Function on write |
| `location` | GeoPoint | OPTIONAL | |
| `embedding` | VectorValue (768 floats) | yes | Populated by `embedArticleOnWrite` Cloud Function within ~30s after publish. Absent on docs that have never reached `status='published'`. |
| `embeddingSourceHash` | string | yes | sha256 hex of `title  description  content` (Start-of-Header separator, full text, pre-truncation). Used by the trigger for idempotency: skips re-embedding when source text is unchanged. |
| `embeddingProvider` | string | yes | Identifier for the embedding model in use, e.g. `'gemini-text-embedding-004'`. Useful when migrating between providers. |
| `embeddingDimensions` | number | yes | Vector length, e.g. `768`. Must match the active provider AND the deployed vector index. |
| `status` | string | REQUIRED | enum: `"published"` \| `"archived"` |
| `createdAt` | Timestamp | REQUIRED | server-side |
| `updatedAt` | Timestamp | REQUIRED | server-side, updated on every write |
| `viewCount` | number | REQUIRED | denormalized, default 0 |
| `favoriteCount` | number | REQUIRED | denormalized, default 0 |
| `isDeleted` | bool | REQUIRED | default `false`; set to `true` on soft delete — document is never hard-deleted |
| `deletedAt` | Timestamp | OPTIONAL | set to `serverTimestamp()` when `isDeleted` transitions to `true`; `null` for live articles |
| `searchHitCount` | number | FUTURE (`ai-embeddings`) | default 0; incremented by semantic search Cloud Function |

**Field count**: 26 (note: `aiSummary` is excluded from main table — see [Future Fields](#future-fields))

#### Soft Delete

Articles are soft-deleted via the `isDeleted` flag rather than removed. This preserves the storage thumbnail (cheaper to keep than to garbage-collect), enables future "trash" recovery, and makes accidental deletions reversible. Hard deletes are blocked by Firestore rules (`allow delete: if false`). The client transitions an article to deleted by calling `update({isDeleted: true, deletedAt: serverTimestamp()})`. Feed and "my articles" queries filter `isDeleted == false`.

#### Vector Field Justification

The `embedding` field uses the native `Vector` type from `cloud_firestore ^5.4.0` (NOT `List<double>` or `array<number>`). This is required to use Firestore's `findNearest` API for semantic search and recommendations.

| Property | Value |
|----------|-------|
| Dimensions | 768 |
| Generator | Gemini `gemini-embedding-001` |
| Distance metric | Cosine similarity |
| SDK floor | `cloud_firestore ^5.4.0` |
| Cost | ~6 KB per document |

Downgrading the SDK below `^5.4.0` would break `embedding` serialization — this is a hard prerequisite.

---

### `articles/{articleId}/favorites/{userId}` ✅

Reverse-lookup of who favorited an article. Document ID is the `userId`.

| Field | Type | Status | Notes |
|-------|------|--------|-------|
| `userId` | string | ✅ | mirror of doc id |
| `articleId` | string | ✅ | mirror of parent doc id |
| `createdAt` | Timestamp | ✅ | server-side |

---

### `users/{userId}/favorites/{articleId}` ✅

Mirror collection for efficient "my favorites" queries. Document ID is the `articleId`.

| Field | Type | Status | Notes |
|-------|------|--------|-------|
| `articleId` | string | ✅ | mirror of doc id |
| `articleTitle` | string | 🔜 (`article-upload-v2`) | denormalize for list rendering without fan-out |
| `articleThumbnailURL` | string | 🔜 (`article-upload-v2`) | denormalize for list rendering without fan-out |

**Mirror rationale**: `articles/{id}/favorites/{userId}` enables a single subcollection scan for "who favorited this article". The mirror at `users/{uid}/favorites/{articleId}` enables a single subcollection scan for "my favorites". Title and thumbnail denormalization is reserved for a follow-up that adds them in the same batch as the toggle.

Cost: **2 writes per favorite toggle** (one to each path, single batched commit). Plus a third write incrementing `articles.favoriteCount`. Acceptable because favorites are low-frequency relative to reads.

---

### `users/{userId}/savedArticles/{articleId}` ✅

Per-user bookmarks of NewsAPI articles. Document ID is `sha1(article.url)` so the same URL writes to the same doc — saving twice is idempotent. The full article snapshot is stored because NewsAPI URLs are not guaranteed to remain reachable beyond ~30 days; the saved copy is durable.

| Field | Type | Marker | Notes |
|-------|------|--------|-------|
| `source` | string | REQUIRED | `'newsapi'` for now; future-proof for `'community'` saves |
| `url` | string | REQUIRED | original NewsAPI url |
| `title` | string | REQUIRED | denormalized for list display |
| `description` | string | OPTIONAL | empty string when NewsAPI omits it |
| `urlToImage` | string | OPTIONAL | empty string when NewsAPI omits it |
| `publishedAt` | string | OPTIONAL | ISO 8601, NewsAPI format |
| `author` | string | OPTIONAL | empty string when unknown |
| `content` | string | OPTIONAL | NewsAPI's truncated content snippet |
| `savedAt` | Timestamp | REQUIRED | server-side |

**Anonymous users have a uid** — they can save under their anon UID, and `linkWithCredential` preserves the UID on signup so saves carry over to the real account. The save **action** is gated to `AuthAuthenticated` only (anonymous users are bounced through `/login`); existing saves under an anon UID remain accessible after the user upgrades the account.

**Migration**: a one-shot `SavedArticlesMigration` lifts any pre-existing local saves from the legacy Floor SQLite store into this subcollection at app boot. Idempotent via a `SharedPreferences` flag.

---

### `articles/{articleId}/views/{viewId}` 🔜 (`analytics-dashboard`)

Per-read event document, NOT yet created in production. Reserved for the analytics aggregator.

| Field | Type | Status | Notes |
|-------|------|--------|-------|
| `userId` | string | 🔜 | optional — absent for anonymous reads |
| `viewedAt` | Timestamp | 🔜 | server-side |
| `readDurationSeconds` | number | 🔜 | client-reported |
| `completed` | bool | 🔜 | `true` if user scrolled to end of article |

**Aggregator**: a Cloud Function in `analytics-dashboard` will read this subcollection and write the aggregate into `articles/{articleId}.viewCount`. Until then `viewCount` stays at its create-time default of 0 — favorites are the only engagement counter actually changing.

---

### `recommendations/{userId}` 🔜 (`recommendations-cache`)

One document per user. **Not deployed in v1** — the `recommendForUser` Cloud Function is **stateless**: it computes the user interest vector, fetches NewsAPI candidates, and ranks them in-memory per request. Each tap of "For You" reruns the whole pipeline. This collection is reserved for the optimization pass that caches the result with a TTL.

| Field | Type | Status | Notes |
|-------|------|--------|-------|
| `articleIds` | array\<reference\> | 🔜 | ranked list, max 20 refs → `articles/{articleId}` |
| `generatedAt` | Timestamp | 🔜 | server-side |
| `userEmbedding` | Vector | 🔜 | 768 dims, averaged from saved-article titles |
| `expiresAt` | Timestamp | 🔜 | Firestore TTL policy field (24h); NOT deleted client-side |

**Trade-off**: stateless costs ~3 seconds per request and 2 batch-embed calls. Cached would drop latency to ~100ms but requires an invalidation strategy (TTL or trigger on `users/{uid}/savedArticles` write). Acceptable for current scale.

---

### `usernames/{usernameLowercase}` ⚠️ (`username-uniqueness`)

Rules block writes that don't match the auth uid (`request.auth.uid == request.resource.data.uid`), but the **transaction-based uniqueness check is not yet wired into the signup flow**. Race condition: two simultaneous signups with the same username can both succeed because neither reads-then-writes inside a transaction. Mitigation: the second writer's `create` is rejected by rules due to existing doc — but the first writer's user-doc creation may have already succeeded under a different username.

| Field | Type | Status | Notes |
|-------|------|--------|-------|
| `uid` | string | 🔜 | back-ref → `users/{userId}` |
| `reservedAt` | Timestamp | 🔜 | server-side |

The document is **create-only** by rule. Display-form username will live in `users/{userId}.username`.

---

### Excluded from Firestore

#### `analytics_events` — NOT in Firestore

Raw analytics events **MUST NOT** be stored in Firestore.

- **Route to**: Firebase Analytics (BigQuery export configurable later).
- **Rationale**: Unbounded write volume at scale makes Firestore cost-prohibitive for raw event capture. Firebase Analytics is purpose-built for funnel and retention analysis and provides BigQuery export out of the box.

#### `users/{userId}/drafts/*` — NOT in Firestore

Article drafts live in local **Floor SQLite** only (offline-first). They are never written to Firestore during drafting. Only on `publish` does a document land in `articles/`.

- **Rationale**: Paid writes for transient, device-local state is wasteful. Offline-first is preserved by keeping drafts in local storage.

---

## Storage Layout

Firestore stores only the URL (or path reference) — the binary lives in Cloud Storage. This is **non-negotiable** per locked architecture rules.

| Path | Purpose | Notes |
|------|---------|-------|
| `media/articles/{articleId}/thumbnail.jpg` | Original cropped 16:9 thumbnail | uploaded by client |
| `media/articles/{articleId}/thumbnail_thumb.jpg` | 200×112 generated variant | created by Cloud Function on upload (scoped to `article-upload`) |
| `media/users/{userId}/avatar.jpg` | User profile picture | client-uploaded |

`articles/{articleId}.urlToImage` and `users/{userId}.photoURL` reference these Storage paths (or external URLs). The binary is never stored in Firestore.

---

## Indexes

Composite indexes will be declared in `backend/firestore.indexes.json` by the changes that depend on them. This doc lists them so downstream changes know what to declare.

| Index | Type | Fields | Used by |
|-------|------|--------|---------|
| feed-by-recency | composite | `status` ASC, `publishedAt` DESC | home feed |
| my-articles | composite | `userId` ASC, `createdAt` DESC | "My Articles" screen |
| category-feed | composite | `category` ASC, `status` ASC, `publishedAt` DESC | category filter chips |
| my-favorites | implicit | subcollection ordered by `favoritedAt` DESC | `users/{uid}/favorites` listing |
| my-saved-articles | implicit | subcollection ordered by `savedAt` DESC | `users/{uid}/savedArticles` listing |
| article-views | implicit | subcollection ordered by `viewedAt` DESC | analytics aggregator (`analytics-dashboard`) |
| vector-similarity | vector | `embedding`, cosine, 768 dims | `semanticSearch` + `recommendForUser` (added in `ai-embeddings`) |

**Deferral note**: `firestore.indexes.json` declarations are owned by the consuming changes (`article-upload`, `analytics-dashboard`, `ai-embeddings`), not by this change.

---

## Validation Sketch

This change documents the validation contract — it does **NOT** write `.rules` files. Full Firestore and Storage rules implementation is **explicitly deferred** to the `auth` and `article-upload` changes.

No `match` / `allow` Firestore rules syntax appears in this document.

| Rule | Field / Path | Implemented in |
|------|-------------|----------------|
| `title` must be 5..200 chars | `articles.title` | Firestore rules — `article-upload` |
| `description` must be 20..500 chars | `articles.description` | Firestore rules — `article-upload` |
| `content` must be ≥50 chars | `articles.content` | Firestore rules — `article-upload` |
| `urlToImage` must not be empty | `articles.urlToImage` | Firestore rules — `article-upload` |
| `userId == request.auth.uid` on write | `articles.userId` | Firestore rules — `article-upload` |
| `source == "journalist"` for client writes | `articles.source` | Firestore rules — `article-upload` |
| `users/{uid}` writable only by owner | `users/{userId}` | Firestore rules — `auth` |
| `usernames/{username}` create-only; `userId == request.auth.uid` | `usernames/{usernameLowercase}` | Firestore rules — `auth` |
| `media/articles/{articleId}/*` writable only by article owner | Storage path | Storage rules — `article-upload` |
| `media/users/{userId}/avatar.jpg` writable only by owner | Storage path | Storage rules — `auth` |

---

## Locked Decisions Citation Map

Every locked decision in `project/architecture-decisions` maps to a concrete schema element.

| Locked decision | Schema implementation |
|-----------------|----------------------|
| **us-central1 / nam5 region** | Doc header banner; vector index uses cosine 768 dim only because `nam5` supports Vector Search — region cannot change post-creation |
| **Anonymous auth enabled** | `users.isAnonymous` field; `users.providerId == "anonymous"` enum value; `views.userId` OPTIONAL (anonymous reads produce view records without a `userId`) |
| **Streak timezone = user's local IANA id** | `users.timezone` stores IANA id (e.g. `"America/Mexico_City"`); `users.lastPublishDate` is `YYYY-MM-DD` in local timezone, NOT UTC |
| **Optimistic UI updates** | `articles.viewCount` and `articles.favoriteCount` are denormalized — the client increments them locally for instant feedback before Firestore confirms. A Cloud Function reconciles from `views/` and `favorites/` subcollections to correct drift. Counters are NOT client-trusted at read. |

---

## Open Questions

All three questions are resolved for implementation.

1. **Denormalize `articles.userDisplayName` (display name) or resolve via `userId`?**
   **Chosen: denormalize.** Reads dominate writes; `displayName` changes are rare; saves a `users/` fan-out per article in the feed. Trade-off: when a user changes their `displayName`, a Cloud Function must back-fill `articles` where `userId == uid`. Acceptable cost.

2. **Lowercase-normalize `users.username`?**
   **Chosen: yes.** The doc id of `usernames/{usernameLowercase}` is the lowercase form; the display form is stored in `users.username`. Case-insensitive uniqueness is enforced by the existence rule on `usernames/{lowercase}` (create-only, no update).

3. **TTL on `recommendations`**
   **Chosen: 24h.** Recommendations recompute when the user reads new articles; fresh data wins. Configured via Firestore TTL policy on the `expiresAt` field — not client-side deletion.

---

## Future Fields

These fields are **documented to reserve names** — they are NOT created by this change. Each cites the SDD change that will introduce it.

### `users`

| Field | Type | Owning change |
|-------|------|---------------|
| `pushTokens` | array\<string\> | `notifications` (FCM tokens) |
| `featureFlags` | map | `remote-config` (Remote Config overrides) |
| `pinnedArticleIds` | array\<reference\> | `profile-v2` |

### `articles`

| Field | Type | Owning change |
|-------|------|---------------|
| `searchHitCount` | number | `ai-embeddings` |
| `aiSummary` | string | `ai-summarization` (future Gemini summary) |
| `editHistory` | subcollection | `article-edit` (revision history) |

### `recommendations`

| Field | Type | Owning change |
|-------|------|---------------|
| `userEmbedding` | Vector (768 dims) | `ai-embeddings` (averaged from read history) |
| `feedbackSignals` | map | `ai-embeddings` (like/dislike per article) |

---

## Embedding lifecycle

Articles gain four embedding-related fields when `embedArticleOnWrite`
fires (or when an admin runs `backfillEmbeddings`):

- `embedding` — 768-dim vector produced by the active provider with
  `taskType: RETRIEVAL_DOCUMENT` (currently Gemini `gemini-embedding-001`).
  Search queries are embedded with `taskType: RETRIEVAL_QUERY` for asymmetric
  retrieval; without the explicit task types both vectors collapse into a
  narrow cone and similarity loses discriminative power.
- `embeddingSourceHash` — sha256 hex of `modelName \x01 composedText`
  where `composedText = title \x01 description \x01 content` (full text,
  pre-truncation). Keying the hash on the model name means **changing
  providers auto-invalidates every existing hash** — the next write to
  each article re-embeds it under the new provider, no manual backfill.
- `embeddingProvider` — identifier of the active model, e.g.
  `'gemini-embedding-001'`. Used in logs and as the hash salt above.
- `embeddingDimensions` — vector length. MUST match both the active
  provider and the deployed Firestore vector index.

The trigger is idempotent and only embeds articles where
`status == 'published'` and `isDeleted == false`. Soft-deleted articles
keep their embedding data on disk but are excluded from search results
by the `searchArticles` callable.

### Provider abstraction

Embeddings are produced via a TypeScript `EmbeddingProvider` interface in
`backend/functions/src/ai/embedding_provider.ts`. The active provider is
selected by a single factory function (`backend/functions/src/ai/factory.ts`).
Switching providers (Gemini → OpenAI / Voyage / Anthropic) is a one-file
change to the factory, plus a re-deploy and a backfill if the new
provider's vector dimension differs from the old one. Business logic
inside the trigger, the search callable, and the backfill callable
depends only on the interface — never on the provider's SDK directly.
This convention is documented in engram observation #408 and applies
to any future AI/ML integration.

### Vector index

A Firestore vector index is declared in `backend/firestore.indexes.json`:

```json
{
  "vectorIndexes": [
    {
      "collectionGroup": "articles",
      "queryScope": "COLLECTION",
      "fieldPath": "embedding",
      "vectorConfig": { "dimension": 768, "flat": {} }
    }
  ]
}
```

The index is required by `findNearest` queries used in the
`searchArticles` callable. Index build can take several minutes after
deploy on a populated collection.
