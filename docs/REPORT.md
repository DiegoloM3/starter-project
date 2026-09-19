# Applicant Showcase App Report

## Introduction

This project extends the starter news application so a journalist can create and publish original articles. The implementation keeps the existing news feed while adding a focused newsroom workflow for writing, previewing and publishing stories.

## Learning journey

The project uses Flutter, BLoC, Clean Architecture and Firebase. The new feature follows the existing separation between presentation, domain and data layers. Firebase Authentication is used anonymously during development so Firestore and Storage rules can identify the current author.

## Implemented functionality

- Article creation form with headline, standfirst, body and thumbnail.
- Editorial preview before publication.
- Local image selection with `image_picker`.
- Public HTTPS thumbnail URL stored with the article.
- Article metadata stored in the Firestore `articles` collection.
- Published articles loaded into the feed.
- Firestore and Storage validation rules.
- Firestore composite index for the published feed query.
- Local Floor cache retained for saved articles and offline continuity.

## Challenges and decisions

The starter application already used a local database for saved articles and NewsAPI for the remote feed. Instead of coupling the UI directly to Firebase, a Firebase data source was added behind the existing repository contract. This keeps the presentation layer independent from Firestore and Storage and makes the integration easier to test or replace.

The Firebase project is intentionally not embedded in the repository. Each developer must configure their own project, enable anonymous authentication, and run `flutterfire configure`.

## Setup required before running

1. Set the real project id in `backend/.firebaserc`.
2. Enable Firestore and Anonymous Authentication in Firebase. Cloud Storage is not required.
3. From `frontend`, run `flutterfire configure` and select the same project.
4. Run `flutter pub get`.
5. From `backend`, run `firebase deploy` or start the emulators with `firebase emulators:start`.

## Proof of the project

Add screenshots or a screen recording here after running the configured Flutter application. The most useful flows to capture are the newsroom editor, preview mode, successful publication, and the published article appearing in the feed.

## Overdelivery

The newsroom is intentionally more than a plain CRUD form: it gives the writer an editorial preview, a visual publication action, image selection, validation feedback and a distinct publication-focused visual language. Future improvements could include drafts, scheduled publication, article editing, moderation and image cropping.

## Future directions

- Add authenticated user profiles instead of anonymous accounts.
- Add draft and archived statuses.
- Return the Firestore document id as a first-class domain value for edit and delete flows.
- Add integration tests against the Firebase Emulator Suite.
- Add pagination to the public feed.
