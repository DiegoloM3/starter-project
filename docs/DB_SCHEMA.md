# Database Schema

This document describes the Firestore collections, documents, and Firebase Storage structure used in The Daily app.

## Firestore Collections

---

### `users/{userId}`

Stores user profile data and preferences. Created on first sign-in and updated throughout onboarding.

| Field | Type | Required | Description |
|---|---|---|---|
| `uid` | string | yes | Firebase Auth user ID |
| `email` | string | yes | User email address |
| `displayName` | string | yes | Full name shown on articles |
| `photoURL` | string | no | Reference to Firebase Storage: `media/avatars/{userId}` |
| `bio` | string | no | Short author bio, max 160 characters |
| `role` | string | yes | `"reader"` or `"writer"` |
| `preferredCategories` | string[] | yes | Selected during onboarding. Possible values: `technology`, `design`, `world`, `business`, `culture`, `science`, `health`, `politics`, `sports` |
| `onboardingCompleted` | boolean | yes | Controls whether the user is redirected to onboarding on next launch |
| `notificationsEnabled` | boolean | no | Reserved for future push notification support |
| `darkMode` | boolean | no | Reserved for future dark mode support |
| `createdAt` | timestamp | yes | Account creation date |
| `updatedAt` | timestamp | yes | Last profile update date |

---

### `users/{userId}/savedArticles/{articleId}`

Subcollection storing articles saved by the user. Article data is denormalized to avoid extra queries when rendering the saved articles list.

| Field | Type | Required | Description |
|---|---|---|---|
| `articleId` | string | yes | Reference to the original article in `articles/{articleId}` |
| `title` | string | yes | Denormalized from article for list rendering |
| `thumbnailURL` | string | no | Denormalized from article for list rendering |
| `authorName` | string | yes | Denormalized from article for list rendering |
| `category` | string | yes | Denormalized from article for list rendering |
| `readTime` | number | yes | Denormalized from article for list rendering |
| `savedAt` | timestamp | yes | Date the article was saved |

> **Note:** Denormalized fields may become stale if the original article is edited after being saved. This is a known and accepted trade-off for read performance in a NoSQL architecture.

---

### `articles/{articleId}`

Stores all articles created by writers, both published and drafts. Author data is denormalized to avoid extra queries when rendering article cards in the feed.

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Auto-generated Firestore document ID |
| `title` | string | yes | Article title |
| `excerpt` | string | yes | Auto-generated from first ~160 characters of body. Used in feed cards to avoid loading full body. |
| `body` | string | yes | Full article content |
| `category` | string | yes | One of: `technology`, `design`, `world`, `business`, `culture`, `science`, `health`, `politics`, `sports` |
| `thumbnailURL` | string | no | Reference to Firebase Storage: `media/articles/{articleId}` |
| `authorId` | string | yes | Firebase Auth UID of the author. Used for ownership queries and Firestore rules. |
| `authorName` | string | yes | Denormalized from `users/{authorId}.displayName` |
| `authorPhotoURL` | string | no | Denormalized from `users/{authorId}.photoURL` |
| `readTime` | number | yes | Estimated read time in minutes. Calculated as `body.wordCount / 200`. |
| `status` | string | yes | `"published"` or `"draft"` |
| `createdAt` | timestamp | yes | Article creation date |
| `updatedAt` | timestamp | yes | Last edit date |

---

## Firebase Storage Structure

```
media/
  articles/{articleId}    ← Article thumbnail images
  avatars/{userId}        ← User profile photos
```

Accepted formats: JPEG, PNG, WEBP. Max file size: 8MB.

---

## Design Decisions

**Denormalization of author data in articles**
In Firestore (NoSQL), joins are expensive. Storing `authorName` and `authorPhotoURL` directly in each article avoids N extra queries when rendering a feed of articles. The `authorId` field is still stored for ownership checks and security rules.

**Excerpt field precalculated on publish**
The `excerpt` field is generated at write time from the first ~160 characters of the body. This ensures the feed never loads full article bodies, keeping read costs low.

**Saved articles as subcollection**
Saved articles are stored as a subcollection under each user rather than as an array field. This scales better for pagination and makes it easier to query, sort, and delete individual saves.

**Role-based access**
The `role` field on each user document drives both UI visibility (FAB, My Posts tab) and Firestore security rules. Only users with `role == "writer"` can create or modify articles.
