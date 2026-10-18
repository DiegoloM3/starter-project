# Firebase Firestore Backend
In this folder are all the [Firebase Firestore](https://firebase.google.com/docs/firestore) related files. 
You will use this folder to add the schema of the *Articles* you want to upload for the app and to add the rules that enforce this schema. 

## DB Schema
The schema for the `articles` collection and the `media/articles` Cloud Storage folder is documented in [docs/DB_SCHEMA.md](./docs/DB_SCHEMA.md).

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

## Assigning roles
Every registered user is a *reader*. To promote a user to *journalist* (or back to *reader*), run the `set-role` script with a [service account key](https://firebase.google.com/docs/admin/setup#initialize_the_sdk_in_non-google_environments):

```
npm install
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json npm run set-role -- user@email.com journalist
```

The user must sign in again for the new role to take effect.

**Never commit the service account key**: it grants admin access to the whole Firebase project. Keep it outside the repository.

## Demo data
The `seed` script creates demo data so the app can be tried right away: 4 journalists with 10 articles, 3 readers, comments and follows. All demo accounts use `@example.com` emails and the password `Demo1234!`.

```
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json npm run seed
```

The ids are fixed, so running it again updates the demo data instead of duplicating it. To remove all of it, including the follows of other users to demo accounts:

```
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json npm run seed -- --remove
```

## Testing the security rules
The Firestore and Cloud Storage rules are covered by tests in the `test` folder, which run against the local emulators:

```
npm install
npm test
```

## Running the project in a local emulator
To run the application locally, use the following command:

```firebase emulators:start```
