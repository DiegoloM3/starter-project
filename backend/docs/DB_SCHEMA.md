# Database Schema

This document outlines the schema for the "Articles" collection in Firebase Firestore and the "media/articles" folder structure in Firebase Cloud Storage.

## Firestore Collection: `articles`

Each document in the `articles` collection represents a news article created by a journalist.

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Unique identifier for the article. |
| `author` | `string` | Name of the journalist who wrote the article. |
| `title` | `string` | Title of the news article. |
| `description` | `string` | A brief summary of the news article. |
| `url` | `string` | URL of the article (if applicable). |
| `thumbnailURL` | `string` | A reference URL to an image in Firebase Cloud Storage (folder `media/articles`). |
| `publishedAt` | `timestamp` | The date and time when the article was published. |
| `content` | `string` | The full content/body of the article. |
| `category` | `string` | (Optional) The category representing the article (e.g. Technology, Business, Politics, etc.). |
| `isPremium` | `boolean` | (Optional) Whether the article is only available for premium subscribers. |

---

## Firestore Collection: `authors` (Overdelivery)

To allow for more robust journalist profiles.

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Unique identifier for the author. |
| `name` | `string` | Full name of the author. |
| `bio` | `string` | A short biography of the journalist. |
| `profileImageURL` | `string` | Reference URL to the profile picture in Cloud Storage. |

---

## Storage Structure: Firebase Cloud Storage

All media files related to articles will be stored in the following folder structure:

`media/articles/{article_id}/{filename}`

- **`thumbnailURL`**: Stores the download URL of the uploaded image for the article.
