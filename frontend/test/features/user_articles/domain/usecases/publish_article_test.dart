import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/publish_article.dart';

class _MockRepository extends Mock implements UserArticleRepository {}

const _validContent =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

PublishArticleParams _params({
  String id = 'a1',
  String authorId = 'u1',
  String authorName = 'Author',
  String title = 'Clean architecture notes',
  String description = 'desc',
  String content = _validContent,
  String thumbnailURL = 'https://cdn.test/thumb.jpg',
  List<String> tags = const <String>[],
}) {
  return PublishArticleParams(
    id: id,
    authorId: authorId,
    authorName: authorName,
    title: title,
    description: description,
    content: content,
    thumbnailURL: thumbnailURL,
    tags: tags,
  );
}

UserArticleEntity _stubEntity() {
  return UserArticleEntity(
    id: 'a1',
    authorId: 'u1',
    authorName: 'Author',
    title: 'Clean architecture notes',
    description: 'desc',
    content: _validContent,
    thumbnailURL: 'https://cdn.test/thumb.jpg',
    publishedAt: DateTime(2026, 4, 24),
    updatedAt: DateTime(2026, 4, 24),
    status: UserArticleStatus.published,
  );
}

void main() {
  late _MockRepository repository;
  late PublishArticleUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_params());
  });

  setUp(() {
    repository = _MockRepository();
    useCase = PublishArticleUseCase(repository);
  });

  group('PublishArticleUseCase validation', () {
    test('rejects empty authorId', () async {
      final result = await useCase(_params(authorId: ''));
      expect(result.isLeft(), isTrue);
      verifyNever(() => repository.publishArticle(any()));
    });

    test('rejects title shorter than 5 chars', () async {
      final result = await useCase(_params(title: 'hi'));
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(
          f,
          isA<ValidationFailure>().having((e) => e.field, 'field', 'title'),
        ),
        (_) => fail('expected Left'),
      );
    });

    test('rejects content shorter than 50 chars', () async {
      final result = await useCase(_params(content: 'short'));
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(
          f,
          isA<ValidationFailure>().having((e) => e.field, 'field', 'content'),
        ),
        (_) => fail('expected Left'),
      );
    });

    test('rejects empty thumbnailURL', () async {
      final result = await useCase(_params(thumbnailURL: ''));
      expect(result.isLeft(), isTrue);
    });

    test('rejects more than 5 tags', () async {
      final result = await useCase(
        _params(tags: const ['a', 'b', 'c', 'd', 'e', 'f']),
      );
      expect(result.isLeft(), isTrue);
    });
  });

  group('PublishArticleUseCase happy path', () {
    test('forwards to repository when payload is valid', () async {
      final entity = _stubEntity();
      when(() => repository.publishArticle(any()))
          .thenAnswer((_) async => Right(entity));

      final result = await useCase(_params());

      expect(result, Right<AppFailure, UserArticleEntity>(entity));
      verify(() => repository.publishArticle(any())).called(1);
    });
  });
}
