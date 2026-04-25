# Database Schema

This document defines the Firestore database schema for the Symmetry News App.

---

## Collections

### `users`

Stores registered user profiles. Created upon successful account registration.

| Field         | Type        | Required | Description                                             |
| ------------- | ----------- | -------- | ------------------------------------------------------- |
| `displayName` | `string`    | Yes      | The display name chosen by the user. Must be non-empty. |
| `email`       | `string`    | Yes      | The email address of the user. Must be non-empty.       |
| `createdAt`   | `timestamp` | Yes      | Server timestamp marking when the account was created.  |

> **Note:** The document ID matches the Firebase Auth UID. This ensures a 1:1 mapping
> between authentication and user profile data.

#### Example Document

```json
// Document ID: "aBcDeFgHiJkLmN"
{
  "displayName": "Jane Doe",
  "email": "jane@example.com",
  "createdAt": "January 15, 2024 at 10:30:00 AM UTC"
}
```

---

### `articles`

Stores user-created articles uploaded through the app.

| Field          | Type        | Required | Description                                                                           |
| -------------- | ----------- | -------- | ------------------------------------------------------------------------------------- |
| `title`        | `string`    | Yes      | The headline of the article. Must be non-empty.                                       |
| `description`  | `string`    | Yes      | A short summary of the article. Must be non-empty.                                    |
| `content`      | `string`    | Yes      | The full body text of the article. Must be non-empty.                                 |
| `author`       | `string`    | Yes      | The display name of the journalist. Must be non-empty.                                |
| `authorId`     | `string`    | Yes      | The Firebase Auth UID of the user who created the article.                            |
| `thumbnailURL` | `string`    | Yes      | A download URL referencing an image in Firebase Cloud Storage (`media/articles/`).    |
| `publishedAt`  | `string`    | Yes      | ISO 8601 date string representing the publication date (e.g. `2024-01-15T10:30:00Z`). |
| `createdAt`    | `timestamp` | Yes      | Server timestamp marking when the document was created. Used for ordering.            |

#### Example Document

```json
{
  "title": "Breaking: New Discoveries in AI Research",
  "description": "Scientists have unveiled a groundbreaking approach to neural networks.",
  "content": "In a landmark paper published today, researchers from MIT demonstrated...",
  "author": "Jane Doe",
  "authorId": "aBcDeFgHiJkLmN",
  "thumbnailURL": "https://firebasestorage.googleapis.com/v0/b/{project}/o/media%2Farticles%2Fexample.jpg?alt=media",
  "publishedAt": "2024-01-15T10:30:00Z",
  "createdAt": "January 15, 2024 at 10:30:00 AM UTC"
}
```

---

## Authentication Strategy

The app supports three authentication flows:

| Flow         | Method                  | Permissions                                        |
| ------------ | ----------------------- | -------------------------------------------------- |
| **Register** | Email + Password        | Read all articles, create/edit/delete own articles |
| **Sign In**  | Email + Password        | Read all articles, create/edit/delete own articles |
| **Guest**    | Firebase Anonymous Auth | Read all articles only                             |

> **Why Anonymous Auth for guests?** Firebase Anonymous Auth provides a temporary UID
> without requiring credentials. This allows guests to have a consistent session while
> restricting write operations through security rules. If a guest later registers,
> Firebase supports linking the anonymous account to a permanent one.

---

## Design Decisions

1. **Flat structure over subcollections**: Articles are independent documents with no
   relational nesting. A single flat collection is the most efficient choice for reads
   and queries.

2. **`thumbnailURL` as a download URL**: Rather than storing only the Cloud Storage path
   (e.g. `media/articles/example.jpg`), we store the full download URL. This avoids an
   extra asynchronous call to `getDownloadURL()` every time we render the article,
   improving read performance and simplifying the presentation layer.

3. **`publishedAt` as ISO 8601 string**: This mirrors the format used by the existing
   News API (`ArticleEntity.publishedAt` is a `String`), ensuring compatibility between
   remote API articles and Firebase articles when displayed together in the UI.

4. **`createdAt` as Firestore Timestamp**: Used exclusively for server-side ordering
   (`orderBy('createdAt', descending: true)`). Unlike `publishedAt` (which the user
   controls), `createdAt` is set by the server and cannot be spoofed by the client.

5. **`authorId` for ownership**: Links each article to its creator via Firebase Auth UID.
   This enables security rules to enforce that only the author can edit or delete their
   own articles, while anyone can read them.

6. **No `url` field**: The original News API articles have a `url` field linking to an
   external webpage. Firebase articles are created within the app and have no external
   webpage, so this field is omitted. The shared entity handles this as a nullable field.

7. **No `source` object**: The News API provides a `source` with `id` and `name`. For
   Firebase articles, the source is implicitly "Symmetry App" and does not need to be
   stored per document.

8. **User document ID = Auth UID**: Using the Auth UID as the Firestore document ID for
   users eliminates the need for queries to find a user profile — it is a direct
   document lookup by path, which is the fastest read operation in Firestore.

---

## Cloud Storage Structure

```
media/
  articles/
    {documentId}_{timestamp}.{extension}
```

Thumbnail images are stored in `media/articles/` with a filename composed of the
Firestore document ID and a timestamp to ensure uniqueness and prevent overwrites.

---

## Queries

| Collection | Query                        | Index Required    | Description                                |
| ---------- | ---------------------------- | ----------------- | ------------------------------------------ |
| `articles` | `orderBy('createdAt', desc)` | No (single field) | Fetch all articles sorted by newest first. |
| `articles` | `where('authorId', ==)`      | No (single field) | Fetch articles by a specific author.       |
| `users`    | Direct document get by UID   | No                | Fetch user profile by Auth UID.            |
