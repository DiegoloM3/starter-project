# Database Schema

## Overview

The app uses two data sources for articles:

- **NewsAPI** (external REST API) — read-only, no Firestore schema needed.
- **Community Articles** (journalist-authored) — stored in Firebase Firestore with images in Firebase Cloud Storage.

---

## Firestore Collection: `community_articles`

Each document represents a journalist-authored article.

### Document ID

Auto-generated Firestore document ID (string).

### Fields

| Field         | Type        | Required | Description                                                                                                |
| ------------- | ----------- | -------- | ---------------------------------------------------------------------------------------------------------- |
| `authorId`    | `string`    | ✅       | Firebase Auth UID of the journalist who created the article.                                               |
| `authorName`  | `string`    | ✅       | Display name of the author at time of publishing.                                                          |
| `title`       | `string`    | ✅       | Article headline.                                                                                          |
| `content`     | `string`    | ✅       | Full article body text.                                                                                    |
| `description` | `string`    | ❌       | Short summary / subtitle shown in article list cards.                                                      |
| `imageUrl`    | `string`    | ❌       | Public download URL pointing to the thumbnail stored in Firebase Cloud Storage (see Storage Schema below). |
| `category`    | `string`    | ❌       | Article category (e.g. `"Politics"`, `"Technology"`, `"Sports"`).                                          |
| `publishedAt` | `timestamp` | ✅       | Server timestamp set at document creation time.                                                            |
| `updatedAt`   | `timestamp` | ❌       | Server timestamp updated on every edit (`FieldValue.serverTimestamp()`).                                   |

### Example Document

```json
{
  "authorId": "uid_abc123",
  "authorName": "John Doe",
  "title": "Flutter 5 Released: What's New",
  "content": "The Flutter team announced today...",
  "description": "A deep dive into the new features in Flutter 5.",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/news-app-symmetry-aa047.firebasestorage.app/o/community_article_images%2Fuid_abc123%2F1748534400000_cover.jpg?alt=media&token=...",
  "category": "Technology",
  "publishedAt": "2026-05-29T10:00:00Z",
  "updatedAt": null
}
```

---

## Firebase Cloud Storage: `community_article_images/`

Article thumbnails are stored at:

```
community_article_images/{userId}/{timestamp}_{originalFilename}
```

| Segment            | Description                                                             |
| ------------------ | ----------------------------------------------------------------------- |
| `userId`           | Firebase Auth UID of the uploading journalist.                          |
| `timestamp`        | `DateTime.now().millisecondsSinceEpoch` — prevents filename collisions. |
| `originalFilename` | The original filename of the uploaded image.                            |

**Example path:**

```
community_article_images/uid_abc123/1748534400000_cover.jpg
```

The full public download URL is retrieved after upload via `ref.getDownloadURL()` and stored in the `imageUrl` field of the Firestore document.

---

## Firestore Security Rules Summary

| Operation       | Condition                                                     |
| --------------- | ------------------------------------------------------------- |
| `read`          | Anyone (public, no auth required)                             |
| `create`        | Authenticated user whose `authorId == request.auth.uid`       |
| `update/delete` | Authenticated user whose `authorId == resource.data.authorId` |

See [`firestore.rules`](../firestore.rules) for the full implementation.

---

## Storage Security Rules Summary

| Operation      | Condition                                            |
| -------------- | ---------------------------------------------------- |
| `read`         | Anyone (public)                                      |
| `write/delete` | Authenticated user whose `uid == userId` in the path |

See [`storage.rules`](../storage.rules) for the full implementation.

---

## Firestore Indexes

Composite indexes defined in [`firestore.indexes.json`](../firestore.indexes.json):

| Collection           | Fields                              | Use Case                                   |
| -------------------- | ----------------------------------- | ------------------------------------------ |
| `community_articles` | `authorId ASC` + `publishedAt DESC` | Fetch all articles by a user, newest first |
| `community_articles` | `category ASC` + `publishedAt DESC` | Filter by category, newest first           |

---
