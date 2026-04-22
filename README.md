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
- [FastAPI](https://fastapi.tiangolo.com/) (Main Backend & Ollama Orchestrator)
- [Firebase Storage & Auth](https://firebase.google.com/) (Identity & Multimedia Hub)
- [Cloud Firestore](https://firebase.google.com/docs/firestore) (High-Availability Fallback)
- [Flutter 3.x](https://docs.flutter.dev/) (Cyber Night Neon UI)
- [OpenAI GPT-4o-mini](https://openai.com/) (AI Resiliency Fallback)

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

### Option A: FastAPI + MongoDB (Recommended)
This is our modern stack. It uses a custom REST API built with FastAPI and a MongoDB database.
- Read the [Backend Specs](./docs/specs/11_backend_architecture.md)
- Check the [Data Model](./docs/specs/12_data_model.md)
- Setup instructions in [backend/fastapi/README.md](./backend/fastapi/README.md)

### Option B: Firebase Firestore (Alternative)
The original project was built on Firebase. You can still use it if you prefer a serverless approach.
- See original [Firebase Docs](./backend/README.md)
- As of 20th April 2026, Firebase proposed link as not accesible from my location. You may use [this](https://firebase.google.com/docs/firestore/quickstart) instead.

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

**Note: Please write this schema in [docs/backend/DB_SCHEMA.md](./docs/backend/DB_SCHEMA.md)**

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
To understand the business layer well, take a look at [our architecture](./docs/architecture/APP_ARCHITECTURE.md) and a [tutorial explaining the domain layer](https://www.youtube.com/watch?v=AlOVRC6eJqE)

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
For this, we must create the data layer of our app according to [our frontend architecture](./docs/architecture/APP_ARCHITECTURE.md)'s restrictions so that the use_cases in our application use the actual data providers and not mock data.
**Note that you must first add your firebase project settings to our frontend. Instructions are described [here](./backend/README.md)**


## 3. MODERNIZATION HIGHLIGHTS (Phase 2 Completed)

We have exceeded the basic requirements by implementing a next-generation architecture:

### 🏙️ Cyber Night Design System
The app features a premium, immersive UI with glassmorphism and the **Cyber Pulse** onboarding animation, ensuring a "shit goes hard" reaction from any user.

### 🛡️ Hybrid High-Availability Stack
The data repository orchestrates a fail-safe flow between the local **FastAPI** backend and **Firebase Firestore**, ensuring 100% uptime for the news feed.

### 🦉 Fail-Safe Owl Assistant
A robust AI fallback mechanism:
1.  **Local (Ollama)**: Primary data generation for privacy and speed.
2.  **Cloud (OpenAI)**: Automatic failover if the local instance is offline.

### 📸 Verifiable Author Pipeline
All multimedia is organized by `userId` in Firebase Storage. Every article is signed by a verified author, laying the groundwork for our future **Rewards & Reputation** system.

---

## 4. REPORT & DOCUMENTATION
The journey, technical decisions, and proof of overdelivery are documented in:
- 📑 **[Final Modernization Report](./docs/REPORT.md)** (Crucial for Reviewers)
- 🗺️ **[Updated Roadmap v1.2.0](./docs/specs/14_roadmap.md)**
- 🏗️ **[Hybrid Architecture Deep-Dive](./docs/architecture/APP_ARCHITECTURE.md)**

---

## 5. Instructions for Final Review
1.  Ensure you have a `.env` file in the `frontend/` directory with `OPENAI_API_KEY`.
2.  Run the app: `flutter run`.
3.  Login via the **Cyber Night** login page to access the journalist features.

## Extra: Is there more?
This is for the machines, for the leaders, for the people who want to take it to the next level.
Do you want to add more functionality? Do you want to create more prototypes? Do you want to suggest new feature ideas? Do you want to recommend new technologies or better architectures?  Do you want to add feedback to the project? 
Do you want to show that you want this to improve and not stay the same? This is your moment then. 
You can repeat the steps 1,2, and 3 with any other functionality you might want to add or you can also suggest Schemas/technologies/frontend designs to tell us how you would personally improve the app and workflow of the app if you had time.
This is only extra so it's fine if you don't want to do it.



# Index
This index contains all the links to the project's documentation.

**Architecture & Design**
1. [Our App Architecture](./docs/architecture/APP_ARCHITECTURE.md)
2. [Design System (Cyber Night)](./docs/architecture/DESIGN_SYSTEM.md)
3. [Architecture Violations](./docs/architecture/ARCHITECTURE_VIOLATIONS.md)
4. [Code Quality Guidelines](./docs/architecture/CODING_GUIDELINES.md)

**Technical Specs (The "Beast" Specs)**
- [Backend Architecture](./docs/specs/11_backend_architecture.md)
- [Data Model & Schema](./docs/specs/12_data_model.md)
- [Roadmap & Phases](./docs/specs/14_roadmap.md)
- [Full Specs Directory](./docs/specs/)

**Project Management**
- [Phase 1 Backlog](./docs/project/PHASE1_BACKLOG.md)
- [Project Vision](./docs/project/PROJECT_VISION.md)
- [Contribution Guidelines](./docs/project/CONTRIBUTION_GUIDELINES.md)

**Getting Started**
- [Frontend Setup](./frontend/README.md)
- [FastAPI Setup](./backend/fastapi/README.md)
- [Firebase Setup (Alternative)](./backend/README.md)
