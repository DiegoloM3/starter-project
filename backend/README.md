# Firebase Firestore Backend
In this folder are all the [Firebase Firestore](https://firebase.google.com/docs/firestore) related files. 
You will use this folder to add the schema of the *Articles* you want to upload for the app and to add the rules that enforce this schema. 

## DB Schema
The Firestore and Cloud Storage schema is documented in [docs/DB_SCHEMA.md](./docs/DB_SCHEMA.md).
It is enforced by [`firestore.rules`](./firestore.rules) and [`storage.rules`](./storage.rules), and every
constraint has an automated test in [`tests/`](./tests) that runs against the Emulator Suite.

## Testing the rules
The rules are tested with [`@firebase/rules-unit-testing`](https://firebase.google.com/docs/rules/unit-tests)
and Node's built-in test runner. The Emulator Suite requires **Java 21 or newer** on your `PATH`
(Android Studio ships one at `C:\Program Files\Android\Android Studio\jbr` on Windows).

```
npm install
npm test
```

`npm test` starts the Firestore and Storage emulators, runs every `tests/**/*.test.js` file and shuts the
emulators down. Use `npm run test:watch` while editing rules.

## Cloud Functions
[`functions/`](./functions) holds one callable function, `assistArticle`, the editorial assistant
behind *Ask the editor* and the reader lenses. It is the only code that talks to the language
model; the key lives in the Firebase secret `ANTHROPIC_API_KEY` and every account gets a daily
allowance of calls. The request and answer formats are in
[docs/DB_SCHEMA.md](./docs/DB_SCHEMA.md#cloud-functions).

```
cd functions
npm install
npm test                                              # unit tests, no network
firebase functions:secrets:set ANTHROPIC_API_KEY      # once per project
firebase deploy --only functions
```

## Continuous integration
Every pull request runs [`.github/workflows/ci.yml`](../.github/workflows/ci.yml): the Flutter
analyzer and test suite with coverage, the function unit tests, and the rules tests against the
emulators.

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
