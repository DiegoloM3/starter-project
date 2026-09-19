# Article schema

The `articles` collection stores published newsroom stories. Documents use an auto-generated Firestore id.

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `authorId` | string | yes | Firebase Auth uid of the journalist who created the story. |
| `authorName` | string | yes | Display name shown in the byline. |
| `title` | string | yes | Headline, limited to 140 characters. |
| `description` | string | yes | Standfirst, limited to 320 characters. |
| `content` | string | yes | Article body. |
| `thumbnailURL` | string | yes | Download URL for the image stored under `media/articles/{articleId}`. |
| `createdAt` | timestamp | yes | Server timestamp when the draft was published. |
| `updatedAt` | timestamp | yes | Server timestamp of the last edit. |
| `publishedAt` | timestamp | yes | Server timestamp used for feed ordering. |
| `status` | string | yes | Currently `published`; reserved for `draft` and `archived`. |

## Storage

Article thumbnails are stored at:

```text
media/articles/{articleId}/{originalFileName}
```

The Firestore document stores the resulting download URL, never a device-local path.

## Query shape

The public feed reads `articles` where `status == "published"`, ordered by `publishedAt` descending. A composite index may be required for this query in production.
