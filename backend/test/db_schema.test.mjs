// docs/DB_SCHEMA.md is the contract of the database. These tests read it next to firestore.rules, storage.rules
// and the limits the app checks before writing (frontend/lib/features/*/domain/entities), and fail when they
// say different things, so a change in one place cannot leave the others behind.
// They only read files: they need no emulator (npm run test:schema).
import { readFileSync } from 'node:fs';
import { describe, test } from 'node:test';
import assert from 'node:assert/strict';

const schema = readFileSync('docs/DB_SCHEMA.md', 'utf8');
const firestoreRules = readFileSync('firestore.rules', 'utf8');
const storageRules = readFileSync('storage.rules', 'utf8');
const appEntity = (path) => readFileSync(`../frontend/lib/features/${path}`, 'utf8');

/// The fields table under a heading of DB_SCHEMA.md: { field: { type, constraints } }.
function documentedFields(heading) {
  const section = schema.split(heading)[1];
  assert.ok(section, `DB_SCHEMA.md has no "${heading}" section`);
  const fields = {};
  for (const line of section.split('\n### ')[0].split('\n')) {
    const cells = line.split('|').map((cell) => cell.trim());
    const field = cells[1]?.match(/^`(\w+)`$/)?.[1];
    if (field) fields[field] = { type: cells[2].replaceAll('`', ''), constraints: cells[4] };
  }
  return fields;
}

const maxLengthIn = (constraints) => {
  const limit = constraints.match(/Up to ([\d ]+) characters/)?.[1];
  return limit === undefined ? undefined : Number(limit.replaceAll(' ', ''));
};

/// The field names of a rules function: `let fields = [...]` or `keys().hasOnly([...])`.
function ruleFields(functionName) {
  const body = firestoreRules.split(`function ${functionName}(`)[1]?.split('\n    }')[0];
  assert.ok(body, `firestore.rules has no ${functionName} function`);
  const list = body.match(/let fields = \[([^\]]+)\]/)?.[1] ?? body.match(/hasOnly\(\[([^\]]+)\]\)/)?.[1];
  return list.split(',').map((field) => field.trim().replaceAll("'", ''));
}

/// { 'article.title': 150, ... } from every isNonBlankStringUpTo(variable.field, max) call.
const ruleMaxLengths = Object.fromEntries(
  [...firestoreRules.matchAll(/isNonBlankStringUpTo\((\w+)\.(\w+), (\d+)\)/g)].map(([, variable, field, max]) => [`${variable}.${field}`, Number(max)]),
);

/// The thumbnails of the articles (### Folder `media/articles`).
const thumbnailRow = schema.split('\n').find((line) => line.includes('`media/articles/{articleId}.{extension}`') && line.includes('max'));
const documentedExtensions = thumbnailRow.match(/Extension (.+?);/)[1].match(/`(\w+)`/g).map((extension) => extension.replaceAll('`', ''));
const documentedContentTypes = thumbnailRow.match(/content type (.+?);/)[1].match(/`image\/(\w+)`/g).map((type) => type.slice(7, -1));
const documentedMaxMegabytes = Number(thumbnailRow.match(/max (\d+) MB/)[1]);

const collections = [
  { heading: '### Collection `articles`', rulesFunction: 'hasExactlyArticleFields', variable: 'article' },
  { heading: '### Subcollection `articles/{articleId}/comments`', rulesFunction: 'isValidComment', variable: 'comment' },
  { heading: '### Subcollection `users/{userId}/savedArticles`', rulesFunction: 'isValidSavedArticle', variable: 'savedArticle' },
];

describe('DB_SCHEMA.md and firestore.rules', () => {
  for (const { heading, rulesFunction, variable } of collections) {
    const fields = documentedFields(heading);

    test(`${heading.replace(/^#+ /, '')}: the rules allow exactly the documented fields`, () => {
      assert.deepEqual(ruleFields(rulesFunction).sort(), Object.keys(fields).sort());
    });

    test(`${heading.replace(/^#+ /, '')}: the rules enforce the documented length limits`, () => {
      for (const [field, { constraints }] of Object.entries(fields)) {
        const documented = maxLengthIn(constraints);
        if (documented === undefined) continue;
        // The author of articles and comments is checked once, in isWrittenByTheSignedInUser(document).
        const enforced = ruleMaxLengths[`${variable}.${field}`] ?? ruleMaxLengths[`document.${field}`];
        assert.equal(enforced, documented, `${variable}.${field}`);
      }
    });

    test(`${heading.replace(/^#+ /, '')}: the timestamps the server sets are checked against request.time`, () => {
      const serverTimestamps = Object.entries(fields)
        .filter(([, { type, constraints }]) => type === 'timestamp' && constraints.includes('request.time'))
        .map(([field]) => field);
      for (const field of serverTimestamps) {
        assert.match(firestoreRules, new RegExp(`${variable}\\.${field} == request\\.time`), `${variable}.${field}`);
      }
    });
  }

  test('the author of articles and comments is the signed-in account, as documented', () => {
    for (const { heading } of collections.slice(0, 2)) {
      const fields = documentedFields(heading);
      assert.match(fields.author.constraints, /request\.auth\.token\.name/);
      assert.match(fields.authorId.constraints, /request\.auth\.uid/);
    }
    assert.match(firestoreRules, /document\.authorId == request\.auth\.uid/);
    assert.match(firestoreRules, /document\.author == request\.auth\.token\.name/);
  });
});

describe('DB_SCHEMA.md and storage.rules', () => {
  test('thumbnails have the documented extensions', () => {
    const enforced = storageRules.match(/fileName\.matches\('\[A-Za-z0-9\]\+\\\\\.\(([\w|]+)\)'\)/)[1].split('|');
    assert.deepEqual(enforced.sort(), [...documentedExtensions].sort());
  });

  test('thumbnails have the documented content types', () => {
    const enforced = storageRules.match(/contentType\.matches\('image\/\(([\w|]+)\)'\)/)[1].split('|');
    assert.deepEqual(enforced.sort(), [...documentedContentTypes].sort());
  });

  test('thumbnails weigh at most the documented size', () => {
    assert.match(storageRules, new RegExp(`file\\.size <= ${documentedMaxMegabytes} \\* 1024 \\* 1024`));
  });

  test('a thumbnail URL of an article points to an image with the documented extensions', () => {
    const enforced = firestoreRules.match(/articleId \+ '\\\\\.\(([\w|]+)\)'/)[1].split('|');
    assert.deepEqual(enforced.sort(), [...documentedExtensions].sort());
  });
});

describe('DB_SCHEMA.md and the limits the app checks before writing', () => {
  const constant = (source, name) => source.match(new RegExp(`static const (?:int|List<String>) ${name} = (.+);`))[1];
  const articles = documentedFields(collections[0].heading);
  const comments = documentedFields(collections[1].heading);

  test('the article draft has the documented length limits', () => {
    const draft = appEntity('journalist_articles/domain/entities/article_draft.dart');
    assert.equal(Number(constant(draft, 'maxTitleLength')), maxLengthIn(articles.title.constraints));
    assert.equal(Number(constant(draft, 'maxDescriptionLength')), maxLengthIn(articles.description.constraints));
    assert.equal(Number(constant(draft, 'maxContentLength')), maxLengthIn(articles.content.constraints));
  });

  test('the comment draft has the documented length limit', () => {
    const draft = appEntity('journalist_articles/domain/entities/article_comment_draft.dart');
    assert.equal(Number(constant(draft, 'maxContentLength')), maxLengthIn(comments.content.constraints));
  });

  test('the name of an account, which signs articles and comments, has the documented author limit', () => {
    const rules = appEntity('auth/domain/entities/credentials_rules.dart');
    assert.equal(Number(constant(rules, 'maxNameLength')), maxLengthIn(articles.author.constraints));
    assert.equal(Number(constant(rules, 'maxNameLength')), maxLengthIn(comments.author.constraints));
  });

  test('the thumbnail has the documented extensions and size', () => {
    const thumbnail = appEntity('journalist_articles/domain/entities/article_thumbnail.dart');
    const extensions = constant(thumbnail, 'allowedExtensions').match(/'(\w+)'/g).map((extension) => extension.replaceAll("'", ''));
    assert.deepEqual(extensions.sort(), [...documentedExtensions].sort());
    assert.equal(constant(thumbnail, 'maxSizeInBytes'), `${documentedMaxMegabytes} * 1024 * 1024`);
  });
});
