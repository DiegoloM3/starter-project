import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/pages/community_feed_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

// Widget tests for CommunityFeedPage. Pins:
// - Loading state shows a spinner.
// - Empty state shows the "Be the first" CTA copy.
// - Loaded state renders one card per article with title and description.
// - Error state shows the error message.

class _FakeRepository implements CommunityArticleRepository {
  final StreamController<List<ArticleEntity>> _controller =
      StreamController<List<ArticleEntity>>.broadcast();

  void emit(List<ArticleEntity> articles) => _controller.add(articles);
  void emitError(Object error) => _controller.addError(error);

  Future<void> dispose() => _controller.close();

  @override
  Stream<List<ArticleEntity>> watchArticles() => _controller.stream;

  @override
  Future<String> publishArticle(ArticleEntity article) async => 'unused';

  @override
  Future<String> uploadArticleImage({
    required String uid,
    required File imageFile,
  }) async =>
      'unused';

  @override
  Future<void> deleteArticle({
    required String firestoreId,
    String? imageUrl,
  }) async {}

  @override
  Future<void> updateArticle({
    required String firestoreId,
    required String title,
    required String description,
    required String content,
    String? imageUrl,
    String? oldImageUrl,
  }) async {}
}

Widget _wrap(CommunityFeedCubit cubit) {
  return MaterialApp(
    home: BlocProvider<CommunityFeedCubit>.value(
      value: cubit,
      child: const Scaffold(body: CommunityFeedPage()),
    ),
  );
}

void main() {
  late _FakeRepository repository;
  late CommunityFeedCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    cubit = CommunityFeedCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  group('CommunityFeedPage', () {
    testWidgets('shows a loading spinner before the stream emits',
        (tester) async {
      // Don't call cubit.start() — initial state is Loading.
      await tester.pumpWidget(_wrap(cubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('Be the first'), findsNothing);
    });

    testWidgets('shows the empty-state CTA when the stream emits an empty list',
        (tester) async {
      cubit.start();
      await tester.pumpWidget(_wrap(cubit));
      repository.emit(const []);
      await tester.pump();

      expect(
        find.text('Be the first to publish — tap the + button below.'),
        findsOneWidget,
      );
    });

    testWidgets('renders one card per article with title and description',
        (tester) async {
      const articles = [
        ArticleEntity(
          firestoreId: 'a',
          uid: 'u',
          title: 'First',
          description: 'first description',
        ),
        ArticleEntity(
          firestoreId: 'b',
          uid: 'u',
          title: 'Second',
          description: 'second description',
        ),
      ];

      cubit.start();
      await tester.pumpWidget(_wrap(cubit));
      repository.emit(articles);
      await tester.pump();

      expect(find.text('First'), findsOneWidget);
      expect(find.text('first description'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('second description'), findsOneWidget);
    });

    testWidgets('shows the error message when the stream errors',
        (tester) async {
      cubit.start();
      await tester.pumpWidget(_wrap(cubit));
      repository.emitError(Exception('boom'));
      await tester.pump();

      expect(find.textContaining('Could not load community articles'),
          findsOneWidget);
      expect(find.textContaining('boom'), findsOneWidget);
    });
  });
}
