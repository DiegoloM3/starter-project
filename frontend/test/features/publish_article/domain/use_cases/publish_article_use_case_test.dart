import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/publishable_article.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_result.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_use_case.dart';

import '../../support/fake_publish_article_repository.dart';

PublishArticleParams input({
  Map<PublishArticleField, String> text = const {},
  String fileName = 'thumbnail.jpg',
  String mimeType = 'image/jpeg',
  List<int> bytes = const [1, 2, 3],
}) {
  return PublishArticleParams(
    author: text[PublishArticleField.author] ?? 'Jane Doe',
    title: text[PublishArticleField.title] ?? 'Article title',
    description: text[PublishArticleField.description] ?? 'Article summary',
    content: text[PublishArticleField.content] ?? 'Article content',
    thumbnail: ArticleThumbnail(
      fileName: fileName,
      mimeType: mimeType,
      bytes: bytes,
    ),
  );
}

void expectFailure(
  PublishArticleResult result,
  PublishArticleField field,
  String message,
) {
  expect(result.article, isNull);
  expect(result.errors, hasLength(1));
  expect(result.errors.single.field, field);
  expect(result.errors.single.message, message);
}

void main() {
  late PublishArticleUseCase useCase;
  late FakePublishArticleRepository repository;

  setUp(() {
    repository = FakePublishArticleRepository();
    useCase = PublishArticleUseCase(repository);
  });

  test('calls repository once with normalized data without changing input',
      () async {
    final original = input(
      text: {
        PublishArticleField.author: '  Jane Doe  ',
        PublishArticleField.title: '\tArticle title\n',
        PublishArticleField.description: ' Article summary ',
        PublishArticleField.content: '\nArticle content\n',
      },
      fileName: ' thumbnail image.jpg ',
    );
    final result = await useCase(params: original);
    expect(result.errors, isEmpty);
    expect(repository.calls, hasLength(1));
    final received = repository.calls.single;
    expect(received.author, 'Jane Doe');
    expect(received.title, 'Article title');
    expect(received.description, 'Article summary');
    expect(received.content, 'Article content');
    expect(received.thumbnail.fileName, 'thumbnail image.jpg');
    expect(received.thumbnail.mimeType, original.thumbnail.mimeType);
    expect(received.thumbnail.bytes, original.thumbnail.bytes);
    expect(original.author, '  Jane Doe  ');
    expect(original.title, '\tArticle title\n');
    expect(original.description, ' Article summary ');
    expect(original.content, '\nArticle content\n');
    expect(original.thumbnail.fileName, ' thumbnail image.jpg ');
  });

  const limits = {
    PublishArticleField.author: 100,
    PublishArticleField.title: 200,
    PublishArticleField.description: 500,
    PublishArticleField.content: 50000,
  };
  for (final entry in limits.entries) {
    for (final value in ['', '   ']) {
      test('${entry.key} rejects ${value.isEmpty ? 'empty' : 'spaces'}',
          () async {
        final result = await useCase(params: input(text: {entry.key: value}));
        expectFailure(result, entry.key, 'Required.');
        expect(repository.calls, isEmpty);
      });
    }
    test('${entry.key} accepts exactly its maximum after trim', () async {
      final value = List.filled(entry.value, 'a').join();
      final result =
          await useCase(params: input(text: {entry.key: ' $value '}));
      expect(result.article, isNotNull);
      expect(result.errors, isEmpty);
    });
    test('${entry.key} rejects maximum plus one', () async {
      final value = List.filled(entry.value + 1, 'a').join();
      final result = await useCase(params: input(text: {entry.key: value}));
      expectFailure(
          result, entry.key, 'Must not exceed ${entry.value} characters.');
      expect(repository.calls, isEmpty);
    });
  }

  for (final mime in ['image/jpeg', 'image/png', 'image/webp']) {
    test('accepts $mime', () async {
      final result = await useCase(params: input(mimeType: mime));
      expect(result.article, isNotNull);
      expect(result.errors, isEmpty);
    });
  }
  for (final mime in ['image/gif', 'IMAGE/JPEG', ' image/png ', '']) {
    test('rejects unsupported or non-exact MIME "$mime"', () async {
      final result = await useCase(params: input(mimeType: mime));
      expectFailure(result, PublishArticleField.thumbnailMimeType,
          'Use JPEG, PNG or WebP.');
      expect(repository.calls, isEmpty);
    });
  }
  for (final name in ['', '   ']) {
    test('rejects ${name.isEmpty ? 'empty' : 'blank'} file name', () async {
      final result = await useCase(params: input(fileName: name));
      expectFailure(result, PublishArticleField.thumbnailFileName,
          'File name is required.');
      expect(repository.calls, isEmpty);
    });
  }
  test('rejects empty bytes', () async {
    final result = await useCase(params: input(bytes: []));
    expectFailure(result, PublishArticleField.thumbnailBytes,
        'Image bytes are required.');
    expect(repository.calls, isEmpty);
  });
  test('accepts exactly 5 MiB', () async {
    final result =
        await useCase(params: input(bytes: List.filled(5 * 1024 * 1024, 0)));
    expect(result.article, isNotNull);
    expect(result.errors, isEmpty);
  });
  test('rejects 5 MiB plus one byte', () async {
    final result = await useCase(
        params: input(bytes: List.filled(5 * 1024 * 1024 + 1, 0)));
    expectFailure(result, PublishArticleField.thumbnailBytes,
        'Image must not exceed 5 MiB.');
    expect(repository.calls, isEmpty);
  });
  test('accumulates all invalid fields without generating an article',
      () async {
    final result = await useCase(
        params: input(
      text: {for (final field in limits.keys) field: ' '},
      fileName: ' ',
      mimeType: 'image/gif',
      bytes: [],
    ));
    expect(result.article, isNull);
    expect(
        result.errors.map((error) => error.field), PublishArticleField.values);
    expect(repository.calls, isEmpty);
  });
  test('missing params produces ArgumentError', () async {
    await expectLater(useCase(), throwsArgumentError);
    expect(repository.calls, isEmpty);
  });
  test('explicit null params produces ArgumentError', () async {
    await expectLater(useCase(params: null), throwsArgumentError);
    expect(repository.calls, isEmpty);
  });
  test('waits for and returns the exact repository entity', () async {
    final pending = Completer<PublishableArticle>();
    repository = FakePublishArticleRepository(handler: (_) => pending.future);
    useCase = PublishArticleUseCase(repository);
    var completed = false;
    final operation = useCase(params: input()).then((result) {
      completed = true;
      return result;
    });
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);
    expect(repository.calls, hasLength(1));
    final article = PublishableArticle(
      id: 'repository-id',
      author: 'Repository author',
      title: 'Repository title',
      description: 'Repository description',
      content: 'Repository content',
      thumbnailUrl: 'https://example.com/repository-image.png',
      publishedAt: DateTime.utc(2020),
      createdAt: DateTime.utc(2021),
      updatedAt: DateTime.utc(2022),
    );
    pending.complete(article);
    final result = await operation;
    expect(result.article, same(article));
    expect(result.errors, isEmpty);
    expect(repository.calls, hasLength(1));
  });
  test('propagates repository errors without retrying', () async {
    final error = StateError('Repository unavailable');
    repository =
        FakePublishArticleRepository(handler: (_) async => throw error);
    useCase = PublishArticleUseCase(repository);
    await expectLater(useCase(params: input()), throwsA(same(error)));
    expect(repository.calls, hasLength(1));
  });
}
