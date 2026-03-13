# Database Schema

## Overview
This document describes the Firestore database schema for the News App article publishing feature.

- **Database:** Firebase Firestore
- **Image Storage:** Cloudinary (external service)
- **Authentication:** Firebase Auth (Email/Password)

---

## Collections

### 1. `users` Collection
Stores user profile information.

**Path:** `users/{userId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique user identifier (Firebase Auth UID) |
| `email` | string | Yes | User's email address |
| `displayName` | string | Yes | User's display name |
| `photoUrl` | string | No | Profile picture URL (Cloudinary) |
| `createdAt` | timestamp | Yes | Account creation date |
| `updatedAt` | timestamp | Yes | Last profile update |

**Example Document:**
```json
{
  "id": "abc123xyz",
  "email": "journalist@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://res.cloudinary.com/your-cloud/image/upload/v1234/profiles/abc123xyz.jpg",
  "createdAt": "2026-03-10T10:00:00Z",
  "updatedAt": "2026-03-10T10:00:00Z"
}
```

---

### 2. `articles` Collection
Stores user-created articles.

**Path:** `articles/{articleId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique article identifier |
| `authorId` | string | Yes | Reference to user who created the article |
| `authorName` | string | Yes | Author's display name (denormalized) |
| `title` | string | Yes | Article title |
| `description` | string | Yes | Short summary/excerpt (max 300 chars) |
| `content` | string | Yes | Full article content |
| `thumbnailUrl` | string | No | Image URL (Cloudinary hosted) |
| `categories` | array\<string\> | Yes | List of category tags |
| `isDraft` | boolean | Yes | Draft status (true = draft, false = published) |
| `publishedAt` | timestamp | No | Publication date (null if draft) |
| `createdAt` | timestamp | Yes | Article creation date |
| `updatedAt` | timestamp | Yes | Last modification date |

**Example Document:**
```json
{
  "id": "article_001",
  "authorId": "abc123xyz",
  "authorName": "John Doe",
  "title": "Breaking News: Flutter is Amazing",
  "description": "A comprehensive look at why Flutter has become the go-to framework...",
  "content": "Full article content goes here with all the details...",
  "thumbnailUrl": "https://res.cloudinary.com/your-cloud/image/upload/v1234/articles/article_001.jpg",
  "categories": ["Technology", "Mobile Development"],
  "isDraft": false,
  "publishedAt": "2026-03-10T12:00:00Z",
  "createdAt": "2026-03-10T10:00:00Z",
  "updatedAt": "2026-03-10T12:00:00Z"
}
```

---

## External Services

### Cloudinary Configuration

**Purpose:** Store article thumbnails and user profile images.

**Base URL:** `https://res.cloudinary.com/{cloud_name}/image/upload/`

**Folder Structure:**
```
/{cloud_name}/
├── profiles/
│   └── {userId}.jpg          # User profile pictures
└── articles/
    └── {articleId}.jpg       # Article thumbnails
```

**Environment Variables Required:**
```
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

---

## Indexes

### Required Composite Indexes

These indexes are needed for efficient queries.

1. **Published articles by date (for home feed):**
   - Collection: `articles`
   - Fields: `isDraft` (ASC), `publishedAt` (DESC)

2. **User's articles by date (for "My Articles" page):**
   - Collection: `articles`
   - Fields: `authorId` (ASC), `createdAt` (DESC)

3. **Articles by category (for filtering):**
   - Collection: `articles`
   - Fields: `isDraft` (ASC), `categories` (ARRAY_CONTAINS), `publishedAt` (DESC)

---

## Relationships Diagram

```
┌─────────────────┐         ┌─────────────────────┐
│     users       │         │      articles       │
├─────────────────┤         ├─────────────────────┤
│ id (PK)         │────────▶│ authorId (FK)       │
│ email           │         │ id (PK)             │
│ displayName     │         │ authorName          │
│ photoUrl        │         │ title               │
│ createdAt       │         │ description         │
│ updatedAt       │         │ content             │
└─────────────────┘         │ thumbnailUrl        │
                            │ categories[]        │
                            │ isDraft             │
                            │ publishedAt         │
                            │ createdAt           │
                            │ updatedAt           │
                            └─────────────────────┘

Relationship: One user can have many articles (1:N)
```

---

## Security Considerations

1. **Cloudinary:** Use unsigned uploads with upload presets for client-side uploads
2. **Firestore:** Rules enforce that users can only modify their own data
3. **Authentication:** Firebase Auth handles secure user authentication
