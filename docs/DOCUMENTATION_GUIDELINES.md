# Documentation Guidelines

> Every document in this project must follow these rules. No exceptions.
> AI-generated docs are held to the same standard as human-written docs.

---

## 1. Content Types (Diátaxis Framework)

Every document must be **one** of these four types. Do not mix them.

| Type | Purpose | Question it answers | Example in this project |
|------|---------|--------------------|-----------------------|
| **Tutorial** | Learning-oriented | "How do I get started?" | `START_HERE.md` |
| **How-to** | Task-oriented | "How do I do X?" | `docs/ADR/*.md` |
| **Reference** | Information-oriented | "What are the fields/rules?" | `backend/docs/DB_SCHEMA.md` |
| **Explanation** | Understanding-oriented | "Why was this decision made?" | `docs/REPORT.md` |

> [!TIP]
> If you're unsure which type a doc is, ask: "Is the reader trying to *learn*, *do*, *look up*, or *understand*?" That's your type.

---

## 2. Structure

### Inverted Pyramid

Start every document with the conclusion. Then add supporting detail.

```
✅ Good:
"This project uses Firebase Storage for image uploads.
Here's why, and here's how to configure it."

❌ Bad:
"In the beginning, we evaluated several options for image storage.
After careful consideration of pros and cons... [400 words later]
...we chose Firebase Storage."
```

### Heading Rules

- **One `# H1` per file** — the document title.
- **Unique, descriptive subheadings** — a reader scanning headings alone should understand the document's structure.
- **No skip levels** — don't jump from `##` to `####`.

### Modularization

- One topic per document. If a file exceeds **200 lines**, split it.
- Link related docs rather than duplicating content.
- Every `docs/` directory must have a clear scope. Don't use `docs/` as a junk drawer.

---

## 3. Writing Style

### Plain Language

- Use common words. Replace jargon with plain alternatives when possible.
- Developer-specific terms (BLoC, Firestore, DI) are fine — don't dumb down technical content.
- **Active voice always.** "The BLoC emits a new state" not "A new state is emitted by the BLoC."

### Conciseness

- One idea per sentence.
- One idea per paragraph.
- Remove words that don't add meaning. If a sentence works without a word, delete it.
- **Target: ≤300 lines per document.** Anything longer should be split or trimmed.

### Tone

- Direct and professional. Not casual, not academic.
- Honest. If something doesn't work, say so. See `docs/improvements.md`.
- No filler phrases: "It should be noted that...", "It is important to mention...", "As previously discussed..."

---

## 4. Formatting for Scannability

### Text Highlighting

- **Bold ≤ 10% of total text.** If everything is bold, nothing is bold.
- Use bold for key terms on first use, critical warnings, and action items.
- Never bold entire sentences or paragraphs.

### Lists

- Use bulleted lists for unordered items.
- Use numbered lists only for sequential steps.
- Keep list items parallel in structure (all start with verbs, or all are noun phrases).

### Code Blocks

- Always specify the language: ` ```dart `, ` ```bash `, ` ```yaml `.
- Annotate non-obvious code with inline comments.
- Keep code blocks short (< 30 lines). For longer code, link to the source file.

### Alerts (GitHub-style)

Use sparingly — max 2 per document:

```markdown
> [!NOTE]
> Background context or helpful explanation.

> [!WARNING]
> Something that could break or cause problems.

> [!CAUTION]
> High-risk action. Data loss or security implications.
```

### Tables

Use tables for structured comparisons. Don't use tables for prose.

---

## 5. File Conventions

### Naming

| Pattern | Use for | Example |
|---------|---------|---------|
| `UPPER_CASE.md` | Root-level project docs | `START_HERE.md`, `AGENTS.md` |
| `lower_case.md` | Inside `docs/` or `specs/` | `improvements.md`, `spec.md` |
| `NNN-slug/` | Spec directories | `specs/003-auth/` |

### Required metadata

Spec files must include YAML frontmatter:

```yaml
---
id: 003-auth
title: "Firebase Authentication"
status: draft | review | accepted | implemented | deprecated
version: 1.0.0
---
```

All other docs: no frontmatter required unless using a static site generator.

### Links

- Use **relative paths** for internal links: `[DB Schema](../backend/docs/DB_SCHEMA.md)`
- Link to specific files, not directories.
- Avoid bare URLs in prose — always use `[descriptive text](url)`.

---

## 6. Maintenance

### Docs-as-Code

- Documentation updates are part of the PR, not an afterthought.
- If a feature changes behavior, the doc must be updated in the same commit.
- Stale docs are worse than no docs — they actively mislead.

### Review Checklist

Before merging any documentation:

- [ ] Correct content type (tutorial / how-to / reference / explanation)?
- [ ] Starts with the conclusion (inverted pyramid)?
- [ ] One H1, no skipped heading levels?
- [ ] Under 300 lines?
- [ ] Bold ≤ 10% of text?
- [ ] Code blocks have language specified?
- [ ] No broken internal links?
- [ ] Active voice throughout?
- [ ] No filler phrases?

---

## 7. Assets

- **Images:** Compress before committing. Use PNG for screenshots, SVG for diagrams.
- **Large files (>5MB):** Use Git LFS or link to external storage.
- **Diagrams:** Prefer Mermaid in markdown (renders natively on GitHub) over binary image files.

---

## References

- [Diátaxis Framework](https://diataxis.fr/)
- [GitHub Docs Best Practices](https://docs.github.com/en/contributing/writing-for-github-docs/best-practices-for-github-docs)
- [Readability Guidelines — Content Design London](https://readabilityguidelines.co.uk/)
