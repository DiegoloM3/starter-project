# Symmetry — Applicant Showcase App

> Solución entregada por **Abraham Jiménez** — Flutter clean architecture + Firebase, con feature `user_articles` para que el usuario publique sus propios artículos.

## TL;DR

| Métrica                          | Valor |
|----------------------------------|-------|
| `flutter analyze`                | ✅ 0 errors · 0 warnings · 6 infos cosméticos |
| `flutter test`                   | ✅ 58 / 58 |
| Capas afectadas                  | domain · data · presentation · core · config · backend |
| Features nuevas                  | `user_articles`, `auth` (login + register) |
| Features migradas                | `daily_news` (entity, model, repo, blocs al contrato `Either<AppFailure, T>`) |
| Backend                          | Firestore + Storage en `symmetry-test-cf818`, rules con `isValidArticle()` y `deny-by-default` |
| ADRs                             | 3 (lints, dependency bands, decisiones consolidadas) |
| Overdelivery oficial             | go_router tipado · design tokens vía `ThemeExtension` |
| Plataforma Android               | Gradle 8.11.1 · AGP 8.9.1 · Kotlin 2.1.0 (toolchain al día) |

---

## Mapa de la solución (lectura rápida)

```
Usuario
   │
   ├── /                      DailyNews — feed de NewsAPI con fuente, retry, dark/light theme tokens
   ├── /saved                 SavedArticles — caché Floor local
   ├── /article/:id           ArticleDetailsView
   ├── /auth                  AuthPage — login + registro (Firebase Email/Password)
   └── /me/articles           MyArticlesPage 🔒 (gateado por go_router redirect)
        ├── /me/articles/new       ArticleEditorPage (publica)
        └── /me/articles/:id       UserArticleDetailPage
            └── /me/articles/:id/edit   ArticleEditorPage (edita)
```

Las rutas `/me/*` están **protegidas**: el `redirect` de go_router observa `AuthSession.changes` y bota al usuario a `/auth?next=…` cuando no hay sesión.

---

## Cómo correrla en 5 minutos

```bash
# 1. Instalar deps + codegen
make setup

# 2. Crear keys.local.json desde el template (gitignoreado)
make keys
#   → edita frontend/keys.local.json y pon tu NEWS_API_KEY real

# 3. Habilitar manualmente Email/Password en Firebase Console
#    (Authentication → Sign-in method → Enable)

# 4. Desplegar las firestore.rules + storage.rules
make deploy-rules

# 5. Run
make run            # debug, usa keys.local.json automáticamente
# o desde VS Code: F5 con la config "Flutter (debug)"
```

Calidad y CI:

```bash
make analyze        # flutter analyze (0 errors / 0 warnings esperado)
make test           # flutter test
make ci             # analyze + format + test (mismo pipeline que GitHub Actions)
```

---

## Decisiones de diseño clave

| Decisión                                            | Razón                                                                                  | ADR / referencia |
|-----------------------------------------------------|----------------------------------------------------------------------------------------|------------------|
| `Either<AppFailure, T>` en vez de `DataState<T>`    | El `DataState` original filtraba `DioError` a presentation; `Either + AppFailure` aísla el tipo de librería | [ADR-0003 §4](./docs/prueba-tecnica/adr/0003-decisiones-consolidadas.md#4-d3-d4-d5--contrato-universal-de-errores) |
| Fake repository en `data/fake/`, no solo en `test/` | Permite que F7 (presentation) avanzara antes de F8 (Firestore real) y que la demo corra sin credenciales | [ADR-0003 §10](./docs/prueba-tecnica/adr/0003-decisiones-consolidadas.md#10-d11--fake-repository-en-datafake) |
| `--dart-define-from-file` con `keys.json` template + `keys.local.json` gitignoreado | Secretos nunca tocan git history; el desarrollador clona y corre `make keys` | [SOLUCION §9.10](./docs/SOLUCION.md#910-gestión-de-secretos-y-makefile) |
| Article `id` generado client-side (`microsecondsSinceEpoch`) | Firestore solo exige unicidad de colección; las rules enforcean `request.resource.data.id == articleId` | [ADR-0003 §13](./docs/prueba-tecnica/adr/0003-decisiones-consolidadas.md#13-d14--article-id-generado-client-side) |
| `AuthSession` como **port read-only** + `FirebaseAuthSession` con comandos | El bloc del editor no debe importar `firebase_auth` (regla 3.1.1); el cubit de auth necesita comandos concretos. Misma instancia bajo dos tipos en GetIt | [SOLUCION §13.5](./docs/SOLUCION.md#135-firebase-auth-con-ui-de-login--registro-cierra-122-punto-4) |
| `image_picker` con `ImageSource.gallery` + permisos diferenciados por API level | Android 13+ usa Photo Picker (sin permiso runtime); Android ≤12 usa `READ_EXTERNAL_STORAGE` (legacy) | [SOLUCION §13.4](./docs/SOLUCION.md#134-galería-real-de-thumbnails-cierra-122-punto-3) |
| Modelo `NewsTopHeadlinesResponse` envuelve la respuesta de NewsAPI | Retrofit fallaba con `_Map<String,dynamic> is not a subtype of List` porque la respuesta es un objeto, no una lista | [SOLUCION §13.2](./docs/SOLUCION.md#132-modelo-de-respuesta-newsapi-alineado-al-contrato) |
| `dependency_overrides` en `analyzer` / `dart_style` / `win32` / `path_provider_android` / `sqflite` | `floor_generator 1.4.x` bloquea `analyzer ≥ 6.5`; algunos plugins viejos arrastran código incompatible con Dart 3.5+ y el embedding v1 de Flutter 3.29+ | [ADR-0002](./docs/prueba-tecnica/adr/0002-dependency-version-bands.md) |

---

## Arquitectura en una imagen

```
                ┌────────────────────────────────────────────┐
                │ presentation/                              │
                │ ┌──────────────┐  ┌──────────────────────┐ │
                │ │ AuthPage     │  │ ArticleEditor / List │ │
                │ │ (Cubit)      │  │ (Bloc + Cubit)       │ │
                │ └──────┬───────┘  └─────────┬────────────┘ │
                └────────┼────────────────────┼──────────────┘
                         │                    │
                         ▼                    ▼
                ┌────────────────────────────────────────────┐
                │ domain/                                    │
                │   UseCases · Entities · Params · Ports     │
                │   AuthSession · UserArticleRepository      │
                └─────────────────────┬──────────────────────┘
                                      │
                                      ▼
                ┌────────────────────────────────────────────┐
                │ data/                                      │
                │   Repository impls (Firestore + Storage)   │
                │   FakeUserArticleRepository (offline/tests)│
                │   ArticleRepositoryImpl (NewsAPI + Floor)  │
                └─────────────────────┬──────────────────────┘
                                      │
                                      ▼
                ┌────────────────────────────────────────────┐
                │ Firebase · Floor · NewsAPI · image_picker  │
                └────────────────────────────────────────────┘
```

Las flechas son **unidireccionales** y verificadas por `make grep-violations` (regla `presentation` no importa providers, `domain` no importa Flutter ni Firebase).

---

## Documentación de respaldo

> Todo el detalle exhaustivo está en `docs/`. Esta tabla es el índice rápido — si solo tienes 5 minutos abre **SOLUCION.md** §3 (flujo end-to-end) y §11 (Q&A anticipada).

| Documento | Para qué sirve |
|---|---|
| **[docs/SOLUCION.md](./docs/SOLUCION.md)** | Narrativa exhaustiva: qué se construyó, cómo funciona, por qué se decidió cada cosa. 13 secciones + Apéndice de archivos clave. |
| [docs/REPORT.md](./docs/REPORT.md) | Reporte requerido por la prueba — 7 secciones con tono de retrospectiva |
| [docs/APP_ARCHITECTURE.md](./docs/APP_ARCHITECTURE.md) | Reglas de arquitectura del proyecto (originales + extendidas) |
| [docs/prueba-tecnica/adr/](./docs/prueba-tecnica/adr/) | 3 ADRs con decisiones consolidadas (lints, dependency bands, todas las decisiones de diseño) |
| [docs/prueba-tecnica/PRE_PR_MANUAL.md](./docs/prueba-tecnica/PRE_PR_MANUAL.md) | Checklist manual antes del PR (screenshots, vídeo, deploy de rules) |
| [backend/firestore.rules](./backend/firestore.rules) | Rules con `isValidArticle()` (mismo predicate que el bloc del editor) |
| [backend/storage.rules](./backend/storage.rules) | Rules de Storage para `media/articles/{authorId}/{articleId}/*` |
| [backend/docs/DB_SCHEMA.md](./backend/docs/DB_SCHEMA.md) | Schema de la colección `articles` con tabla de campos + ejemplo JSON |
| [backend/docs/SCHEMA_RATIONALE.md](./backend/docs/SCHEMA_RATIONALE.md) | Argumentación campo a campo del schema |
| [backend/docs/RULES_VISUAL.md](./backend/docs/RULES_VISUAL.md) | Manual operativo: 13 casos para Rules Playground + procedimiento de deploy |
| [Makefile](./Makefile) | 20+ targets para run/build/test/ci/deploy/emulators |

---

## Brief original de la prueba

> A continuación se preserva el README original de Symmetry para que el revisor pueda contrastar lo entregado contra la consigna.

# Applicant Showcase App
Welcome to the repository for our Applicant Showcase App - an application designed for job applicants of Symmetry to showcase their capacity to learn and program good code.

## Who will see this project?
This project will be reviewed by senior developers at Symmetry to determine whether your capacities are suited to our fast-paced development environment. 
We are not looking for MASTERS of their craft, we are looking for people who have the ability to learn extremely quickly and adapt to an ever-changing environment where the ability to improve is a requirement.
That being said, this project may also be used simply to learn [Flutter](https://docs.flutter.dev/) or to create a project of your own which you can showcase to employers in the future (you are completely welcome to use this project to showcase your skills to employers).
However, we will only review your project if you are applying for a Programming Job at Symmetry so the question remains: how will we judge your work?

## To what standards will we judge your work?
We will judge your work by:
- The quality of your code
- Your experience - we do not expect the same from a programmer with 1 year of experience and a programmer with 5 years of experience
- The extent to which your project implements the specified functionality (or exceeds it...)
- Your alignment with Symmetry's 3 core values:
  - Truth is King
    - You must search the truth without regards to other people's opinions or supposed knowledge. If you believe something is the truth, help other people understand your point of view regardless of their position. This could mean changing the design prototypes to something you like more or using a backend framework you consider superior to Firebase (obviously explaining your decision) if you believe that this will bring a better project to life.
  - Total Accountability 
    - You must always reponsible for your actions and outcomes; this means you are responsible for your happiness and for the quality of your work.
  - Maximally Overdeliver
    - You must always give the people more than what they expect from you. You must always rise to the occasion. This could mean you will add more functionality we did not tell you to add or designed new prototypes or came up with ideas on how to improve the project

We know these are high standards, but our company isn't built for the ordinary; it's crafted for the exceptional. 
We're not seeking your average Joe; we're on the hunt for authentic beasts, the driving force behind societal evolution.
Symmetry IS the new generation. We will empower the relentless pursuit of innovation and excellence. 
If you're ready to unleash your potential and shape the future, show it in this project, and... welcome home.

*Note: You might take the third value as a hint to add more functionality and prototypes we did not suggest...*


Now, let us start with the instructions...
*You can follow the instructions specified or you can give more than what we expect from you (which will make it much more likely for us to hire you)*

# Instructions for getting started
First, you will need to install and understand the technologies that this project uses.

## Technologies Used
- [Firebase](https://firebase.google.com/)
- [Flutter](https://docs.flutter.dev/)
- [Flutter BLoc](https://bloclibrary.dev/)

Please understand that it does not matter at all whether you know about these technologies or not. In fact, in an ideal world you don't know anything about them and can learn them over the course of the next 72 hours and deliver an incredible project. This is an ideal situation since it will allow you to showcase your capacity to learn new technologies fast and deliver good solutions with the knowledge aquired which is exactly what we are looking for.

After you have installed this technologies, you must learn them to be able to use them.
For this, we have synthesized a group of resources that will make your learning process easier. 
This can of course be skipped (or replaced by other resources) if you already know these technologies.

## 1 | Learning the Technologies
*Note: We recommend you learn these technolies in the order displayed in this list*
1. Learn the Flutter framework:
- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Online Documentation](https://flutter.dev/docs)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
2. Learn how to combine a Flutter frontend and Firebase backend:
- [Flutter and Firebase](https://www.youtube.com/watch?v=sfA3NWDBPZ4&list=PL4cUxeGkcC9j--TKIdkb3ISfRbJeJYQwC)
3. Learn the BLoc technology for reliable state management in Flutter:
- [Flutter BLoc Technology Tutorial](https://youtube.com/playlist?list=PLB_RxclDAkeYBOTIJ8qUubHx9aQLoiHeM&si=VagmSkUCzC2xsBZb)
- [BLoc Library Docs](https://bloclibrary.dev/)
4. Learn Flutter Clean Architecture so that you know how to build a healthy codebase:
- [Flutter Clean Architecture tutorial](https://www.youtube.com/watch?v=7V_P6dovixg)
5. Read our project docs in order to understand the intricacies of our architecture, way of working, and contribution guidelines to see how our specific project works.
-  [Our Project Index](#index) with all the document files

Now, if you are safe that you have learned all the required technologies and understood our project architecture and guidelines,  you may start your work...

# 2 | The ASSIGNMENT... CHAN CHAN CHAAAANN (Dramatic Tone)
The app presented in this repository is a News App.
However, you have found the following to be true: YOU ARE A JOURNALIST!
And **as a journalist, you would love to upload your own articles to the app so that society can benefit from your genius**.
Therefore, this will be the functionality that you will be writing over the next days.

## 1. THE BACKEND 
First, we will build the backend of the project. 
For this, you will use [Firebase Firestore](https://firebase.google.com/docs/firestore).

#### 1.1 THE SCHEMA
Before you even get to actually building the backend in Firestore, you must create the schema for the Articles you will store in the database.
Here's a tutorial that will help you learn how to design schemas: [How to Design NoSQL DB Schemas](https://www.youtube.com/watch?v=QAqK-R9HUhc)

##### Now, what will our schema need?
Well, I will leave you to find out.
I will say, however, that you must use Firebase Cloud Storage to store the article thumbnails in a specific folder inside Firebase Cloud Storage.
A reference to these folder will be stored in the Firebase Firestore. Eg:
```
ArticleSchema = { 
  ...
  thumbnailURL: 'string' // this must be a reference to an image in Firebase Cloud Storage, folder 'media/articles'
  ...
}
```
*Hint: study the data we have in the articles from the API used in the app to design your own schema.*

**Note: Please write this schema in backend/docs/DB_SCHEMA.md**

### 1.2 THE IMPLEMENTATION OF THE SCHEMA
After writing the schema, you must implement it using Firebase's Firestore technology by creating the appropriate collections, subcollections, fields, documents, etc.
In order to understand Firebase Firestore you can watch the following tutorial: [Firebase Firestore w/ Flutter](https://www.youtube.com/playlist?list=PLB_RxclDAkeZhz0ZAJSfPrrPzt8r10gO9)

### 1.3 THE ENFORCEMENT OF THE SCHEMA
After implementing your schema using Firebase Firestore, you must enforce the schema using [Firebase Firestore rules](https://firebase.google.com/docs/firestore/security/rules-structure).
For this, read the `backend/README.md` file (to understand how to deploy the rules you wrote) and change the `backend/firestore.rules` file.


## 2. The FRONTEND....
Now that we have built the backend of the project, we will focus on implementing the frontend of the project.
The guidelines we follow at Symmetry for building a good frontend are the following: 
- Your 90 year old grandmother must be able to use the app (sorry if she's dead :/)
- An 18 year old male NPC must use the app and think "this shit goes hard"
However, we will not bore you with designing the application since this will not be part of your job at Symmetry (unless of course, you want to improve the design yourself...)
You will, however, implement the frontend of the [following figma prototype](https://www.figma.com/file/EVpa82aUzPJuJfewjAA5ke/High-Fidelity-Prototype?type=design&mode=design&t=RbLJDR7BRI8ZtRDP-1)

### 2.0 Setup
Before even beginning to build the frontend of the application, you need to connect the Flutter frontend with the Firebase backend. 
In order to do this, read the [following documentation](./frontend/README.md)

### 2.1 THE BUSINESS LAYER
After setting up, we do not recommend you get into developing the actual UI of the frontend until you have done the business layer.

This is the most important layer, and we recommend you create it with extreme care and attention to detail.
To understand the business layer well, take a look at [our architecture](./docs/APP_ARCHITECTURE.md) and a [tutorial explaining the domain layer](https://www.youtube.com/watch?v=AlOVRC6eJqE)

Now, implement the domain layer, but instead of using the data layer to get real data for the application, **use mock data inside the usecases** to be used by the presentation layer.

### 2.2 THE PRESENTATION LAYER
Now that you have implemented the business layer, we recommend you go into building the presentation layer through the use of Flutter BLoc's cubits. 
For this, read the following tutorial: [BLoc and Cubits tutorial](https://www.kodeco.com/books/real-world-flutter-by-tutorials/v1.0/chapters/3-managing-state-with-cubits-the-bloc-library)

After having read this tutorial, you will be ready to use the mock use_cases you created in *2.1* to form a great set of logical cubits so you can present the information to the user with the best performance and responsiveness.
Thus, first create the necessary BLocs and Cubits for appropriate state management of the frontend.
After this, convert [our figma prototype](https://www.figma.com/file/EVpa82aUzPJuJfewjAA5ke/High-Fidelity-Prototype?type=design&node-id=0%3A1&mode=design&t=xS20es91Shil8nZ9-1) into flutter code so we have a functional application and can start using it.

Notes: 
- You can be creative with animations or even improve the existing UI we have if you desire to do so.
- The Figma Prototype is full of annotations with suggestions of features which are not requirements but would show your capacity to overdeliver.
- The Figma prototype can be improved if you see fit.
- The Figma Prototype can be accessed [here](https://www.figma.com/file/EVpa82aUzPJuJfewjAA5ke/High-Fidelity-Prototype?type=design&node-id=0%3A1&mode=design&t=xS20es91Shil8nZ9-1)

## 2.3 THE DATA LAYER
Now that you have implemented the UI, the business logic, and the backend required for our functionality to work, it remains to write the code to ensure that the Flutter frontend and the Firebase backend will be synchronized so that any data you upload will not be lost when you close the application.
For this, we must create the data layer of our app according to [our frontend architecture](./docs/APP_ARCHITECTURE.md)'s restrictions so that the use_cases in our application use the actual data providers and not mock data.
**Note that you must first add your firebase project settings to our frontend. Instructions are described [here](./backend/README.md)**


## 3. REPORT
Now, you have finished your application... TON TON TON!!!!

However... before completely finishing your application you must create a Report explaining your experience.
This report is crucial for reviewers to understand your work so please do not ignore it.
[Here](./docs/REPORT_INSTRUCTIONS.md) are instructions on what should be added to the report: [Report Instructions](./docs/REPORT_INSTRUCTIONS.md)
**The report should be written in `/docs/REPORT.md`** 

## Extra: Is there more?
This is for the machines, for the leaders, for the people who want to take it to the next level.
Do you want to add more functionality? Do you want to create more prototypes? Do you want to suggest new feature ideas? Do you want to recommend new technologies or better architectures?  Do you want to add feedback to the project? 
Do you want to show that you want this to improve and not stay the same? This is your moment then. 
You can repeat the steps 1,2, and 3 with any other functionality you might want to add or you can also suggest Schemas/technologies/frontend designs to tell us how you would personally improve the app and workflow of the app if you had time.
This is only extra so it's fine if you don't want to do it.



# Index
This index contains all the links to the project's documentation.

**Frontend Documentation**
[Understanding the Frontend and getting started](./frontend/README.md)

**Backend Documentation**
[Understanding the Backend and getting started](./backend/README.md)

**Contributions and Violations**
1. [Contribution Guidelines](./docs/CONTRIBUTION_GUIDELINES.md)
2. [Architecture Violations](./docs/ARCHITECTURE_VIOLATIONS.md)
3. [Code Quality Violations](./docs/CODING_GUIDELINES.md)
4. [Our App Architecture](./docs/APP_ARCHITECTURE.md)
