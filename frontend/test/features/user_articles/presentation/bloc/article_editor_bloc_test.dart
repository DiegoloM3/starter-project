import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/session/auth_session.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_thumbnail_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/publish_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/upload_thumbnail.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_editor/article_editor_bloc.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_editor/article_editor_event.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_editor/article_editor_state.dart';

class _MockPublish extends Mock implements PublishArticleUseCase {}

class _MockUpdate extends Mock implements UpdateArticleUseCase {}

class _MockUpload extends Mock implements UploadThumbnailUseCase {}

UserArticleEntity _savedArticle() {
  return UserArticleEntity(
    id: 'new_1',
    authorId: 'u1',
    authorName: 'Author',
    title: 'Hello world',
    description: 'desc',
    content: 'c' * 60,
    thumbnailURL: 'https://cdn.test/x.jpg',
    publishedAt: DateTime(2026, 4, 24),
    updatedAt: DateTime(2026, 4, 24),
  );
}

void main() {
  late _MockPublish publish;
  late _MockUpdate update;
  late _MockUpload upload;
  const auth = DevAuthSession(user: AuthUser(id: 'u1', name: 'Author'));

  setUpAll(() {
    registerFallbackValue(
      const PublishArticleParams(
        id: 'a1',
        authorId: 'u1',
        authorName: 'Author',
        title: 't',
        description: '',
        content: 'c',
        thumbnailURL: 'https://x',
      ),
    );
    registerFallbackValue(
      const UpdateArticleParams(
        id: 'id',
        title: 't',
        description: '',
        content: 'c',
        thumbnailURL: 'https://x',
      ),
    );
    registerFallbackValue(
      const UploadThumbnailParams(
        authorId: 'u1',
        articleId: 'a1',
        fileName: 'f.png',
        bytes: [1],
        contentType: 'image/png',
      ),
    );
  });

  setUp(() {
    publish = _MockPublish();
    update = _MockUpdate();
    upload = _MockUpload();
  });

  ArticleEditorBloc build({UserArticleEntity? editing}) => ArticleEditorBloc(
        publishArticle: publish,
        updateArticle: update,
        uploadThumbnail: upload,
        authSession: auth,
        editing: editing,
      );

  test('canSubmit is false on initial empty state', () {
    expect(build().state.canSubmit, isFalse);
  });

  test('fromArticle seeds editing mode', () {
    final bloc = build(editing: _savedArticle());
    expect(bloc.state.isEditing, isTrue);
    expect(bloc.state.editingId, 'new_1');
    expect(bloc.state.canSubmit, isTrue);
    bloc.close();
  });

  blocTest<ArticleEditorBloc, ArticleEditorState>(
    'submitted publishes and emits success when form is valid',
    setUp: () {
      when(() => upload(any())).thenAnswer(
        (_) async => const Right<AppFailure, String>('https://cdn.test/x.jpg'),
      );
      when(() => publish(any())).thenAnswer(
        (_) async => Right<AppFailure, UserArticleEntity>(_savedArticle()),
      );
    },
    build: build,
    act: (bloc) {
      bloc
        ..add(const ArticleEditorEvent.titleChanged('Hello world'))
        ..add(
          const ArticleEditorEvent.contentChanged(
            'this is the long content that passes the 50 char rule aaa',
          ),
        )
        ..add(
          const ArticleEditorEvent.thumbnailPicked(
            fileName: 'pic.png',
            bytes: [1, 2, 3],
            contentType: 'image/png',
          ),
        )
        ..add(const ArticleEditorEvent.submitted());
    },
    verify: (_) {
      verify(() => publish(any())).called(1);
    },
    skip: 3,
    expect: () => [
      isA<ArticleEditorState>()
          .having((s) => s.status, 'status', EditorStatus.submitting),
      isA<ArticleEditorState>()
          .having((s) => s.status, 'status', EditorStatus.success),
    ],
  );

  blocTest<ArticleEditorBloc, ArticleEditorState>(
    'submit emits failure when publish use case returns Left',
    setUp: () {
      when(() => upload(any())).thenAnswer(
        (_) async => const Right<AppFailure, String>('https://cdn.test/x.jpg'),
      );
      when(() => publish(any())).thenAnswer(
        (_) async => const Left<AppFailure, UserArticleEntity>(
          AppFailure.network(message: 'offline'),
        ),
      );
    },
    build: build,
    act: (bloc) {
      bloc
        ..add(const ArticleEditorEvent.titleChanged('Hello world'))
        ..add(
          const ArticleEditorEvent.contentChanged(
            'this is the long content that passes the 50 char rule aaa',
          ),
        )
        ..add(
          const ArticleEditorEvent.thumbnailPicked(
            fileName: 'pic.png',
            bytes: [1, 2, 3],
            contentType: 'image/png',
          ),
        )
        ..add(const ArticleEditorEvent.submitted());
    },
    skip: 3,
    expect: () => [
      isA<ArticleEditorState>()
          .having((s) => s.status, 'status', EditorStatus.submitting),
      isA<ArticleEditorState>()
          .having((s) => s.status, 'status', EditorStatus.failure)
          .having((s) => s.failure, 'failure', isA<NetworkFailure>()),
    ],
  );
}
