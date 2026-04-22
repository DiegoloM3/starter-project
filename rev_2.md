# Clean Code & Architecture Review: Symmetry Project

This review is based on the principles outlined in the **Clean Code** manual and general Clean Architecture best practices.

## 1. Architectural Integrity (Clean Architecture)

### 🟢 Strengths
- **Layer Separation**: The project successfully separates **Data**, **Domain**, and **Presentation** layers.
- **Dependency Injection**: Heavy and correct use of `GetIt` for service management.
- **Failover Strategy**: The hybrid backend strategy (FastAPI -> Firebase) is well-implemented in the repository layer.

### 🔴 Violations
- **Logic Leakage (SRP)**:
    - **`ArticleDetailsView`**: Contains reward-claiming logic (`_claimReward`). According to Clean Code, UI components should only be responsible for rendering state, not executing business operations. This logic should be moved to a `RewardCubit`.
    - **`ArticleRepositoryImpl`**: Violates the Single Responsibility Principle by managing news fetching, database persistence, and cloud storage (image uploads).
- **Interface Segregation**: The `ArticleRepository` interface is starting to bloat. "Image Upload" should likely be part of a `StorageRepository` or `MediaRepository`.

---

## 2. Code Quality (Clean Code)

### 🔍 Meaningful Names
- **Improvements Needed**:
    - `ArticleModel.articleId`: The getter logic is a bit complex. It would be better as a static helper or a method with a clearer name like `generateUniqueId()`.
    - `sl`: While common in Flutter projects for "Service Locator", a more descriptive name like `locator` is preferred in very strict Clean Code environments.

### 🛠️ Functions & Logic
- **DRY (Don't Repeat Yourself)**:
    - The `postArticle` logic in the repository repeats the try-catch failover pattern. This could be abstracted into a generic `FailoverHandler`.
- **Side Effects**:
    - The `ArticleModel.articleId` getter has logic that depends on `url` and `title`. If these change, the ID changes, which might cause issues with local DB keys. This logic should be encapsulated during object creation.

### 🛡️ Error Handling
- **Exceptions**: The use of generic `Exception("...")` in `article_repository_impl.dart` makes it difficult for calling layers to handle specific errors (e.g., NetworkError vs StorageError).
- **Null Safety**: While significantly improved in the last pass, some layers still depend on `?? ""` as a catch-all, which can hide data integrity issues.

---

## 3. Security & Constants
- **Hardcoding**:
    - **[FIXED]** `newsAPIKey` was moved to `fromEnvironment`.
    - **[PENDING]** `kAlphaTesterId` is still a hardcoded string. While centralized, it should ideally come from a `UserEntity` obtained through `AuthRepository`.

---

## 4. Proposed Refactoring Path

### Phase 1: Separation of Concerns
1.  **[NEW]** `StorageRepository`: Move `uploadImage` logic here.
2.  **[NEW]** `RewardCubit`: Move reward-claiming logic from `ArticleDetailsView`.

### Phase 2: Professionalizing Logic
1.  **Custom Exceptions**: Implement `SymmetryException` subclasses for better error propagation.
2.  **Config Objects**: Pass a `NetworkConfig` object to repositories instead of reading global constants directly.

### Phase 3: Domain Purity
1.  Ensure `ArticleEntity` is the only object passed between BLoCs and UseCases, keeping `ArticleModel` strictly within the Data layer.
