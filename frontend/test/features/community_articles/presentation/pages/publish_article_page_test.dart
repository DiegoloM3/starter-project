import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/pages/publish_article_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

// Widget tests for PublishArticlePage. Pins the form-level behaviour that
// does NOT require Firebase Auth or the Image Picker plugin:
// - The "Publish" action is rendered.
// - All three text fields are rendered with the right labels.
// - The image picker entry point ("Add image (optional)") is rendered.
// - Validation errors block submission of an empty form.
//
// What is NOT covered here:
// - The actual submit path. It calls `FirebaseAuth.instance.currentUser?.uid`
//   directly, which makes it impossible to unit test without either
//   `firebase_auth_mocks` (an extra dependency) or a refactor to inject the
//   UID. Both are out of scope for IMP-001 and tracked in the spec
//   improvements backlog.
// - The image picker flow. It depends on the `image_picker` plugin which
//   needs platform-channel mocking — also out of scope here.

class _UnusedRepository implements CommunityArticleRepository {
  @override
  Stream<List<ArticleEntity>> watchArticles() => const Stream.empty();
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
      child: const PublishArticlePage(),
    ),
  );
}

void main() {
  late CommunityFeedCubit cubit;

  setUp(() {
    cubit = CommunityFeedCubit(_UnusedRepository());
  });

  tearDown(() async {
    await cubit.close();
  });

  group('PublishArticlePage', () {
    testWidgets('renders the three text fields and the image picker entry',
        (tester) async {
      await tester.pumpWidget(_wrap(cubit));

      expect(find.widgetWithText(TextFormField, 'Title'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Description'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Content'), findsOneWidget);
      expect(find.text('Add image (optional)'), findsOneWidget);
    });

    testWidgets('renders a Publish action in the AppBar', (tester) async {
      await tester.pumpWidget(_wrap(cubit));

      expect(find.widgetWithText(TextButton, 'Publish'), findsOneWidget);
    });

    testWidgets('shows inline validation errors when submitting an empty form',
        (tester) async {
      await tester.pumpWidget(_wrap(cubit));

      // Tap Publish without filling any field.
      await tester.tap(find.widgetWithText(TextButton, 'Publish'));
      await tester.pump();

      // Each required field renders its own error. We assert by text content.
      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Description is required'), findsOneWidget);
      expect(find.text('Content is required'), findsOneWidget);
    });

    testWidgets(
        'does not show validation errors when the form has not been submitted',
        (tester) async {
      await tester.pumpWidget(_wrap(cubit));

      // Just rendering the page should not show error text.
      expect(find.text('Title is required'), findsNothing);
      expect(find.text('Description is required'), findsNothing);
      expect(find.text('Content is required'), findsNothing);
    });
  });
}
