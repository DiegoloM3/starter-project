import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/screens/my_articles/my_articles_page.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class MockMyArticlesBloc
    extends MockBloc<MyArticlesEvent, MyArticlesState>
    implements MyArticlesBloc {}

JournalistArticleEntity _article(String id, String title) {
  return JournalistArticleEntity(
    id: id,
    title: title,
    description: 'Description for $title',
    content: 'Content for $title',
    urlToImage: 'https://example.com/$id.jpg',
    publishedAt: DateTime(2026, 1, 1),
    userId: 'user-1',
    userDisplayName: 'Author',
    source: 'journalist',
    category: ArticleCategory.news,
    tags: const [],
    language: 'en',
    readingTimeMinutes: 1,
    status: ArticleStatus.published,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    viewCount: 0,
    favoriteCount: 0,
  );
}

DraftArticleEntity _draft(int id, String title) {
  return DraftArticleEntity(
    id: id,
    title: title,
    description: 'Draft description',
    content: 'Draft content',
    tags: const [],
    language: 'en',
    lastSavedAt: DateTime(2026, 1, 1),
  );
}

Widget _buildPage(MyArticlesBloc bloc) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<MyArticlesBloc>.value(
      value: bloc,
      child: const MyArticlesPage(userId: 'user-1'),
    ),
  );
}

void main() {
  late MockMyArticlesBloc bloc;

  setUpAll(() {
    registerFallbackValue(const LoadMyArticlesEvent('user-1'));
    registerFallbackValue(const DeleteArticleRequestedEvent('article-id'));
    registerFallbackValue(const LoadDraftsEvent());
    registerFallbackValue(const DeleteDraftRequestedEvent(0));
  });

  setUp(() {
    bloc = MockMyArticlesBloc();
    when(() => bloc.state).thenReturn(const MyArticlesState());
  });

  tearDown(() => bloc.close());

  group('MyArticlesPage', () {
    testWidgets('shows empty state message when both lists are empty',
        (tester) async {
      when(() => bloc.state)
          .thenReturn(const MyArticlesState(articles: [], drafts: []));

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.textContaining('No articles yet'), findsOneWidget);
    });

    testWidgets('renders two tiles when state has two articles', (tester) async {
      when(() => bloc.state).thenReturn(MyArticlesState(
        articles: [_article('a1', 'Article One'), _article('a2', 'Article Two')],
      ));

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.text('Article One'), findsOneWidget);
      expect(find.text('Article Two'), findsOneWidget);
    });

    testWidgets('tapping delete then confirming dispatches DeleteArticleRequestedEvent',
        (tester) async {
      when(() => bloc.state).thenReturn(MyArticlesState(
        articles: [_article('a1', 'Article One')],
      ));

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      expect(find.text('Delete article?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pump();

      verify(() =>
          bloc.add(const DeleteArticleRequestedEvent('a1'))).called(1);
    });

    testWidgets('Drafts section renders with Draft badge when drafts present',
        (tester) async {
      when(() => bloc.state).thenReturn(MyArticlesState(
        drafts: [_draft(1, 'My Draft Title')],
      ));

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.text('Drafts'), findsOneWidget);
      expect(find.text('My Draft Title'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
    });

    testWidgets('Empty state shows when both lists are empty', (tester) async {
      when(() => bloc.state)
          .thenReturn(const MyArticlesState(articles: [], drafts: []));

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.textContaining('No articles yet'), findsOneWidget);
    });
  });
}
