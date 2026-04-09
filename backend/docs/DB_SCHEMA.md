# Database Schema

## Firestore — `/articles/{articleId}`

Only Community articles are written to Firestore. NewsAPI articles are fetched from the API and are not persisted.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `uid` | string | Yes | Firebase Auth UID of the author. Used by security rules to enforce ownership. |
| `title` | string | Yes | Article headline. |
| `description` | string | Yes | Short summary shown on feed cards. |
| `content` | string | Yes | Full article body. |
| `imageUrl` | string | No | HTTPS download URL from Firebase Storage. `null` when published without image. |
| `publishedAt` | timestamp | Yes | Set via `FieldValue.serverTimestamp()` on create. Used for feed ordering. |

`imageUrl` stores the full download URL (not a Storage path) so the client can use it directly without an extra round-trip.

`publishedAt` uses a server timestamp to avoid issues with client clock skew.

## Firebase Storage

Path pattern: `articles/{uid}/{timestamp}_{filename}`

Example: `articles/abc123/1712600000000_photo.jpg`

## Security Rules

### Firestore (`firestore.rules`)

```js
match /articles/{articleId} {
  allow read: if true;
  allow create: if request.auth != null
                && request.resource.data.uid == request.auth.uid;
  allow update, delete: if request.auth != null
                         && resource.data.uid == request.auth.uid;
}
```

Reads are open — community articles are public. On `create`, the rule verifies the written `uid` matches the caller. On `update`/`delete`, it verifies the caller owns the existing document.

### Storage (`storage.rules`)

```js
match /articles/{allPaths=**} {
  allow read: if true;
  allow write: if request.auth != null;
}
```

Any authenticated user can upload under `articles/`. Path-level UID validation is tracked as a future improvement (IMP-003).

## Feed Query

```dart
_articlesRef.orderBy('publishedAt', descending: true).limit(50)
```

Uses a single-field descending index on `publishedAt`, which Firestore creates automatically. A composite index (`uid` + `publishedAt`) would be needed for a "my articles" filtered view — definition is ready to add to `firestore.indexes.json` when that feature is built.
