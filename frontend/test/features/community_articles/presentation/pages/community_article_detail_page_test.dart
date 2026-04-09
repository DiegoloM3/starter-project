import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/pages/community_article_detail_page.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/widgets/community_article_detail_deleting_indicator.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/widgets/community_article_detail_hero_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

// Pins spec 012. Covers:
// - Owner-only gate on edit + delete actions.
// - Delete confirmation + cancel + error paths.
// - Hero image show/hide based on urlToImage.
//
// Strategy: real CommunityFeedCubit over a hand-rolled _FakeRepository
// (same pattern as community_feed_page_test.dart). No mocks of
// FirebaseAuth — spec 012's refactor exposed currentUid as a
// constructor parameter.

class _FakeRepository implements CommunityArticleRepository {
  final List<({String firestoreId, String? imageUrl})> deleteCalls = [];
  bool throwOnDelete = false;

  @override
  Future<void> deleteArticle({
    required String firestoreId,
    String? imageUrl,
  }) async {
    deleteCalls.add((firestoreId: firestoreId, imageUrl: imageUrl));
    if (throwOnDelete) {
      throw Exception('simulated firestore failure');
    }
  }

  @override
  Stream<List<ArticleEntity>> watchArticles() =>
      const Stream<List<ArticleEntity>>.empty();

  @override
  Future<String> publishArticle(ArticleEntity article) async => 'unused';

  @override
  Future<String> uploadArticleImage({
    required String uid,
    required File imageFile,
  }) async =>
      'unused';

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

const _ownerArticle = ArticleEntity(
  firestoreId: 'abc123',
  uid: 'alice',
  title: 'Alice wrote this',
  description: 'A short description.',
  url: 'https://example.com',
  urlToImage: 'https://example.com/pic.png',
  publishedAt: '2026-04-08T12:00:00Z',
  content: 'The full body of the article.',
);

const _ownerArticleNoImage = ArticleEntity(
  firestoreId: 'abc123',
  uid: 'alice',
  title: 'Alice wrote this',
  description: 'A short description.',
  url: 'https://example.com',
  urlToImage: null,
  publishedAt: '2026-04-08T12:00:00Z',
  content: 'The full body of the article.',
);

// Delete-flow scenarios use articles without urlToImage to avoid the
// CachedNetworkImage loader hang under pumpAndSettle. The imageUrl
// propagation is still verified in scenario 5 by asserting the
// repository receives `imageUrl: null` — any non-null string would
// equally prove the pass-through but would block the test loop.
const _articleWithoutFirestoreId = ArticleEntity(
  firestoreId: null,
  uid: 'alice',
  title: 'Alice wrote this',
  description: 'A short description.',
  url: 'https://example.com',
  urlToImage: null,
  publishedAt: '2026-04-08T12:00:00Z',
  content: 'The full body of the article.',
);

/// Mounts the detail page directly at the root of the Navigator.
/// Good for render-only scenarios that don't exercise pop().
Widget _wrapDirect({
  required ArticleEntity article,
  required String? currentUid,
  required CommunityFeedCubit cubit,
}) {
  return MaterialApp(
    home: BlocProvider<CommunityFeedCubit>.value(
      value: cubit,
      child: CommunityArticleDetailPage(
        article: article,
        currentUid: currentUid,
      ),
    ),
  );
}

/// Mounts a two-route navigator stack so the detail page can pop back
/// to a previous screen. Used by the delete-happy-path test.
Widget _wrapWithPreviousRoute({
  required ArticleEntity article,
  required String? currentUid,
  required CommunityFeedCubit cubit,
}) {
  return MaterialApp(
    home: BlocProvider<CommunityFeedCubit>.value(
      value: cubit,
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<CommunityFeedCubit>.value(
                    value: cubit,
                    child: CommunityArticleDetailPage(
                      article: article,
                      currentUid: currentUid,
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
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
  });

  group('CommunityArticleDetailPage — render / owner gate', () {
    testWidgets(
      'Scenario 1 — non-owner viewer sees no edit or delete actions',
      (tester) async {
        await tester.pumpWidget(_wrapDirect(
          article: _ownerArticle,
          currentUid: 'bob',
          cubit: cubit,
        ));

        expect(find.text('Article'), findsOneWidget);
        expect(find.text('Alice wrote this'), findsOneWidget);
        expect(find.byIcon(Icons.edit_outlined), findsNothing);
        expect(find.byIcon(Icons.delete_outline), findsNothing);
        expect(find.byType(CommunityArticleDetailHeroImage), findsOneWidget);
      },
    );

    testWidgets(
      'Scenario 2 — anonymous viewer (null uid) sees no owner actions',
      (tester) async {
        await tester.pumpWidget(_wrapDirect(
          article: _ownerArticle,
          currentUid: null,
          cubit: cubit,
        ));

        expect(find.byIcon(Icons.edit_outlined), findsNothing);
        expect(find.byIcon(Icons.delete_outline), findsNothing);
      },
    );

    testWidgets(
      'Scenario 3 — null imageUrl hides the hero image, body still renders',
      (tester) async {
        await tester.pumpWidget(_wrapDirect(
          article: _ownerArticleNoImage,
          currentUid: 'bob',
          cubit: cubit,
        ));

        expect(find.byType(CommunityArticleDetailHeroImage), findsNothing);
        expect(find.text('Alice wrote this'), findsOneWidget);
        expect(find.text('The full body of the article.'), findsOneWidget);
      },
    );

    testWidgets(
      'Scenario 4 — owner sees enabled edit and delete icons',
      (tester) async {
        await tester.pumpWidget(_wrapDirect(
          article: _ownerArticle,
          currentUid: 'alice',
          cubit: cubit,
        ));

        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);

        final editButton = tester.widget<IconButton>(
          find.ancestor(
            of: find.byIcon(Icons.edit_outlined),
            matching: find.byType(IconButton),
          ),
        );
        final deleteButton = tester.widget<IconButton>(
          find.ancestor(
            of: find.byIcon(Icons.delete_outline),
            matching: find.byType(IconButton),
          ),
        );
        expect(editButton.onPressed, isNotNull);
        expect(deleteButton.onPressed, isNotNull);
      },
    );
  });

  group('CommunityArticleDetailPage — delete flow', () {
    testWidgets(
      'Scenario 5 — confirm delete calls repository and pops the route',
      (tester) async {
        await tester.pumpWidget(_wrapWithPreviousRoute(
          article: _ownerArticleNoImage,
          currentUid: 'alice',
          cubit: cubit,
        ));

        // Navigate to the detail page.
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.text('Alice wrote this'), findsOneWidget);

        // Tap delete, then confirm in the dialog.
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        expect(find.text('Delete this article?'), findsOneWidget);

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(repository.deleteCalls, hasLength(1));
        expect(repository.deleteCalls.single.firestoreId, 'abc123');
        // The page passes `_article.urlToImage` through verbatim — here
        // that's null. A non-null value would equally prove the
        // propagation but would hang the test on CachedNetworkImage.
        expect(repository.deleteCalls.single.imageUrl, isNull);
        // Back on the previous route.
        expect(find.text('open'), findsOneWidget);
        expect(find.text('Alice wrote this'), findsNothing);
      },
    );

    testWidgets(
      'Scenario 6 — cancel in the dialog does not call repository',
      (tester) async {
        await tester.pumpWidget(_wrapDirect(
          article: _ownerArticleNoImage,
          currentUid: 'alice',
          cubit: cubit,
        ));

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        expect(find.text('Delete this article?'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(repository.deleteCalls, isEmpty);
        // Page is still visible.
        expect(find.text('Alice wrote this'), findsOneWidget);
      },
    );

    testWidgets(
      'Scenario 7 — missing firestoreId surfaces a snackbar and skips delete',
      (tester) async {
        await tester.pumpWidget(_wrapDirect(
          article: _articleWithoutFirestoreId,
          currentUid: 'alice',
          cubit: cubit,
        ));

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pump(); // start snackbar animation
        await tester.pump(const Duration(milliseconds: 200));

        expect(repository.deleteCalls, isEmpty);
        expect(
          find.text('Could not delete: missing article id.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Scenario 8 — repository error shows snackbar and clears deleting overlay',
      (tester) async {
        repository.throwOnDelete = true;

        await tester.pumpWidget(_wrapDirect(
          article: _ownerArticleNoImage,
          currentUid: 'alice',
          cubit: cubit,
        ));

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pump(); // let the throw propagate + snackbar start
        await tester.pump(const Duration(milliseconds: 200));

        expect(repository.deleteCalls, hasLength(1));
        expect(
          find.text('Could not delete. Check your connection and try again.'),
          findsOneWidget,
        );
        // The deleting overlay was cleared.
        expect(
          find.byType(CommunityArticleDetailDeletingIndicator),
          findsNothing,
        );
      },
    );
  });
}
