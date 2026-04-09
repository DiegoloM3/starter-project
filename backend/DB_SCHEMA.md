# Articles Collection

**Collection path:** `/articles/{articleId}`

| Field Name    | Data Type | Description                                                                                     |
| ------------- | --------- | ----------------------------------------------------------------------------------------------- |
| `id`          | String    | Firestore Auto-generated ID.                                                                    |
| `author`      | String    | Author name.                                                                                    |
| `title`       | String    | Title of the article.                                                                           |
| `description` | String    | Short description about the article.                                                            |
| `content`     | String    | Full body of the article (supports long text).                                                  |
| `url`         | String    | Firebase URL to download the images from the article from Firebase Storage (`media/articles/`). |
| `publishedAt` | Timestamp | Date of the article that helps to order the articles.                                           |

## Cloud Storage Structure

- **Root:** `media/`
- **Subfolder:** `articles/`

# Users Collection

**Collection path:** `/users/{userId}`

| Field Name          | Data Type | Description                                                                                     |
| ------------------- | --------- | ----------------------------------------------------------------------------------------------- |
| `id`                | String    | Firestore Auto-generated ID. It must be the same that Firebase auth.                            |
| `email`             | String    | Author email.                                                                                   |
| `profilePictureUrl` | String?   | User profile picture (NOT DEVELOPED)                                                            |
