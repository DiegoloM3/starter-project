# Firebase Firestore Backend
In this folder are all the [Firebase Firestore](https://firebase.google.com/docs/firestore) related files. 
You will use this folder to add the schema of the *Articles* you want to upload for the app and to add the rules that enforce this schema. 

## DB Schema
The full schema is documented in [docs/DB_SCHEMA.md](docs/DB_SCHEMA.md). In short:

| Collection | Field | Type | Constraints |
|---|---|---|---|
| `articles/{articleId}` | `title` | `string` | 1–100 characters |
| | `content` | `string` | 1–5000 characters |
| | `thumbnailURL` | `string` | Path `media/articles/{articleId}.{jpg\|jpeg\|png\|webp}` in Cloud Storage |
| | `publishedAt` | `timestamp` | Server time of the write |

Thumbnails are stored in Cloud Storage under `media/articles/` (images only, 5 MB max).
Articles and thumbnails can be read by anyone and created when they match the schema; they cannot be updated or deleted.

## Testing the rules
The Firestore and Cloud Storage rules are covered by tests that run against the Local Emulator Suite, using a `demo-` project so nothing reaches the real Firebase project.
Requirements: Node.js, the Firebase CLI and Java 11 or newer (for the emulators).

```
npm install
npm test
```

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

```firebase emulators:start```
