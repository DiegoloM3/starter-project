# Known Bugs & Architectural Pitfalls

This document tracks recurring issues, bugs, and technical debt found during the development of Symmetry.

## Active / Recently Fixed

### 1. Broken Relative Imports (Flutter)
- **Issue**: Incorrect relative paths in repository implementations (e.g., `data/repository` looking for `domain` inside `data`).
- **Impact**: Compilation failure (`flutter build` fails).
- **Solution**: Ensure Clean Architecture paths are followed: `../../domain/repository/...` from `data/repository`.
- **Status**: Fixed in `storage_repository_impl.dart`.

### 2. Missing Model Utilities for Firestore
- **Issue**: `FirebaseDataSource` expects `fromRawData` and `toRawData` but models only have `fromJson`/`toJson`.
- **Impact**: Member not found errors during build.
- **Solution**: Implement aliases in the model that bridge to `fromJson`/`toJson`.
- **Status**: Fixed in `ArticleModel`.

### 3. Missing News Media
- **Issue**: Image rendering failing in news feed.
- **Cause**: Missing or malformed image URLs in the new backend responses.
- **Solution**: Audit API response mapping and ensure fallback to `kDefaultImage`.
- **Status**: Monitored.

## Historical Log

### 4. LLM Backend Latency
- **Issue**: Slow responses and high API costs for the AI assistant.
- **Solution**: Implemented a caching layer for LLM responses.

### 5. Image Upload Errors
- **Issue**: Persistent failures when uploading images to Firebase Storage.
- **Status**: Requires verified connectivity and proper metadata handling (implemented in `StorageRepositoryImpl`).

### 6. Rewards System - Low Effort Farming
- **Issue**: Users could earn tokens without reading content.
- **Solution**: Implemented "Reading Validation" (minimum time-on-page check).

### 7. Blockchain ESM Compatibility
- **Issue**: Hardhat deployment scripts failing due to ESM/CommonJS mismatches.
- **Solution**: Configured Hardhat for ESM compatibility.

### 8. Chatbot Hybrid Pipeline Failure
- **Issue**: Fallback from Ollama to OpenAI failing.
- **Status**: Requires periodic validation of API keys and local service status.

### 9. Android Build Warnings (Cloud Firestore)
- **Issue**: "Unchecked or unsafe operations" warnings during Gradle build.
- **Solution**: Update dependencies or suppress warnings if they are internal to the package.
