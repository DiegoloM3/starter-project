# Project Modules Implementation
This document outlines the specific modules that were implemented to fulfill the feature of uploading an article to Firebase, strictly following the Clean Architecture guidelines.

## 1. Data Module
Responsible for external API and Cloud interactions, ensuring no other layer processes raw data directly.
- **`FirebaseArticleService`**: A new remote data source created to handle the connection with Firebase Firestore specifically for the `articles` collection.
- **`ArticleModel`**: A data transfer object that extends `ArticleEntity`. It acts as the bridge to serialize objects into JSON maps before pushing them to Firestore.
- **`ArticleRepositoryImpl`**: Implements the repository interface. It acts as the coordinator, taking the pure business entity from the Domain module, converting it to a Model, and submitting it to the `FirebaseArticleService`.

## 2. Domain Module (Business Logic)
This is the core of the application, completely isolated from any external libraries (no Firebase, no dart:io, no Flutter materials).
- **`ArticleEntity`**: The primitive representation of an article. Purposely isolated to use primitive Strings for image URLs instead of physical files to respect Rule 2.1.1 and 2.2.1.
- **`UploadArticleUseCase`**: A unique, single-purpose class that implements the `UseCase` interface. It bridges the Presentation requests with the Repository contracts.
- **`ArticleRepository`**: An abstract interface defining the `uploadArticle` contract without enforcing any implementation details.

## 3. Presentation Module
Responsible for user interaction and State Management.
- **`UploadArticleCubit`**: A state manager that emits exactly three states (`Loading`, `Done`, `Error`). It exclusively depends on the `UploadArticleUseCase`, respecting Rule 3.2.3.
- **`ArticleUploadPage`**: The visual form that collects the user inputs (Title, Author, Image URL, Content). It communicates entirely through the Cubit and listens to its states using a `BlocConsumer` to render a `SnackBar` dynamically.

## 4. Security & Configuration Module (Overdelivery)
- **`constants.dart`**: Refactored to eliminate hardcoded keys. It leverages `--dart-define` to inject the `NEWS_API_KEY` dynamically during the build process, preventing sensitive data leaks.
- **`injection_container.dart` (Service Locator)**: We extended the `get_it` dependency injection to register our new Cubits, Use Cases, Repositories, and the Data Source, tying all the modules together efficiently at runtime.
