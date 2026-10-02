# Firebase Firestore Backend
In this folder are all the [Firebase Firestore](https://firebase.google.com/docs/firestore) related files. 
You will use this folder to add the schema of the *Articles* you want to upload for the app and to add the rules that enforce this schema. 

## DB Schema
The schema of the *Articles* (Firestore collection `articles` and Cloud Storage folder `media/articles`) is documented in [docs/DB_SCHEMA.md](docs/DB_SCHEMA.md).

## Getting Started
Before starting to work on the backend, you must have a Firebase project with the [Firebase Firestore](https://firebase.google.com/docs/firestore), [Firebase Cloud Storage](https://firebase.google.com/docs/storage) and [Firebase Local Emulator Suite](https://firebase.google.com/docs/emulator-suite) technologies enabled.
To do this, create a project but enable only Firebase Cloud Storage, Firebase Firestore, and Firebase Local Emulator Suite technologies.

> **Firebase Authentication**: the journalists sign in to the app with an email and a password, so the project also
> uses Firebase Authentication (free on every plan). In the Firebase console, go to **Authentication → Sign-in method**
> and enable **Email/Password**. The Local Emulator Suite includes an Authentication emulator, so nothing else is needed
> to work locally. See the [schema](docs/DB_SCHEMA.md) for why it was added.


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

> **Cloud Storage and the Blaze plan**: since February 3, 2026, Firebase only provisions new Cloud Storage buckets for
> projects on the pay-as-you-go [Blaze plan](https://firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024).
> On the free Spark plan, Cloud Storage only works in the Local Emulator Suite, so deploy only the Firestore rules and
> indexes with `firebase deploy --only firestore`. On a Blaze project, `firebase deploy` also deploys `storage.rules`.

## Running the project in a local emulator
The emulators do not need a Firebase account nor `firebase login` (the CLI only warns that you are not authenticated),
but they require Java 21 and the [Firebase CLI](#1-install-firebase-cli). To run the application locally, use the
following command:

```firebase emulators:start```

To keep the data between runs, start them with the npm script instead: it loads the data saved in `emulator-data/`
and saves it again when the emulators are stopped (`Ctrl+C`), so the articles published from the app are not lost:
```
npm run emulators
```

### Seeding the emulator with sample articles
The first time, the emulator starts empty. To create two demo journalist accounts and the `articles` collection with sample
articles, their comments and their thumbnails in `media/articles`, install the dependencies once and, with the emulators running, run the
seed script in another terminal:
```
npm install
npm run seed
```
The script publishes each article and comment signed in as its author and writes through `firestore.rules` and `storage.rules`, so the
sample data always follows the [schema](docs/DB_SCHEMA.md). The demo accounts (emulator only) are listed in
`scripts/seed-data/users.json`; you can sign in to the app with any of them.

## Testing the rules
`firestore.rules` and `storage.rules` are covered by tests in the `test` folder
(written with [@firebase/rules-unit-testing](https://firebase.google.com/docs/rules/unit-tests)).
They start the Firestore and Storage emulators with a demo project, so they never touch a real Firebase project:
```
npm install
npm run test:rules
```

`test/db_schema.test.mjs` checks that the [schema](docs/DB_SCHEMA.md) and the code say the same thing: the fields, length
limits and server timestamps of each collection against `firestore.rules`, the thumbnail extensions, content types and
size against `storage.rules`, and the limits the app checks before writing (its domain entities). It only reads files,
so it runs without the emulators (it also runs with `npm run test:rules`):
```
npm run test:schema
```
