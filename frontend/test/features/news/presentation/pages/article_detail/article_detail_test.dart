import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_author_profile.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/get_article_comments.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/post_comment.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments/comments_bloc.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class _FakeGetSaved extends Fake implements GetSavedArticleUseCase {
  List<ArticleEntity> saved = const [];

  @override
  Future<List<ArticleEntity>> call({void params}) async => saved;
}

class _FakeSave extends Fake implements SaveArticleUseCase {
  final _FakeGetSaved getSaved;
  bool called = false;

  _FakeSave(this.getSaved);

  @override
  Future<void> call({ArticleEntity? params}) async {
    called = true;
    if (params != null) {
      getSaved.saved = [...getSaved.saved, params];
    }
  }
}

class _FakeRemove extends Fake implements RemoveArticleUseCase {
  final _FakeGetSaved getSaved;
  bool called = false;

  _FakeRemove(this.getSaved);

  @override
  Future<void> call({ArticleEntity? params}) async {
    called = true;
    if (params != null) {
      getSaved.saved = getSaved.saved
          .where((entry) => !entry.isSameArticle(params))
          .toList();
    }
  }
}

class _StubGetAuthorProfile extends Fake implements GetAuthorProfile {
  @override
  Future<DataState<UserProfileEntity?>> call(
      {GetAuthorProfileParams? params}) async {
    return const DataSuccess(null);
  }
}

class _StubGetArticleComments extends Fake implements GetArticleComments {
  @override
  Future<DataState<List<CommentEntity>>> call({
    GetArticleCommentsParams? params,
  }) async {
    return const DataSuccess([]);
  }
}

class _StubPostComment extends Fake implements PostComment {
  @override
  Future<DataState<void>> call({PostCommentParams? params}) async {
    return DataSuccess(null);
  }
}

class _StubDeleteComment extends Fake implements DeleteComment {
  @override
  Future<DataState<void>> call({DeleteCommentParams? params}) async {
    return DataSuccess(null);
  }
}

class _StubGetCurrentUser extends Fake implements GetCurrentUserUseCase {
  @override
  Future<DataState<UserEntity?>> call({void params}) async {
    return const DataSuccess(null);
  }
}

void main() {
  const tArticle = ArticleEntity(
    id: 'user-article-1',
    authorDisplayName: 'Camilo',
    title: 'Test de un articulo',
    urlToImage: 'https://example.com/thumb.png',
    publishedAt: '2026-09-27T12:11:50.732200',
    content: 'offline copy',
    authorId: 'author-123',
  );

  late _FakeGetSaved fakeGetSaved;
  late _FakeSave fakeSave;
  late _FakeRemove fakeRemove;

  Icon _bookmarkIcon(WidgetTester tester) {
    final fab = find.byType(FloatingActionButton);
    return tester.widget<Icon>(
      find.descendant(of: fab, matching: find.byType(Icon)),
    );
  }

  setUp(() {
    fakeGetSaved = _FakeGetSaved();
    fakeSave = _FakeSave(fakeGetSaved);
    fakeRemove = _FakeRemove(fakeGetSaved);
    sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(fakeGetSaved, fakeSave, fakeRemove),
    );
    sl.registerFactory<AuthorAvatarCubit>(
      () => AuthorAvatarCubit(_StubGetAuthorProfile()),
    );
    sl.registerFactory<CommentsBloc>(
      () => CommentsBloc(
        _StubGetArticleComments(),
        _StubPostComment(),
        _StubDeleteComment(),
        _StubGetCurrentUser(),
      ),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('save FAB carries a unique hero tag', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailsView(article: tArticle),
      ),
    );
    await tester.pump();

    final fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    // Must differ from NewsHomePage's 'newsHomeCreate' tag: duplicate hero
    // tags throw during route transitions.
    expect(fab.heroTag, 'articleDetailSave');
  });

  testWidgets('hero image bounds decode size for full-res uploads',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailsView(article: tArticle),
      ),
    );
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    // Image.network folds cacheWidth into a ResizeImage provider.
    final provider = image.image as ResizeImage;
    expect(provider.width, 1080);
  });

  testWidgets('tapping save reports success only after the write lands',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailsView(article: tArticle),
      ),
    );
    await tester.pump();

    expect(find.text('Article saved successfully.'), findsNothing);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump();

    expect(fakeSave.called, isTrue);
    expect(find.text('Article saved successfully.'), findsOneWidget);
  });

  testWidgets('bookmark is white when unsaved and black once saved',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailsView(article: tArticle),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(_bookmarkIcon(tester).color, Colors.white);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump();

    expect(_bookmarkIcon(tester).color, Colors.black);
  });

  testWidgets('renders markdown content as formatted text', (tester) async {
    const mdArticle = ArticleEntity(
      id: 'md-1',
      authorDisplayName: 'Camilo',
      title: 'Markdown test',
      urlToImage: null,
      publishedAt: '2026-09-27',
      content: '# Hello\n\n**bold** plain',
      authorId: null,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailsView(article: mdArticle),
      ),
    );
    await tester.pump();

    expect(find.byType(GptMarkdown), findsOneWidget);
    // Formatted output must not leak raw markdown markers.
    expect(find.textContaining('**', findRichText: true), findsNothing);
    expect(find.textContaining('#', findRichText: true), findsNothing);
    expect(find.textContaining('Hello', findRichText: true), findsWidgets);
    expect(find.textContaining('bold', findRichText: true), findsWidgets);
  });

  testWidgets('plain-text content still renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailsView(article: tArticle),
      ),
    );
    await tester.pump();

    expect(find.byType(GptMarkdown), findsOneWidget);
    expect(
      find.textContaining('offline copy', findRichText: true),
      findsWidgets,
    );
  });

  testWidgets('preview mode hides the save button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailsView(article: tArticle, hideSaveButton: true),
      ),
    );
    await tester.pump();

    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Test de un articulo'), findsOneWidget);
  });

  testWidgets('bookmark starts black for a saved article and tap removes it',
      (tester) async {
    fakeGetSaved.saved = const [tArticle];

    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailsView(article: tArticle),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(_bookmarkIcon(tester).color, Colors.black);
    expect(find.text('Article saved successfully.'), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump();

    expect(fakeRemove.called, isTrue);
    expect(fakeSave.called, isFalse);
    expect(_bookmarkIcon(tester).color, Colors.white);
    expect(find.text('Article removed.'), findsOneWidget);
  });

  testWidgets('shows the comments section with a login prompt for guests',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ArticleDetailsView(article: tArticle),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Comments (0)'), findsOneWidget);
    expect(find.text('Log in to join the discussion.'), findsOneWidget);
    // The floating bookmark button must not cover the login row: the
    // section reserves FAB clearance at its end.
    expect(find.byKey(const ValueKey('commentsFabClearance')), findsOneWidget);
  });
}
