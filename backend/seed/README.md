# Community demo seed

This directory contains two original, clearly labelled demonstration articles for the
Case Study Symmetry Community feed. The articles are fictional and their images are
illustrative; they must not be presented as real reporting.

## Safe execution

The default command is a local validation-only dry-run:

```bash
node backend/seed/seed-community.mjs
```

It validates article lengths, deterministic payload hashes, PNG signatures, file sizes,
and the 1.82:1 thumbnail ratio. It does not load Firebase Admin, contact Firebase, or
write anything. The CLI guard checks are run with:

```bash
sh backend/seed/test-cli.sh
```

Production seeding is explicit:

```bash
node backend/seed/seed-community.mjs --apply --project case-study-symmetry
```

Apply mode requires Firebase Admin Application Default Credentials for a principal that
can create Auth users, write the named Firestore database `articles`, and upload to
`case-study-symmetry.firebasestorage.app`. The script creates the synthetic
`symmetry-demo-editorial` Auth user without a password, uploads deterministic Storage
objects, and creates deterministic `articles/{id}` documents.

Apply mode is idempotent: it never deletes or updates existing article documents.
The compact manifest seeds two representative articles and does not delete previously
seeded demo articles that are no longer listed.

An existing document is skipped only when its owner UID and payload hash match the manifest;
a conflict stops the run. Storage objects are reused only when their payload hash and
MIME type match.

The script follows the app contract: `publishedAt`, `createdAt`, and `updatedAt`
are server timestamps; `url` is empty; `thumbnailPath`, `urlToImage`, and
`payloadHash` are linked exactly as the client publisher does.


## Dependency installation

`backend/package-lock.json` is tracked and synchronized with `backend/package.json`.
Use `npm ci` for a clean, reproducible install from either the repository root or this
directory:

```bash
npm ci --prefix backend
# or: cd backend && npm ci
```
