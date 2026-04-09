# Applicant Showcase: Report

## 1. Introduction

With 10 years of experience building mobile applications, I've read and applied concepts from books like Clean Architecture, Clean Code, The Pragmatic Programmer, and Domain-Driven Design. So the project's structure and coding guidelines felt familiar and intuitive from the start.

My approach for this project was AI-Driven.
AI was an active collaborator in code generation, but always under my supervision and approval. This wasn't about asking AI to write code blindly. It was about using it as a tool to execute implementations based on specs I defined.

For AI context, I used repomix to pack the entire project into a single file, so I could give any model the real state of the codebase without ambiguity. I also used spec-kit (github.com/github/spec-kit), a tool developed by GitHub, to structure specs and establish the project's principles and constraints before writing any code.

The AI workflow looked like this:
I define the spec as a Product Engineer: what problem I'm solving, what I accept as valid, what's out of scope and why. Then the AI and I refine it until the spec is aligned with the goal. Only then do I ask the AI to implement it. The prompts and markdown files in the protocol are designed to prevent the AI from generating code without consulting me first. I always had to give my approval before any implementation.

Software development today is not about being better than AI at generating code. It's about using it as a tool to improve your work by defining the problem and guiding the solution. The spec is the bridge between what the user needs and what the AI can generate. Without a clear spec, the AI optimizes for what it can see, not for what the user actually needs. The design, direction, and final decisions were mine as the mobile expert.

---

## 2. Learning Journey

**Local vs. remote Firebase.** Before writing a single line of code I had to decide whether to connect to a live Firebase project or use the local emulator. I chose local, because any developer can start working on the app by just running `firebase emulators:start` without requesting access or sharing credentials, and always get a clean Firestore on every restart. For a team, that means less friction when onboarding.

**Updating vs. keeping existing versions.** Using the versions pinned in the base project was an option, but I decided to upgrade some packages and only keep the overrides necessary to avoid breaking compatibility. That forced me to learn how some Flutter dependencies were deprecated or changed, version conflicts I hadn't seen before, and changes across the ecosystem. For example, upgrading to `flutter_bloc 8.1.0` required adapting to the new `emit.forEach` API for handling streams inside cubits.

**`firebase_auth` anonymous sign-in on iOS** had a known bug in version 4.16.0 that I hadn't encountered before: the Dart-side Pigeon codec fails to decode the native plugin's response, but the sign-in itself works correctly. The workaround is catching `TypeError` and checking `currentUser` after the call. A proper fix exists in a later version. For now it works, it's documented in `improvements.md` (DEV-002), and it will be a one-line removal when the package is updated.

**Spec 009 had three regressions in v1.1.2.** The spec covered robust image and content rendering in the Daily News article detail. Version 1.1.0 added a content sanitizer with a regex bug that truncated JSON-like strings in article bodies. That same commit also removed a null guard on the article tile image (breaking the saved articles screen) and introduced a null-check crash on scroll. I found them by running the test suite and testing against real NewsAPI data. Version 1.1.2 fixed all three. But this process taught me something important: I can't trust that the AI knows what it needs to generate. AI-generated code is only as good as the context I provide and the tests I run. In this case, I made a mistake in the spec by not considering data that could break the code.

---

## 3. Challenges Faced

**Getting the base project to compile** took longer than expected. The original `pubspec.yaml` and `build.gradle` had pinned versions that conflicted with current Flutter tooling: Kotlin 1.6.10 vs `path_provider_android`'s embedding v2 API, `win32 5.3.0` failing on Dart's `UnmodifiableUint8ListView`, outdated `sqflite` plugin API. None of this was obvious from the error messages. Each one required tracing back to the failing package. All changes and reasoning are in `docs/DISCOVERY.md`.

**Xcode 26 and Firebase CocoaPods** was the most tedious problem in the exercise. Xcode 26's Explicit Module Builds system is strict about non-modular headers in a way that previous versions tolerated. It took several hours of reading native logs alongside Dart stack traces to find the fix: `use_frameworks! :linkage => :static`, a patch to the `Firebase.h` umbrella header guard, and `DEFINES_MODULE = NO` for the affected pods. I was tempted to leave iOS for later, but I didn't. Having only Android working is a technical debt not worth carrying, because it grows and becomes harder to fix over time. Everything is documented in `docs/DISCOVERY.md` under "iOS Podfile: Key Decisions."

**Where to get the current user's UID in the Community Cubit.** The options were injecting `FirebaseAuth` into the cubit, into the repository, or passing the UID as a constructor parameter. The AI proposed injecting `FirebaseAuth` directly into the cubit with a technically solid argument. But testability mattered more to me: if the cubit depends on Firebase, tests become heavier. I asked it to use constructor parameter injection instead. Spec 012 documents the alternatives and why I chose Option C. This wasn't the last time. There were other decisions where the AI's argument was good, but my product or architecture judgment was different.

---

## 4. Reflection and Next Steps

**Thinking like a Product Engineer before a developer.** The starting point for the Community feed wasn't "I'm going to implement CRUD in Firestore." It was: I'm a journalist who wants to publish articles for others to read. From there came the first real question: does the user need to register? Not for an MVP. A community journalist should be able to publish without friction: no registration, no login screen, just publish and see if anyone cares. That's the reason for anonymous auth as a first iteration: ship fast, get real feedback, add user registration only when there's a concrete reason to do so.

**Decisions I considered and didn't implement.** I spent time thinking about whether cleaning up widget nesting and applying Flutter best practices (extract widgets, const constructors, etc.) would add real value to this exercise. The answer was no, but I'll do it anyway as part of the Boy Scout principle, to leave the codebase better than I found it. Same with 100% test coverage: in my experience, 100% coverage doesn't guarantee the code is actually well-covered. I focused on what matters: entities, cubits, repositories, and widget flows with conditional logic. The rest I left out. I was also tempted to spend time on visual design, but the project documentation marked it as unnecessary, so I didn't. Deciding what not to do is just as important as deciding what to do.

**False progress with AI.** One of the most dangerous anti-patterns when working with AI is the illusion of progress: you generate a spec, the AI accepts it, you approve it without reading carefully, you implement, and at some point you realize you built something that wasn't needed or wasn't implemented correctly. It's a reminder that you can't just start vibe coding without having read and understood the spec, the problem to solve, and how you want it solved, before asking the AI to implement it. Reading and questioning each spec before accepting it was just as important as writing it.

**Questioning the pattern before replicating it.** Working with existing code carries a risk: doing things the same way just because that's how it's already done. I ran into this with `Bloc<Event, State>` vs `Cubit<State>`. The base project used BLoC, and the AI wanted to use BLoC regardless, but I didn't need events with differentiated logic. So I chose Cubit because it was the right tool, not because it broke the existing pattern or because the AI said Cubit was enough. The pattern is not the goal, it's just a way to solve a problem. If it doesn't fit, don't use it.

**The most important takeaway.** This exercise confirmed something I already knew but that's easy to forget when you're deep in the code: understanding the problem is more important than knowing the solution. Architecture, patterns, tools, all of that comes after. First you need to know what you're solving and for whom. Once that's clear, the simplest solution that works usually wins. The best solution in the book is useless if the user doesn't need it or won't use it.

The SDD workflow worked really well in the second half. Specs 004 and 005 were faster to implement than spec 003 because the questions the spec forced me to answer upfront were questions I would have had to answer mid-implementation anyway. Writing them first just moved the decision-making to the right place.

Test coverage ended at ~74% with 105 tests. Gaps are tracked in `docs/improvements.md`. Things I'd build next:

- A filtered "my articles" view
- Image compression before upload
- Real authentication to replace anonymous sign-in
- A CI pipeline with GitHub Actions to run tests automatically on every push
- An AI-powered feature to generate or suggest article titles and summaries based on content

---

## 5. Project Evidence

> Simulator: iPhone 17 Pro (iOS 18, Xcode 26.2) and Android Emulator (API 34).
> Firebase Local Emulator running at `localhost:4000`.

### Daily News Feed
![Daily News feed](media/01-daily-news-feed.png)

### Daily News Article Detail
![Article detail](media/02-daily-news-detail.png)

### Community Feed: Empty State
![Community empty](media/03-community-empty.png)

### Community Feed: With Articles
![Community feed](media/04-community-feed.png)

### Publish Form
![Publish form](media/05-publish-form.png)

### Publish Form: Validation Error
![Validation error](media/06-publish-validation.png)

### Community Article Detail: Owner View (Edit + Delete visible)
![Owner view](media/07-community-detail-owner.png)

### Community Article Detail: Non-Owner View
![Non-owner view](media/08-community-detail-viewer.png)

### Delete Confirmation Dialog
![Delete confirm](media/09-delete-confirm.png)

### Firebase Emulator: Firestore (Android)
![Emulator Firestore Android](media/10.a-emulator-firestore.png)

### Firebase Emulator: Firestore (iOS)
![Emulator Firestore iOS](media/10.b-emulator-firestore.png)

### Firebase Emulator: Storage (Android)
![Emulator Storage Android](media/11.a-emulator-storage.png)

### Firebase Emulator: Storage (iOS)
![Emulator Storage iOS](media/11.b-emulator-storage.png)

### Test Suite: 105 Passing
![Tests green](media/12-test-suite-green.png)

---

## 6. Overdelivery

### New Features

**Community feed (spec 003):** A second tab alongside Daily News. Any anonymous user can publish articles. Real-time via Firestore `snapshots()`.

**View and delete your own articles (spec 004):** The detail page shows Edit/Delete only to the article's owner, detected by comparing `uid` with the current user. Deletion is a two-step flow with a confirmation dialog and proper loading/error states.

**Edit your own articles (spec 005):** Title, description, and content are editable. Image replacement is deferred. It requires uploading a new file and cleaning up the previous one (tracked as IMP-005).

**Robust detail rendering (spec 009):** `CachedNetworkImage` with error fallback, a content sanitizer that removes JSON artifacts from NewsAPI responses, null-safe image handling throughout the project.

**Human-readable timestamps (spec 010):** Relative format for recent articles ("3 hours ago"), absolute fallback for older ones ("Apr 7 · 14:23"). 18 unit tests covering edge cases.

**Widget test suites (specs 011, 012):** 8 tests for the Daily News detail, 16 for the Community detail. Covers owner gate, deletion flows, each widget extracted independently.

### Architecture Improvements (spec 001: Boy Scout Rule)

5 violations fixed before writing any feature code:

1. `domain/entities/article.dart`: removed `equatable` import, replaced with manual `==`/`hashCode`.
2. `data/models/article.dart`: added `toEntity()`.
3. `data/models/article.dart`: renamed `fromJson` to `fromRawData`.
4. `data/repository/article_repository_impl.dart`: returns `List<ArticleEntity>` via `toEntity()`.
5. `data/repository/article_repository_impl.dart`: introduced `ArticleLocalDataSourceImpl`, removed direct `AppDatabase` access.

### Spec Driven Development Protocol

12 spec directories under `specs/`, each with a `spec.md` in `implemented` state. Every feature was specified before implementation. The protocol is documented in `AGENTS.md`.

### What to Improve Next

- Storage rules: validate that upload paths start with the caller's UID (IMP-003, one regex).
- Composite Firestore index for "my articles" query (definition ready in `backend/docs/DB_SCHEMA.md`).
- Firestore security rules tests using `@firebase/rules-unit-testing` (IMP-003).
- Image replacement in edit flow (IMP-005, requires orphaned Storage file cleanup).

---

## 7. Alignment with Symmetry's Values

**Truth is King:** `docs/improvements.md` documents every shortcut taken and why. Spec 009 regressions are in the spec's own version history, not hidden. Architecture decisions like the UID injection approach list the alternatives considered and explain the choice. Nothing is hidden.

**Total Accountability:** The 5 violations were fixed before writing any feature code. Every screen has loading, empty, and error states, not just the happy path. The improvements file has named items with affected files and estimated effort. That's a handoff document, not a wishlist.

**Maximally Overdeliver:** 12 specs, 105 tests, widget test suites for both detail pages, SDD protocol documented in `AGENTS.md`, schema with design rationale in `backend/docs/DB_SCHEMA.md`, `docs/START_HERE.md` so the reviewer doesn't have to explore the repo without guidance. The Firebase emulator setup means it runs end-to-end with `firebase emulators:start` + `flutter run`, no live project required.

---

## 8. SDD Process & AI Tooling

This project was built using Spec Driven Development with Claude as the coding collaborator.

**Context tools.** I used repomix to pack the project into a single file and give the AI the real state of the code without ambiguity. I used spec-kit as the spec framework, and with AI assistance generated `constitution.md`, the project principles that every implementation must respect.

**The protocol.** I write the spec, the AI and I refine it, I approve it, the AI implements, I read every file before committing, and if something is wrong I fix it or send it back with specific notes. The prompts and markdown files in the protocol are designed so the AI cannot generate code without consulting me first. That approval is mine and cannot be delegated.

**Concrete examples where I overrode the AI's output:**

- **Sanitizer regex (Spec 009):** the first version used a greedy pattern that truncated valid article text. I caught it testing against real NewsAPI data, wrote a test that reproduced the problem, and sent back the specific failing case.

- **UID injection (Spec 012):** the initial implementation injected `FirebaseAuth` directly into the cubit. The AI had a technically solid argument. I still flagged it as a testability problem and asked for constructor parameter injection instead.

- **Widget tests (Specs 011, 012):** early versions stubbed the cubit rather than the repository. I corrected them to use a `FakeCommunityArticleRepository` that drives the real cubit, so the tests exercise the actual state machine and not a mock that proves nothing.

**The most dangerous anti-pattern.** Working with AI can create an illusion of progress: you generate specs quickly, approve them without reading carefully, and at some point realize you built something nobody asked for. The spec is useless if you don't understand it. Reading and questioning each spec before accepting it was just as important as writing it.

**Why SDD and not just prompts.** SDD lets me translate my experience into words before asking the AI to implement them. Working with AI today is clearly better than not doing it. It generates code faster, suggests alternatives, catches edge cases. But it needs guidance from someone who understands the problem. The spec is that bridge. Without it, the AI optimizes for what it can see, not for what the user needs.

The git history is mine. Every commit was authorized and executed by me. The specs are my design. The AI's role was implementation execution. Using AI as a collaborator in 2026 is normal. The question is whether the engineer owns the spec or delegates it.
