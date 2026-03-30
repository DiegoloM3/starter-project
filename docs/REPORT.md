# Technical Test Report - Symmetry Job Applicant

## 1. Introduction
My initial experience diving into the Symmetry Applicant Showcase App was highly motivating. The project's structure is robust, heavily inspired by Clean Architecture principles. Having detailed documentation like `APP_ARCHITECTURE.md` and `ARCHITECTURE_VIOLATIONS.md` provided a very clear, professional standard from day one. My primary objective was to expand upon the existing features by integrating live data persistence with Firebase without breaking the meticulously crafted layers of the application. 

## 2. Learning Journey
One of the most enriching parts of this project was applying Clean Architecture to a cloud-based integration constraint. While I was familiar with standard Flutter and Firebase integrations, the challenge was to properly decouple Firebase operations so the Presentational layer (UI/Blocs) and Domain layer (Entities/Use Cases) remained completely agnostic to the fact that Firebase was powering the data.

I utilized the `get_it` service locator to map abstract repositories to our new custom `FirebaseArticleService` only within the Data Layer. I learned how to strictly separate the state management of remote API calls from cloud document creations seamlessly. A key realization was maintaining the purity of the Data Entity—ensuring all objects remain decoupled logic units and routing the UI events purely through specialized Cubits (`UploadArticleCubit`).

## 3. Challenges Faced
I encountered two major challenges during development:

1. **Architectural Purity vs Practical Features (Image Uploads):** 
Initially, I planned to integrate a native camera gallery (`image_picker`) for article photos. However, `image_picker` relies heavily on `dart:io` physical files and device-specific constraints. Injecting physical `File` objects through the Domain's `ArticleEntity` to the Data Layer would subtly violate the absolute purity of the Business Logic layer. Moreover, importing Firebase Storage directly into the Cubit to process the file would violate Rule **3.1.1** and **3.2.3** of `ARCHITECTURE_VIOLATIONS.md` ("Do not directly access data layer providers from Presentation"). 
*Solution:* I overcame this gracefully by adapting the schema to simply accept an **Image URL**. This circumvented the UI dependencies dropping into the logic, ensuring the `ArticleEntity` remains a purely primitive-based business object.

2. **Android Gradle Plugin (AGP) and Compatibility Constraints:** 
While testing the app builds natively on Android, I faced an environment mismatch. Modern transitive dependencies were expecting an experimental AGP (v8.9.1+), which broke Android 13/14 emulator stability.
*Solution:* I dove into the `settings.gradle` and `gradle-wrapper.properties`, downgrading conflicting bleeding-edge packages and locking the internal execution environment strictly to AGP 8.3 and Gradle 8.4 layout, stabilizing the builds permanently.

## 4. Reflection and Future Directions
Technically, this challenge forced me to think two steps ahead before modifying state inputs. Professionally, it simulated exactly what it means to work on an enterprise application—where stability and rules matter more than hacking a quick feature together.

**Future Improvements:**
If I had more time, I would incorporate:
- **Firebase Authentication:** Connecting real users to the `Author` schema.
- **My Articles Screen:** Developing the opposite stream (`getUploadedArticles`) to fetch the Firebase collection into a dedicated "Community Articles" UI timeline, separate from the primary `NewsAPI`.
- **Repository Pattern for specialized cloud storage:** Expanding the backend layer so if Symmetry switches from Firebase to AWS/Supabase, we simply swap the remote generic interfaces.

## 5. Proof of the Project
Since this is a simulated technical environment, I have verified my application by successfully deploying it onto an Android Emulator (API 34 stable). 
The final flow:
1. Navigating through the Home Page floating action button.
2. Filling out the `ArticleUploadPage` with dynamic URL image embedding.
3. Submitting to the `UploadArticleCubit` which triggers the pure UseCase, ending with a live Firestore implementation.
*(I am attaching external screenshots of both my Emulator and my Cloud Firestore console actively populated with the newly created articles as the primary mechanism of proof).*

## 6. Overdelivery
I ensured to go beyond simple requirements to demonstrate full ownership of the project:

### 6.1 New Features Implemented
- **Dynamic BLoC Feedback Interface:** The Cubit doesn't just upload data silently. It yields real-time `Loading`, `Success`, and `Error` states via a `BlocConsumer`. This orchestrates a UI `SnackBar` and automatic page pop, elevating the user experience significantly.
- **Environment Variable Security:** I refactored the hardcoded `newsAPIKey`. To meet production standards, I injected the key externally using `--dart-define=NEWS_API_KEY`. As you teach in your codebase: secrets belong in the build process, never in git tracking.

### 6.2 Prototypes Created
- **Custom Backend Schema Prototype (`DB_SCHEMA.md`):** Modeled in the `backend/` folder, this provides an upfront declaration of the database architecture, ensuring cloud validations can match the object configurations built inside our Dart code.

## 7. Extra Sections & Compliance
I stringently adhered to your `CODING_GUIDELINES.md`:
- **CG1 (Boy Scout Rule):** Left all classes cleaner, removing default boilerplate and keeping standard formatting consistent.
- **CG2 & CG3 (Meaningful Names, Small Functions):** Enforced clear, verb-driven execution functions like `uploadArticle(article)` and UI breakdown blocks like `_buildTextField`.
