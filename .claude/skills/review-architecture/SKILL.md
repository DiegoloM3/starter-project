---
name: review-architecture
description: Audits Flutter code in this repo against ITS OWN documented Clean Architecture rules (docs/APP_ARCHITECTURE.md, docs/ARCHITECTURE_VIOLATIONS.md, docs/CODING_GUIDELINES.md), citing the exact document and section for every violation found -- never generic best practices. Use this any time a phase of work on a feature (domain layer, Cubits/presentation, data layer, or any other layer) is about to be considered done, whenever the user asks whether code "follows the architecture", "respects the rules", "is compliant", wants a check "before closing this phase", or mentions violations, guidelines, or a clean-architecture review -- even if they don't say "architecture review" by name. Defaults to reviewing frontend/lib/features/user_articles but accepts any other feature path as an argument.
---

# Review Architecture

This repo grades code against its own written rules, not generic Clean Architecture folklore. This skill's whole job is to be the strict, literal-minded reviewer that `docs/CONTRIBUTION_GUIDELINES.md` describes -- so every claim it makes has to trace back to an exact line in `docs/APP_ARCHITECTURE.md`, `docs/ARCHITECTURE_VIOLATIONS.md`, or `docs/CODING_GUIDELINES.md`. Never invent a rule that "sounds like" Clean Architecture in general -- if you can't point to the section, don't report it as a violation.

## Before anything else: re-read the three docs

Read `docs/APP_ARCHITECTURE.md`, `docs/ARCHITECTURE_VIOLATIONS.md`, and `docs/CODING_GUIDELINES.md` fresh, every time this skill runs -- don't rely on a memory of them from earlier in the conversation. They're short, and re-reading is the only way citations stay accurate if they're ever edited. `ARCHITECTURE_VIOLATIONS.md` numbers its rules explicitly (cite as e.g. "ARCHITECTURE_VIOLATIONS.md Sec. 1.2.4"); `CODING_GUIDELINES.md` uses "CG{n}" and has a real numbering quirk -- two different rules under guideline 2 are both labeled "2.1" -- keep that as-is when citing rather than silently renumbering it.

## Step 1: run the mechanical checker

```
python .claude/skills/review-architecture/scripts/check_layering.py [target]
```

`target` is a feature path relative to the repo root, defaulting to `frontend/lib/features/user_articles`. If the skill was invoked with an argument, or the user names a different feature, pass that path instead -- the script works on any feature that follows the `data/domain/presentation` layout, not just this one. It expects `target` to be a single feature's root folder (the one directly containing `data/`, `domain/`, `presentation/`) -- pointing it at `frontend/lib` itself won't work, since those folder names would no longer be the direct children it looks for.

The script mechanically verifies every rule in `ARCHITECTURE_VIOLATIONS.md` that's really a grep in disguise: import direction between layers, which folder is allowed to import Firebase/Firestore SDK packages, exception-throwing location, model shape (`extends` an entity, has `toEntity()`, has `fromRawData`), repository impl naming (`{Interface}Impl`), and use-case shape (exactly one `call()`). Read its full output -- every finding already carries its exact citation and file:line, so don't re-derive these by hand and don't second-guess a PASS it reports. What it does *not* do is read for meaning: it can't tell if a function is too long, an argument list too wide, or a name is misleading. That's Step 2.

If the script reports the target doesn't exist yet, say so plainly and stop -- that's the expected, correct state before that layer has been built for this phase, not an error to work around.

## Step 2: read every file in scope, for what the script can't check

Open every file the script scanned (its `Files scanned` count tells you how many to expect) and check each of these against the actual text of `CODING_GUIDELINES.md` -- none of this is mechanically checkable the way Step 1 is, it needs you to actually read the code and use judgment, the same way a human reviewer would:

- **Nesting depth <= 2** (CG3.2) -- count `if`/`for`/`while`/`try` blocks nested inside each other in every method body.
- **Argument count** (CG3.5) -- 0-2 is the target, 3 is "avoid", >3 needs a clear reason in the code itself (or should become a `Params` class -- exactly why use cases have one).
- **Single Responsibility** (CG3.3 for functions, CG5.2 for classes) -- does this function/class do one thing, or does its name hide a second job it's also doing?
- **Class size / instance variables** (CG5.1/CG5.3) -- a class with a growing field list is usually a sign two responsibilities got merged.
- **Naming quality** (CG2.1-2.5) -- intention-revealing, no disinformation (a name implying something the code doesn't do), pronounceable, class names are nouns, function/method names are verbs. Also check it against the convention this codebase *already* uses (CG2.1, "follow set conventions") -- e.g. use case classes end in `UseCase`, repository private fields are prefixed `_`, matching `daily_news`'s existing `GetArticleUseCase`, `ArticleRepositoryImpl`, etc.
- **Command-Query Separation** (CG3.6) -- flag any method that both mutates state and returns a meaningful result.
- **Boy Scout Rule / TDD** (CG1, CG4) -- `CODING_GUIDELINES.md` explicitly says TDD doesn't apply to this project "unless you want to overdeliver," so missing tests are a note, not a violation, *unless* an existing tested/working file was modified without updating its test (that's what CG1 actually requires). Mention whether a mirrored `test/` path exists for the reviewed files, per `APP_ARCHITECTURE.md`'s stated convention, as an FYI either way.

## Always surface these three judgment calls explicitly when they come up

These aren't things to silently resolve one way -- they're real tensions between what the docs say and what the existing reference code (`daily_news`) actually does, and the developer needs to see them to decide/defend a position, not have this skill quietly pick a side for them:

1. **`equatable` inside the domain layer.** `ARCHITECTURE_VIOLATIONS.md` Sec. 2.1.1 says the Business Layer must not import anything "except dart libraries," yet `daily_news/domain/entities/article.dart` already imports `package:equatable/equatable.dart`. The script treats zero-dependency, pure-Dart value packages (`equatable`, `meta`) as accepted precedent rather than flagging them, because they add no Flutter/platform/IO surface and the existing reference code already does this. If a file in scope imports something *else* third-party inside `domain/`, that's a real violation; `equatable`/`meta` specifically are not -- but say so out loud each time it's relevant, so it doesn't read like an oversight.
2. **`fromRawData` vs. `fromJson`.** The written rule (`ARCHITECTURE_VIOLATIONS.md` Sec. 1.3.3) requires a `fromRawData` factory on models. The existing `daily_news/data/models/article.dart` uses `fromJson` instead -- the old code doesn't follow its own documented rule. For anything under review now, grade against the *written* rule, not the old precedent, and say explicitly that's what you're doing.
3. **`DataState<T>`'s coupling to `dio`'s `DioError`.** `ARCHITECTURE_VIOLATIONS.md` Sec. 1.4.3 requires repository methods that hit a backend to return `DataState<Type>` -- but `core/resources/data_state.dart` bakes in `DioError`, which doesn't naturally fit Firestore's own `FirebaseException`. Whatever the reviewed code does about this (translate errors into the existing shape, extend `DataState`, or something else) needs to be a deliberate, visible decision -- check whether it looks deliberate and consistent, don't require one specific answer.

## Report format

Organize by layer (data / domain / presentation). For every item:
- Mark it PASS or VIOLATION.
- A VIOLATION always names: file:line, a plain-language restatement of the rule, its exact citation, and a concrete fix.
- A PASS can be brief -- one line is enough, it's still useful signal, not just a violations list.

Combine the script's output with your own reading pass into **one** report -- don't present them as two separate halves. End with a short summary count (checks passed / violations found), and a distinct "Judgment calls" section whenever any of the three items above (or a new one you find) applies.

## A note on scope

This skill checks the rules that already exist in this repo's docs. It does not invent stricter rules, and it has no opinion on anything those docs don't mention (widget performance, animation smoothness, visual design). If something looks like a real problem but isn't backed by any of the three docs, mention it separately and label it clearly as "not a documented rule, just a suggestion" -- never blend it into the violations list as if it had a citation.
