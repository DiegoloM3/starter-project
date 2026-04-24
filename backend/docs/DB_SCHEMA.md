# DB Schema

## Collection: `articles`

| Field         | Type      | Required | Notes                              |
|---------------|-----------|----------|------------------------------------|
| id            | string    | auto     | Firestore document ID              |
| title         | string    | ✅       | max 120 chars                      |
| content       | string    | ✅       | full article body                  |
| thumbnailUrl  | string    | ✅       | path in Storage: media/articles/   |
| authorId      | string    | ✅       | Firebase Auth UID                  |
| authorName    | string    | ✅       | denormalized for read performance  |
| createdAt     | timestamp | ✅       | server timestamp                   |
| updatedAt     | timestamp | ✅       | server timestamp                   |
| readTime      | number    | ✅       | calculated: ceil(wordCount / 200)  |
| tags          | string[]  | ✅       | max 5 tags                         |
| isPublished   | boolean   | ✅       | draft vs published                 |
| views         | number    | ✅       | default 0                          |
| likes         | number    | ✅       | default 0                          |
