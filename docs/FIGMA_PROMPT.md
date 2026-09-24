# Figma design brief — News App with journalist publishing

Paste this whole document as the prompt. It describes an app that already
exists and works: every screen, field, state and string below is implemented,
so the design should fit the app rather than the app being rebuilt to fit the
design.

## 0. What to revise and what to create

Three frames already exist and must be **revised**, not replaced. They set the
visual direction for everything else:

- `Daily News`
- `Publish Article`
- `Publish Article: data added`

Revise those three against the rules in this brief, then **create the
remaining screens in the same visual language**. Consistency with the revised
three matters more than novelty in the new ones.

## 1. What the app is

A news reader that also lets people write. Two things happen in it:

- **Anyone** opens it and reads the news, with no account. This is the front
  door and it is never blocked.
- **A journalist** signs in and writes their own articles: drafts, covers,
  publishing, editing, deleting. Published articles become readable by
  everyone in a community feed.

Reading is open. Writing needs an account. That asymmetry should be felt in
the design: nothing should make a reader feel they have to sign up.

## 2. The bar this design is judged against

The review asks for exactly two things:

> Your 90 year old grandmother must be able to use the app
>
> An 18 year old male NPC must use the app and think "this shit goes hard"

These are not decoration. They are the acceptance criteria, and they pull in
opposite directions unless they are separated carefully.

**The grandmother test — the interaction layer must be obvious:**

- Body text 16–18pt minimum, and the layout must survive the system font being
  scaled up 200% without clipping or overlap.
- Tap targets 48×48dp minimum, with real space between them.
- **No icon-only primary actions.** Every icon that does something important
  carries a text label underneath or beside it. An unlabeled icon row is the
  single most common way this test is failed.
- Contrast at WCAG AA or better, in both themes. Never colour alone to carry
  meaning — pair it with a label or an icon.
- One obvious primary action per screen. If two buttons look equally
  important, neither is.
- Plain words, no jargon: "Save for later", not "Persist draft".
- Every destructive action is confirmed, and every action gets visible
  feedback. Nothing happens silently.
- Nothing is reachable only by a gesture. Swipe can be a shortcut, never the
  only way.

**The "this shit goes hard" test — the presentation layer must have teeth:**

- Bold typographic hierarchy: large, confident headlines against quiet body
  text. Flat, same-size text reads as unfinished.
- Generous whitespace. Cramped equals cheap.
- Photography is the hero. Article covers should be large, edge-to-edge or
  near it, with proper treatment when an image is missing.
- One distinctive accent colour. Default Material blue reads as a template.
- Full dark mode, designed rather than inverted.
- Motion that acknowledges: success states animate in, list items settle,
  transitions between reading and writing feel continuous.
- Empty states with personality instead of grey boxes.

**How to resolve the tension:** put the flair in *presentation* — type,
imagery, colour, motion, spacing — and keep the *interaction* boring and
legible. A screen can be beautiful and still label its buttons. What it cannot
do is be clever about where things are or what they do.

## 3. Design system to establish first

Deliver these as Figma styles/variables before the screens, because every
screen below depends on them:

- **Colour**: one accent, plus semantic roles for success, warning, danger and
  info. Full light and dark palettes. Published vs draft needs a colour pair
  that is still distinguishable in greyscale.
- **Type scale**: display, headline, title, body, label, caption. State the
  sizes.
- **Spacing scale**: a 4 or 8pt grid, used consistently.
- **Radius and elevation**: one radius for cards, one for buttons, one for
  sheets.
- **Components**: primary/secondary/text button, text field (default, focused,
  error, disabled), article card (large and compact), status chip, filter
  chip, snackbar, dialog, bottom sheet, empty state, loading skeleton, avatar.
- **Iconography**: one family, one weight.

## 4. Navigation

The app currently crams four unlabeled icons into the top bar. That fails the
grandmother test outright. Replace it with a **bottom navigation bar with
labelled tabs**, which also happens to be what the 18-year-old expects:

| Tab | Contains |
|-----|----------|
| **News** | Daily News — the world news feed |
| **Community** | Articles written by journalists in the app |
| **Saved** | Articles the reader bookmarked |
| **Account** | Sign in, or the signed-in person's profile and their articles |

Writing is a **floating action button** labelled "Write", visible on News and
Community. Tapped without an account, it opens the sign-in prompt (§5.14)
rather than failing silently.

The Account tab changes shape with the session: signed out it shows a short
invitation to sign in; signed in it shows the profile with "My articles" and
"Sign out".

## 5. Screens

For each screen: what it is for, what is on it, and every state it can be in.
Strings in quotes are the ones the app actually uses — please keep them.

### 5.1 Daily News — REVISE

**Purpose.** The home screen and front door. World news, readable by anyone.

**Content.** A scrolling list of news articles. Each: cover image, headline,
source/author, publication date, short description. One item should be treated
as a lead story with a larger card.

**Actions.** Tap an article → News Article Detail. FAB "Write". Bottom nav.

**States.** Loading (skeleton cards, not a spinner on an empty screen); loaded;
empty; error with a "Try again" button; offline.

### 5.2 News Article Detail — CREATE

**Purpose.** Reading a world-news article.

**Content.** Large cover, headline, author and date, body text, and a link out
to the original source. A bookmark control that visibly changes state when
tapped.

**States.** Default; bookmarked; image missing; long-title.

### 5.3 Community Feed — CREATE

**Purpose.** Articles written by people using the app. Open to everyone,
including signed-out readers.

**Content.** Title "Community Articles". A list of published articles: cover,
title, "By {author}", description excerpt, publication date, and view count.
Paged — a "Load more" control at the end of the list.

**States.** Loading; loaded; loading more; end of list; empty ("No published
articles yet."); error ("Could not load articles.").

### 5.4 Article Reader — CREATE

**Purpose.** Reading one community article.

**Content.** Full-bleed cover, title, author with avatar, publication date,
view count, body text. Below the article, a section **"More from {author}"**
listing that author's other published articles as compact cards. The article
being read is never in that list.

**Actions.** Tap another article → same screen. Back.

**States.** Default; author has no other articles (hide the section rather
than show an empty one); very long article; missing cover.

### 5.5 My Articles — CREATE

**Purpose.** The journalist's own workspace. Everything they have written,
drafts included. Requires an account.

**Content.** Title "My Articles". A search field ("Search in my articles") and
filter chips: **All / Drafts / Published**. A list of the person's articles,
newest edited first. Each row: title, excerpt, a clear **status badge**
("Draft" or "Published"), the dates, and — for published ones — view count.

Each row offers Edit, Delete, and Publish (drafts only). These must be
reachable without a swipe.

**States.** Loading; loaded; empty ("No articles yet. Write one!"); filtered
result empty; search result empty; error.

### 5.6 Article Editor — REVISE (`Publish Article` and `Publish Article: data added`)

**Purpose.** Writing and editing. The most important screen in the app, and
the one where both tests are hardest to pass at once.

**Content.**

- Header: "New article" when writing a new one, "Edit article" when editing.
- **Cover image**: an empty state inviting the person to add one ("Add cover
  image"), and a filled state showing the chosen image with Replace and Remove.
  Design both; the empty state should be inviting, not a grey rectangle.
- **Title** — single line, large, styled like the headline it will become.
- **Description** — short summary, two lines, max 500 characters with a
  counter.
- **Content** — the body, the tallest field on the screen.
- Validation errors shown **under the field they belong to**, in words:
  "The article needs a title.", "Readers need a short description.",
  "Add a cover image before publishing."
- **Autosave indicator**: a quiet "Draft saved" with a timestamp. This must
  never be a dialog, a toast that covers the keyboard, or anything that takes
  focus — the person is mid-sentence. Design it as ambient text near the
  actions.
- Actions: **"Save draft"** (secondary) and **"Publish"** (primary).

**When the article is already published**, the actions change meaning: the
primary becomes "Save changes", and "Save draft" is replaced by an
**"Unpublish"** action that returns it to draft and hides it from readers.
Offering "Save draft" on something already public is confusing and should not
appear.

**Dates.** Published articles carry two different dates and the design must
show them as different facts: "Published 18 Sep · Edited 22 Sep". They are not
the same value and conflating them hides edits from readers.

**States.** New and empty; partly filled; fully filled; saving; autosaved;
validation errors; upload in progress; upload failed; editing a published
article.

### 5.7 Article Published — Success — CREATE

**Purpose.** Confirming the one irreversible-feeling action in the app. This
is the celebration screen.

**Content.** A **large animated green check**, a clear headline ("Your article
is live"), one line explaining what just happened — that anyone can now read
it in the Community feed — and the article's title and cover as confirmation
of *which* article.

**Actions.** "View article" (primary), "Back to my articles" (secondary).

Full screen, not a toast: publishing makes something public, and that deserves
an unmistakable acknowledgement. Contrast this with saving a draft, which is
routine and gets only a snackbar.

### 5.8 Sign In — CREATE

**Purpose.** Getting back into an existing account.

**Content.** "Sign in". Email field, password field with a show/hide control.
Primary button "Sign in". Text links: "I forgot my password" and "Create an
account".

**Error copy.** On bad credentials: "That email and password do not match an
account." The message is deliberately the same whether the email exists or
not — the design must not add anything that reveals which was wrong.

**States.** Empty; filled; loading (button shows progress, stays the same
size); field-level validation errors; sign-in failed.

### 5.9 Create Account — CREATE

**Purpose.** Making an account, only ever because the person wants to write.

**Content.** "Create account". Fields: name readers will see (optional, and
labelled as optional), email, password, repeat password. Password rules stated
**before** the person types, not after they fail: "At least 8 characters."
Primary "Create account", link "I already have an account".

**Error copy.** "That email already has an account. Sign in instead.",
"The two passwords are different.", "Use at least 8 characters."

**States.** Empty; filled; loading; each validation error; email already
registered.

### 5.10 Reset Password — Request — CREATE

**Purpose.** Starting a password reset.

**Content.** "Reset password", one explanatory line, an email field, and a
primary "Send reset link".

### 5.11 Reset Password — Email Sent — CREATE

**Purpose.** Confirming the email went out.

**Content.** A friendly illustration or icon, and this message, which must
stay deliberately vague: *"If that email has an account, a reset link is on
its way. Open it to choose a new password, then come back and sign in."*

It must not confirm whether the address exists — that would let anyone test
who is registered. Design accordingly: no "We sent it to X" phrasing.

Add a practical note in the layout: a hint to check the spam folder, because
these emails commonly land there.

**Actions.** "Back to sign in".

### 5.12 Account — CREATE

**Purpose.** The signed-in person's home.

**Content.** Avatar or initials, display name, email. Then: "My articles" with
a count, and "Sign out". If the person has published anything, a small summary
worth being proud of — number of published articles and total views.

**States.** Signed in; signing out; **signed out**, which shows instead a
short invitation explaining that an account is only needed to write, with
"Sign in" and "Create account".

### 5.13 Delete Article — Confirmation — CREATE

**Purpose.** Preventing an accidental, unrecoverable deletion.

**Content.** A dialog: "Delete article", the article's title quoted, and a
plain warning that it cannot be undone. Buttons "Cancel" (default emphasis)
and "Delete" (clearly destructive). Cancel must be the easier target.

Followed by a snackbar confirming the deletion.

### 5.14 Sign-in Required — CREATE

**Purpose.** What a signed-out reader meets when they tap "Write".

**Content.** A bottom sheet, not a full screen — it must feel like an
invitation, not a wall. One line explaining that writing needs a free account
while reading never will, then "Sign in" and "Create account", and an obvious
way to dismiss and keep reading.

### 5.15 Saved Articles — CREATE

**Purpose.** The reader's bookmarks.

**Content.** A list of saved articles, each removable. Empty state explaining
how to save one.

## 6. Feedback rules

Every action gets a response, and the weight of the response matches the
weight of the action. Apply this consistently:

| Weight | Pattern | Used for |
|--------|---------|----------|
| Big, public, irreversible-feeling | **Full screen success** | Publishing an article |
| Ordinary, explicit | **Snackbar** | Draft saved by tapping, article deleted, signed out |
| Ambient, automatic | **Inline text** | Autosave ("Draft saved"), upload progress |
| Needs a decision | **Dialog** | Deleting, unpublishing, discarding unsaved changes |
| Invitation | **Bottom sheet** | Sign-in required |
| Blocking wait | **Skeleton or inline progress** | Loading a list, saving |

Two rules that matter more than the table:

- **Nothing that happens automatically may interrupt.** The autosave indicator
  must never steal focus, cover the keyboard, or navigate. The person is
  typing.
- **Errors say what to do next**, not what went wrong internally. "Check your
  connection and try again", never "Error code 7".

## 7. States every list needs

Design all five for each list screen. Missing states are where apps look
unfinished:

1. **Loading** — skeleton cards shaped like the real content.
2. **Loaded**.
3. **Empty** — explains why it is empty and what to do about it, with an
   action.
4. **Error** — plain language and a "Try again" button.
5. **Paging** — loading more at the bottom, and a clear end of list.

## 8. Deliverables

1. The design system from §3 as Figma styles and components.
2. The three revised frames.
3. The new screens from §5, each with the states listed.
4. Light and dark for every screen.
5. One frame showing the type scale at default size and at 200% scaling,
   proving the grandmother test.
6. A short flow diagram: reading without an account → hitting "Write" →
   signing in → writing → publishing → seeing it in the Community feed.
