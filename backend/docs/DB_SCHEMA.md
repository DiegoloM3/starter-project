# Firestore Database Schema

## Articles

Articles created in the application are stored in the following collection:

```text
articles/{articleId}
```

The Firestore document ID is used as the article identifier.

### Article document

| Field          | Type      | Required | Description                                                     |
| -------------- | --------- | -------: | --------------------------------------------------------------- |
| `author`       | string    |      Yes | Author name. Maximum 100 characters.                            |
| `title`        | string    |      Yes | Article title. Maximum 200 characters.                          |
| `description`  | string    |      Yes | Short article summary. Maximum 500 characters.                  |
| `content`      | string    |      Yes | Full article body. Maximum 50,000 characters.                   |
| `thumbnailURL` | string    |      Yes | Download URL of the thumbnail stored in Firebase Cloud Storage. |
| `publishedAt`  | timestamp |      Yes | Date and time when the article was published.                   |
| `createdAt`    | timestamp |      Yes | Date and time when the document was created.                    |
| `updatedAt`    | timestamp |      Yes | Date and time of the latest update.                             |

Article documents must contain only these fields. Required strings must not be empty.

### Example

```javascript
{
  author: "Jane Doe",
  title: "How Technology Is Changing Fitness",
  description: "An overview of technology's impact on personal training.",
  content: "The complete article content goes here...",
  thumbnailURL: "https://firebasestorage.googleapis.com/...",
  publishedAt: Timestamp,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

## Cloud Storage

Article thumbnails are stored at:

```text
media/articles/{articleId}/{fileName}
```

The `{articleId}` folder must match the corresponding Firestore document ID.

Allowed image types:

* JPEG
* PNG
* WebP

The maximum file size is 5 MB. Firestore stores only the download URL; the image file remains in Cloud Storage.

## Queries

Articles are listed from newest to oldest:

```text
articles orderBy publishedAt descending
```

This query uses Firestore's automatic single-field index, so no composite index is currently required.

## NewsAPI Mapping

| NewsAPI              | Firestore               |
| -------------------- | ----------------------- |
| `author`             | `author`                |
| `title`              | `title`                 |
| `description`        | `description`           |
| `content`            | `content`               |
| `urlToImage`         | `thumbnailURL`          |
| `publishedAt` string | `publishedAt` timestamp |

The NewsAPI `url` field is not required because these articles are created and stored directly in the application.

## Access

The current assignment does not include Firebase Authentication. Development rules may allow public reads and validated article creation. A production implementation should require authentication and restrict writes to authorized users.
