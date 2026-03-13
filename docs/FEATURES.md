# Features Documentation

## Overview

This application is an **Article Publishing Platform** built with Flutter following **Clean Architecture** principles. Users can create, edit, publish, and read articles with features like text-to-speech, category filtering, and cloud image storage.

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION                          │
│  (BLoCs, Cubits, Widgets, Pages)                       │
├─────────────────────────────────────────────────────────┤
│                      DOMAIN                             │
│  (Entities, Use Cases, Repository Interfaces)          │
├─────────────────────────────────────────────────────────┤
│                       DATA                              │
│  (Repository Implementations, Data Sources, Models)     │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│               EXTERNAL SERVICES                         │
│  (Firebase Auth, Firestore, Cloudinary)                │
└─────────────────────────────────────────────────────────┘
```

### Dependency Flow

Dependencies point **inward** only:
- Presentation → Domain
- Data → Domain
- Domain has no external dependencies

---

## Features

### 1. Authentication (`features/auth/`)

Firebase Authentication integration with email/password.

#### Domain Layer
- **Entities**: `UserEntity` (id, email, displayName, photoUrl)
- **Use Cases**:
  - `SignInUseCase` - Authenticate existing user
  - `SignUpUseCase` - Register new user
  - `SignOutUseCase` - End user session
  - `GetCurrentUserUseCase` - Get authenticated user
  - `GetAuthStateChangesUseCase` - Stream auth state

#### Data Layer
- **Models**: `UserModel` (extends UserEntity, adds JSON/Firebase serialization)
- **Data Source**: `AuthRemoteDataSourceImpl` (Firebase Auth SDK)
- **Repository**: `AuthRepositoryImpl`

#### Presentation Layer
- **AuthBloc**: Manages authentication state
  - Events: `CheckAuthStatus`, `SignInRequested`, `SignUpRequested`, `SignOutRequested`
  - States: `AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthError`
- **Error Mapping**: Converts Firebase exceptions to `AuthFailure` enum

---

### 2. User Articles (`features/user_articles/`)

Full CRUD operations for user-created articles with publishing workflow.

#### Domain Layer
- **Entities**: `UserArticleEntity`
  - Properties: id, authorId, authorName, title, description, content, thumbnailUrl, categories, isDraft, publishedAt, createdAt, updatedAt
- **Use Cases**:
  - `GetUserArticlesUseCase` - Fetch user's articles
  - `GetPublishedArticlesUseCase` - Fetch all published articles
  - `GetArticlesByCategoryUseCase` - Filter by category
  - `CreateArticleUseCase` - Create new article/draft
  - `UpdateArticleUseCase` - Edit existing article
  - `DeleteArticleUseCase` - Remove article
  - `PublishArticleUseCase` - Publish draft
  - `UploadImageUseCase` - Upload cover image

#### Data Layer
- **Models**: `UserArticleModel` (Firestore serialization)
- **Data Sources**:
  - `ArticleRemoteDataSourceImpl` - Firestore CRUD operations
  - `CloudinaryServiceImpl` - Image upload to Cloudinary CDN
- **Repository**: `UserArticleRepositoryImpl`

#### Presentation Layer

**UserArticlesBloc** - List management
- Events: `LoadUserArticles`, `LoadPublishedArticles`, `FilterArticles`, `DeleteArticle`, `PublishArticle`
- States: `UserArticlesInitial`, `UserArticlesLoading`, `UserArticlesLoaded`, `UserArticlesError`, `UserArticlesActionInProgress`

**ArticleEditorCubit** - Article creation/editing
- Methods: `initNewArticle()`, `initWithArticle()`, `updateTitle()`, `updateContent()`, `addCategory()`, `removeCategory()`, `uploadCoverImage()`, `saveDraft()`, `publishArticle()`
- States: ArticleEditorStatus (initial, editing, uploading, saving, publishing, success, error)

**TtsCubit** - Text-to-Speech reader
- Methods: `prepareText()`, `play()`, `pause()`, `stop()`, `togglePlayPause()`, `setPlaybackSpeed()`
- Features: Progress tracking, speed control (0.5x - 2.0x), estimated reading time

---

## External Services

### Firebase Configuration

| Service | Purpose |
|---------|---------|
| Firebase Auth | User authentication |
| Cloud Firestore | Article storage |
| Firebase Storage | (Available, not used - using Cloudinary) |

### Cloudinary Integration

- **Purpose**: Cover image hosting with CDN
- **Configuration**: Via environment variable `CLOUDINARY_CLOUD_NAME`
- **Unsigned Uploads**: Using preset for public uploads

---

## State Management

### BLoC Pattern

All features use the BLoC (Business Logic Component) pattern via `flutter_bloc`:

```dart
// Events trigger state changes
bloc.add(LoadUserArticles(userId: 'user123'));

// States represent UI state
state is UserArticlesLoading → Show spinner
state is UserArticlesLoaded → Show article list
state is UserArticlesError → Show error message
```

### Cubit Pattern

Simpler state management for features without complex events:

```dart
// Direct method calls
cubit.updateTitle('New Title');
cubit.saveDraft(authorId: userId, authorName: userName);
```

---

## Dependency Injection

Using `get_it` service locator configured in `injection_container.dart`:

### Registration Order
1. **External Services** (Firebase instances)
2. **Data Sources** (API clients)
3. **Repositories** (Data orchestration)
4. **Use Cases** (Business logic)
5. **BLoCs/Cubits** (Presentation logic)

### Usage

```dart
// In widgets
final authBloc = sl<AuthBloc>();

// In tests - easy to swap with mocks
sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
```

---

## Navigation

Route-based navigation with `onGenerateRoute` in `config/routes/routes.dart`:

| Route | Page | Parameters |
|-------|------|------------|
| `/` | Home/Article List | - |
| `/login` | Login Page | - |
| `/register` | Registration Page | - |
| `/article/:id` | Article Detail | articleId |
| `/editor` | Article Editor | article? (optional) |
| `/profile` | User Profile | - |

---

## Data Flow Example

### Publishing an Article

```
1. User taps "Publish" button
        │
        ▼
2. ArticleEditorCubit.publishArticle()
        │
        ▼
3. CreateArticleUseCase.call(params: article)
        │
        ▼
4. UserArticleRepositoryImpl.createArticle()
        │
        ▼
5. articleRemoteDataSource.createArticle()
        │
        ▼
6. Firestore document created
        │
        ▼
7. DataSuccess<UserArticleEntity> returned
        │
        ▼
8. Cubit emits ArticleEditorStatus.success
        │
        ▼
9. UI shows success message
```

---

## Error Handling

### Domain Layer
- Use cases return `DataState<T>` (either `DataSuccess` or `DataFailed`)

### Data Layer
- Repositories convert external exceptions to domain-level errors
- Firebase errors mapped to `AuthFailure` enum

### Presentation Layer
- BLoCs emit error states with user-friendly messages
- Error states contain both message and failure type for UI decisions

---

## Testing Coverage

| Component | Tests | Notes |
|-----------|-------|-------|
| Auth Use Cases | 14 | Sign in/up/out, get user |
| Article Use Cases | 57 | All CRUD + image upload |
| Auth Repository | 12 | Firebase integration |
| Article Repository | 52 | Firestore + Cloudinary |
| AuthBloc | 18 | All events + error mapping |
| UserArticlesBloc | 15 | Load, filter, delete, publish |
| ArticleEditorCubit | 21 | Full editor workflow |
| TtsCubit | 17 | Playback controls |
| **Total** | **210** | All passing ✅ |

---

## Future Enhancements

- [ ] Social authentication (Google, Apple)
- [ ] Real-time collaboration
- [ ] Offline support with local caching
- [ ] Push notifications for new articles
- [ ] Rich text editor with markdown
- [ ] Article comments and reactions
- [ ] User following system
- [ ] Analytics dashboard
