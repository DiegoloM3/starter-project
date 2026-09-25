# Articles — Firestore Schema

## Overview

This document defines the Firestore schema for **user-submitted articles** — the "upload your own article" feature added on top of the starter News App.

It is deliberately a separate model from the existing `daily_news` feature's `ArticleEntity`, which represents read-only articles cached from the external NewsAPI (different data source, different owner, different lifecycle — read-only + locally cached vs. fully mutable and Firestore-native). The new feature lives in its own `lib/features/user_articles/` slice with its own `UserArticleEntity`, documented alongside the domain layer in Phase C. This document covers the backend data shape only.

- **Collection:** `articles` (flat, top-level — not nested under a user)
- **Thumbnail storage:** Firebase Cloud Storage, path `media/articles/{articleId}.{ext}`
- **Identity:** Firebase Anonymous Auth. Every article's `authorId` is a real `request.auth.uid`, enforced in `firestore.rules` (Phase B) — not just an informational string.

## Why a flat collection, not `users/{uid}/articles/{articleId}`

The dominant read pattern is a **public feed** of every journalist's articles ordered by date, not a private per-user notebook — the whole point of the feature is "so that society can benefit from your genius." A flat collection makes that a single, simple query (`articles.orderBy('createdAt', 'desc')`). A subcollection-per-author structure would turn that same query into a heavier collection-group query for no benefit, since nothing here is private to the author.

## Fields

| Field | Type | Required | Notes |
|---|---|---|---|
| `authorId` | `string` | yes, immutable | Firebase Auth UID (anonymous sign-in, no login screen). Source of truth for ownership — `firestore.rules` checks `request.auth.uid == resource.data.authorId` on update/delete (Phase B). |
| `authorName` | `string` | yes | Byline, entered by the author in the create-article form. Anonymous Auth has no built-in display name, so this is a plain field captured at write time, not looked up from `request.auth` — the app may remember the last value locally as a convenience default, but that's a UI nicety, not a schema concept. |
| `title` | `string` | yes | 3–150 chars. |
| `description` | `string` | yes | 10–300 chars. Short summary shown in list previews (same role as `ArticleEntity.description` in `daily_news`). |
| `content` | `string` | yes | Full article body, minimum 50 chars. Unlike `daily_news`'s `content` (often truncated by NewsAPI's free tier, e.g. `"...[+1200 chars]"`), this is the complete text — we own the storage, so nothing gets cut. |
| `thumbnailURL` | `string` | yes | HTTPS download URL from Cloud Storage (the resolved URL, not just the storage path) — resolved once at upload time so the UI can render it directly with `cached_network_image` (already a dependency) without an extra async Storage call per article. Must point into `media/articles/`. |
| `createdAt` | `Timestamp` | yes, immutable | Server-set via `FieldValue.serverTimestamp()`. Replaces `daily_news`'s free-text `publishedAt` string with a real, sortable, timezone-safe type. |
| `updatedAt` | `Timestamp` | yes | Server-set on create, updated on every edit. Justified by "edit" being one of the 5 required use cases — not a speculative field. |

The Firestore document ID itself (auto-generated) is the article's `id` once mapped into `UserArticleEntity` — it is **not** duplicated as a field inside the document body, to avoid a second copy that could go stale.

## Cloud Storage convention

- Path: `media/articles/{articleId}.{ext}` — one thumbnail per article, extension preserved from the picked file.
- `{articleId}` is generated **client-side** before any write, via `FirebaseFirestore.instance.collection('articles').doc()`. This returns a `DocumentReference` with a real, unique ID with no network round-trip — which resolves the natural chicken-and-egg problem (the thumbnail's storage path needs the article's ID, but the article document doesn't exist yet). The write order in Phase F: (1) get a doc reference and its id, (2) upload the thumbnail to that id's Storage path, (3) `set()` the Firestore document — including the now-resolved `thumbnailURL` — in a single write.

## Anticipated query patterns (drives Phase B's `firestore.indexes.json`)

- **Public feed:** `articles.orderBy('createdAt', 'desc')` — a single-field order, no composite index needed.
- **My articles:** `articles.where('authorId', '==', myUid).orderBy('createdAt', 'desc')` — an equality filter combined with an `orderBy` on a *different* field. Firestore does require a composite index for this combination; it gets added in Phase B.
- **Article detail:** `articles.doc(id).get()`.

## Deliberately deferred (not in this version)

Left out to avoid designing for requirements that aren't real yet — all are additive later, since Firestore has no migrations to worry about:

- **`status`** (`draft` / `published`) — no draft workflow was requested; every article publishes immediately. A strong Overdelivery candidate.
- **`tags` / `category`** — no filtering-by-topic was requested.
- **`readTimeMinutes`** — cheap to compute from `content.length` later; nice detail-screen polish.
- **`viewCount` / `likeCount`** — engagement metrics; would need either a client-side `FieldValue.increment()` (fine at this scale) or Cloud Functions (out of scope for a Firestore-only backend as briefed).

## What was deliberately left out of the entity

- **`url`** — `daily_news`'s `ArticleEntity.url` links out to the article's source on the web. Self-authored articles have no external source to link to. If in-app deep-linking is ever wanted, that's a route generated from `id` at the presentation layer, not a stored field.

## Identity decision (resolved)

`authorId` only means something if `firestore.rules` can verify *who* is writing, which requires some form of authentication — not part of this project's originally briefed stack (Firebase, Flutter, Flutter BLoC).

**Resolved: Firebase Anonymous Auth.** Automatic sign-in on app start, no login screen, giving each install a stable `request.auth.uid` that gets stamped as `authorId` and checked for real in the security rules (Phase B) — a real ownership model without the scope of building login/registration screens, which aren't the focus of this feature.

Trade-off: an anonymous identity is tied to the app's local install — uninstalling the app or clearing its data loses it. Existing articles stay publicly visible either way (this is a public feed, not a private space); the device simply loses edit/delete rights over its own past articles.

**Update — optional permanent accounts (built).** The guest stays the default (still no login screen to get started), but a guest can now connect **Google or email/password** from the "My Articles" screen. Connecting uses `linkWithCredential`, which **keeps the same `uid`**, so every article written as a guest keeps its `authorId` and nothing in this schema or in `firestore.rules` had to change. If the chosen Google/email identity already belongs to an account, the app offers to switch to that account instead (a plain sign-in, so the `uid` changes); the guest's articles stay with the guest, because ownership rules deliberately don't allow one user to re-assign another's `authorId`. Signing out starts a fresh guest session. Identity data (email, provider) lives only in Firebase Auth — no `users` collection was added, since nothing in the app reads a profile yet.
