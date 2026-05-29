# Firebase Firestore Backend
In this folder are all the [Firebase Firestore](https://firebase.google.com/docs/firestore) related files. 
You will use this folder to add the schema of the *Articles* you want to upload for the app and to add the rules that enforce this schema. 

## DB Schema
The full database schema is documented in [docs/DB_SCHEMA.md](docs/DB_SCHEMA.md). It covers:
- **articles/{articleId}** — top-level collection with 14 fields, status transitions (draft → published → archived), soft-delete, and server timestamp enforcement.
- **articles/{articleId}/comments/{commentId}** — append-only subcollection, soft-delete only.
- **users/{uid}/savedArticles/{articleId}** — per-user bookmarks subcollection.
- **Composite indexes** for efficient querying (by author, status, date).
- **Storage paths** at `media/articles/{uid}/{articleId}/thumbnail` with MIME and size validation.

## Getting Started
Before starting to work on the backend, you must have a Firebase project with the [Firebase Firestore](https://firebase.google.com/docs/firestore), [Firebase Cloud Storage](https://firebase.google.com/docs/storage) and [Firebase Local Emulator Suite](https://firebase.google.com/docs/emulator-suite) technologies enabled.
To do this, create a project but enable only Firebase Cloud Storage, Firebase Firestore, and Firebase Local Emulator Suite technologies.


## Deploying the Project
In order to deploy the Firestore rules from this repository to the [Firebase console](https://firebase.google.com/)  of your project, follow these steps:

### 1. Install firebase CLI
```
npm install -g firebase-tools
```
### 2. Login to your account
```
firebase login
```

### 3. Add your project id to the .firebasesrc file 
This corresponds to the project Id of the firebase project you created in the Firebase web-app.
[Change project id](.firebaserc)

### 4. Initialize the project
```
firebase init
```

You should leave everything as it is, choose:
- emulators
- firestore
- cloud storage

### 5. Deploy to firebase
```
firebase deploy
```
This will deploy all the rules you write in `firestore.rules` to your Firebase Firestore project.
Be careful becasuse it will overwrite the existing firestore.rules file of your project.

## Running the project in a local emulator
To run the application locally, use the following command:

```bash
firebase emulators:start
```

## Running Security Rules Tests

The project includes comprehensive tests for Firestore and Storage security rules using `@firebase/rules-unit-testing`.

### Prerequisites
- Node.js 18+
- Java JDK 21+ (required by Firebase emulators)

### Install dependencies
```bash
npm install
```

### Run all rule tests
```bash
npm test
```

This starts the Firestore and Storage emulators, runs all tests, and shuts down the emulators automatically.

### Run tests for a specific service
```bash
npm run test:firestore
npm run test:storage
```
