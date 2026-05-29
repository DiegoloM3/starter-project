# Firestore Database Schema

## Collections Overview

```
firestore/
├── articles/{articleId}                          # Top-level collection
│   └── comments/{commentId}                      # Subcollection per article
└── users/{uid}/
    └── savedArticles/{articleId}                  # Subcollection per user
```

---

## `articles/{articleId}`

Top-level collection storing all articles (drafts, published, archived).

| Field | Type | Required | Immutable | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | `string` | Yes | Yes | Must equal document ID |
| `title` | `string` | Yes | No | 1–200 characters |
| `description` | `string` | Yes | No | 1–500 characters |
| `content` | `string` | Yes | No | 1–50,000 characters |
| `authorId` | `string` | Yes | Yes | Must equal `request.auth.uid` on create |
| `authorName` | `string` | Yes | No | Display name of the author |
| `thumbnailUrl` | `string` | Yes | No | Download URL or empty string `""` |
| `thumbnailPath` | `string` | Yes | No | Storage path or empty string `""` |
| `publishedAt` | `timestamp \| null` | Yes | No | `null` for drafts. On the `draft → published` transition it must equal the server timestamp (`request.time`); immutable on every later write |
| `createdAt` | `timestamp` | Yes | Yes | Must equal server timestamp on create |
| `updatedAt` | `timestamp` | Yes | No | Must equal server timestamp on every write |
| `status` | `string` | Yes | No | One of: `draft`, `published`, `archived` |
| `isDeleted` | `bool` | Yes | No | Must be `false` on create. Soft-delete only, and **terminal**: once `true` the document becomes immutable (no further edits, no un-delete) |
| `readingTimeMinutes` | `int` | Yes | No | Minimum value: 1 |

### Status Transitions

```
draft ──→ published ──→ archived
  │           │             │
  └───────────┴─────────────┘  (same → same is always allowed)
```

Only these transitions are valid:
- `draft` → `draft` (edit without publishing)
- `draft` → `published`
- `published` → `published` (edit published article)
- `published` → `archived`
- `archived` → `archived` (no-op)

All other transitions (e.g., `draft` → `archived`, `archived` → `published`) are **denied**.

### Write Rules Summary

- **Create:** Auth required. `authorId` must match authenticated user. Status must be `draft`. `isDeleted` must be `false`. `publishedAt` must be `null`. Timestamps must be server-generated.
- **Update:** Auth + ownership required. Immutable fields cannot change. Status transitions enforced. `updatedAt` must be server timestamp. On `draft → published`, `publishedAt` is set to the server time and is immutable thereafter. A soft-deleted document (`isDeleted == true`) is terminal and rejects all further writes.
- **Delete:** Hard deletes are **always denied**. Use `isDeleted: true` for soft-delete.

---

## `articles/{articleId}/comments/{commentId}`

Subcollection for comments on an article. **Append-only** — comment content cannot be edited after creation.

| Field | Type | Required | Immutable | Constraints |
|-------|------|----------|-----------|-------------|
| `id` | `string` | Yes | Yes | Must equal document ID |
| `articleId` | `string` | Yes | Yes | Must equal parent article's document ID |
| `authorId` | `string` | Yes | Yes | Must equal `request.auth.uid` on create |
| `authorName` | `string` | Yes | Yes | Display name of the commenter |
| `content` | `string` | Yes | Yes | 1–2,000 characters |
| `createdAt` | `timestamp` | Yes | Yes | Must equal server timestamp on create |
| `isDeleted` | `bool` | Yes | No | Must be `false` on create |

### Write Rules Summary

- **Create:** Auth required. `authorId` must match authenticated user. `articleId` must match parent path. `isDeleted` must be `false`. `createdAt` must be server timestamp.
- **Update:** Only the comment author can update. The **only** permitted change is `isDeleted: false → true` (soft-delete). All other fields must remain identical.
- **Delete:** Hard deletes are **always denied**.

---

## `users/{uid}/savedArticles/{articleId}`

Subcollection for bookmarked/saved articles per user. Each document represents one saved article.

> **Implementation note.** The shipped app persists "saved" articles **locally on-device** via Floor/SQLite (`LocalArticleBloc` → `AppDatabase.articleDAO`), so bookmarking works offline with no network round-trip. This Firestore subcollection is **designed and rule-protected but not yet wired** — it is a forward-looking schema for cross-device bookmark sync (a `FirestoreSavedArticleDataSource` would write/read it). It is documented here so the rules and indexes are ready the moment that sync is implemented.

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `articleId` | `string` | Yes | Reference to the saved article's ID |
| `savedAt` | `timestamp` | Yes | Must equal server timestamp on create |

### Write Rules Summary

- **Create:** Auth required. User can only write to their own subcollection (`uid` must match `request.auth.uid`).
- **Read:** Auth required. User can only read their own subcollection.
- **Delete:** Auth + ownership. User can remove (unsave) their own saved articles.
- **Update:** Always denied — saved articles are immutable.

---

## Composite Indexes

These mirror `backend/firestore.indexes.json` exactly.

| Collection | Fields | Query Scope | Purpose |
|------------|--------|-------------|---------|
| `articles` | `isDeleted` ASC, `status` ASC, `publishedAt` DESC | Collection | Feed: published, non-deleted articles ordered by publish date |
| `articles` | `authorId` ASC, `isDeleted` ASC, `createdAt` DESC | Collection | A user's non-deleted articles ordered by creation date |
| `articles` | `authorId` ASC, `status` ASC, `isDeleted` ASC, `createdAt` DESC | Collection | A user's articles filtered by status, excluding soft-deleted |
| `comments` | `isDeleted` ASC, `createdAt` ASC | Collection | An article's non-deleted comments ordered oldest-first |

---

## Storage Paths

Thumbnails are stored in Firebase Cloud Storage at:

```
media/articles/{uid}/{articleId}/thumbnail
```

- **MIME types allowed:** `image/jpeg`, `image/png`, `image/webp`
- **Max size:** 5 MB
- **Auth + ownership:** Only the user matching `{uid}` can write/delete.
- **Read:** Any authenticated user can read (thumbnails are public to logged-in users).
