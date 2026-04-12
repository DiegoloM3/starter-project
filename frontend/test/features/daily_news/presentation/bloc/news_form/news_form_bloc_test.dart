import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/error_type.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_state.dart';
import 'package:news_app_clean_architecture/core/resources/image_item.dart';

import '../../../fakes/fake_draft_service.dart';
import '../../../fakes/fake_firestore_article_repository.dart';

NewsFormBloc createBloc({
  FakeFirestoreArticleRepository? repo,
  FakeDraftService? draftService,
  ArticleEntity? existingArticle,
  NewsSection? existingSection,
}) {
  final repository = repo ?? FakeFirestoreArticleRepository();
  return NewsFormBloc(
    createArticleUseCase: CreateArticleUseCase(repository),
    updateArticleUseCase: UpdateArticleUseCase(repository),
    deleteArticleUseCase: DeleteArticleUseCase(repository),
    draftService: draftService ?? FakeDraftService(),
    authorName: 'Test Author',
    existingArticle: existingArticle,
    existingSection: existingSection,
  );
}

void main() {
  group('NewsFormBloc', () {
    late NewsFormBloc bloc;

    setUp(() {
      bloc = createBloc();
    });

    tearDown(() {
      bloc.close();
    });

    group('initial state', () {
      test('starts with empty create mode state', () {
        expect(bloc.state.title, '');
        expect(bloc.state.body, '');
        expect(bloc.state.selectedSection, isNull);
        expect(bloc.state.images, isEmpty);
        expect(bloc.state.isEditing, false);
        expect(bloc.state.status, FormStatus.initial);
      });

      test('initializes with existing article in edit mode', () {
        const article = ArticleEntity(
          documentId: 'doc-1',
          title: 'Test Title',
          content: 'Test Content',
          images: ['https://example.com/image.jpg'],
        );
        final editBloc = createBloc(
          existingArticle: article,
          existingSection: NewsSection.sports,
        );

        expect(editBloc.state.title, 'Test Title');
        expect(editBloc.state.body, 'Test Content');
        expect(editBloc.state.selectedSection, NewsSection.sports);
        expect(editBloc.state.isEditing, true);
        expect(editBloc.state.articleId, 'doc-1');
        expect(editBloc.state.images.length, 1);
        expect(
            editBloc.state.images.first.url, 'https://example.com/image.jpg');

        editBloc.close();
      });

      test('initializes with empty images when article has no images', () {
        const article = ArticleEntity(documentId: 'doc-2', title: 'No Image');
        final editBloc = createBloc(existingArticle: article);

        expect(editBloc.state.images, isEmpty);
        expect(editBloc.state.isEditing, true);

        editBloc.close();
      });
    });

    group('NewsFormTitleChanged', () {
      test('updates title', () async {
        bloc.add(const NewsFormTitleChanged('New Title'));
        await Future.delayed(Duration.zero);

        expect(bloc.state.title, 'New Title');
      });
    });

    group('NewsFormBodyChanged', () {
      test('updates body', () async {
        bloc.add(const NewsFormBodyChanged('New Body'));
        await Future.delayed(Duration.zero);

        expect(bloc.state.body, 'New Body');
      });
    });

    group('NewsFormSectionChanged', () {
      test('updates selected section', () async {
        bloc.add(const NewsFormSectionChanged(NewsSection.weather));
        await Future.delayed(Duration.zero);

        expect(bloc.state.selectedSection, NewsSection.weather);
      });
    });

    group('NewsFormImageAdded', () {
      test('adds image to list', () async {
        final file = File('test_image.jpg');
        bloc.add(NewsFormImageAdded(file));
        await Future.delayed(Duration.zero);

        expect(bloc.state.images.length, 1);
        expect(bloc.state.images.first.file, file);
      });

      test('does not add image when max reached', () async {
        for (var i = 0; i < 5; i++) {
          bloc.add(NewsFormImageAdded(File('image_$i.jpg')));
          await Future.delayed(Duration.zero);
        }

        expect(bloc.state.images.length, 5);

        bloc.add(NewsFormImageAdded(File('image_extra.jpg')));
        await Future.delayed(Duration.zero);

        expect(bloc.state.images.length, 5);
      });
    });

    group('NewsFormImageRemoved', () {
      test('removes image at index', () async {
        bloc.add(NewsFormImageAdded(File('image_0.jpg')));
        bloc.add(NewsFormImageAdded(File('image_1.jpg')));
        await Future.delayed(Duration.zero);

        bloc.add(const NewsFormImageRemoved(0));
        await Future.delayed(Duration.zero);

        expect(bloc.state.images.length, 1);
        expect(bloc.state.images.first.file?.path, 'image_1.jpg');
      });

      test('ignores invalid index', () async {
        bloc.add(NewsFormImageAdded(File('image.jpg')));
        await Future.delayed(Duration.zero);

        bloc.add(const NewsFormImageRemoved(5));
        await Future.delayed(Duration.zero);

        expect(bloc.state.images.length, 1);
      });

      test('ignores negative index', () async {
        bloc.add(NewsFormImageAdded(File('image.jpg')));
        await Future.delayed(Duration.zero);

        bloc.add(const NewsFormImageRemoved(-1));
        await Future.delayed(Duration.zero);

        expect(bloc.state.images.length, 1);
      });
    });

    group('NewsFormSubmitted', () {
      test('emits success when creating article with valid fields', () async {
        bloc.add(const NewsFormTitleChanged('Title'));
        bloc.add(const NewsFormBodyChanged('Body content'));
        bloc.add(const NewsFormSectionChanged(NewsSection.sports));
        await Future.delayed(Duration.zero);

        bloc.add(const NewsFormSubmitted());
        await Future.delayed(Duration.zero);

        expect(bloc.state.status, FormStatus.success);
      });

      test('does not submit when canSubmit is false', () async {
        bloc.add(const NewsFormSubmitted());
        await Future.delayed(Duration.zero);

        expect(bloc.state.status, FormStatus.initial);
      });

      test('emits failure with network ErrorType when create fails',
          () async {
        final repo = FakeFirestoreArticleRepository();
        repo.createResult = const DataFailed(NetworkFailure());
        final failBloc = createBloc(repo: repo);

        failBloc.add(const NewsFormTitleChanged('Title'));
        failBloc.add(const NewsFormBodyChanged('Body'));
        failBloc.add(const NewsFormSectionChanged(NewsSection.sports));
        await Future.delayed(Duration.zero);

        failBloc.add(const NewsFormSubmitted());
        await Future.delayed(Duration.zero);

        expect(failBloc.state.status, FormStatus.failure);
        expect(failBloc.state.errorType, ErrorType.network);
        failBloc.close();
      });

      test('emits failure with server ErrorType when update fails', () async {
        final repo = FakeFirestoreArticleRepository();
        repo.updateResult = const DataFailed(ServerFailure());
        const article = ArticleEntity(
          documentId: 'doc-1',
          title: 'Original',
          content: 'Content',
          section: NewsSection.arts,
        );
        final editBloc = createBloc(
          repo: repo,
          existingArticle: article,
          existingSection: NewsSection.arts,
        );

        editBloc.add(const NewsFormTitleChanged('Updated'));
        await Future.delayed(Duration.zero);

        editBloc.add(const NewsFormSubmitted());
        await Future.delayed(Duration.zero);

        expect(editBloc.state.status, FormStatus.failure);
        expect(editBloc.state.errorType, ErrorType.server);
        editBloc.close();
      });
    });

    group('NewsFormDeleted', () {
      test('emits success when deleting article with documentId', () async {
        const article = ArticleEntity(
          documentId: 'doc-delete',
          title: 'To Delete',
          content: 'Content',
          section: NewsSection.arts,
        );
        final editBloc = createBloc(
          existingArticle: article,
          existingSection: NewsSection.arts,
        );

        editBloc.add(const NewsFormDeleted());
        await Future.delayed(Duration.zero);

        expect(editBloc.state.status, FormStatus.success);
        editBloc.close();
      });

      test('does nothing when articleId is null', () async {
        bloc.add(const NewsFormDeleted());
        await Future.delayed(Duration.zero);

        expect(bloc.state.status, FormStatus.initial);
      });

      test('emits failure with ErrorType when delete fails', () async {
        final repo = FakeFirestoreArticleRepository();
        repo.deleteResult = const DataFailed(StorageFailure());
        const article = ArticleEntity(
          documentId: 'doc-fail',
          title: 'Fail Delete',
          content: 'Content',
          section: NewsSection.crime,
        );
        final editBloc = createBloc(
          repo: repo,
          existingArticle: article,
          existingSection: NewsSection.crime,
        );

        editBloc.add(const NewsFormDeleted());
        await Future.delayed(Duration.zero);

        expect(editBloc.state.status, FormStatus.failure);
        expect(editBloc.state.errorType, ErrorType.storage);
        editBloc.close();
      });
    });
  });

  group('NewsFormState', () {
    test('canSubmit returns true when all required fields are filled', () {
      const state = NewsFormState(
        title: 'Title',
        body: 'Body content',
        selectedSection: NewsSection.weather,
      );

      expect(state.canSubmit, true);
    });

    test('canSubmit returns false when title is empty', () {
      const state = NewsFormState(
        title: '',
        body: 'Body content',
        selectedSection: NewsSection.weather,
      );

      expect(state.canSubmit, false);
    });

    test('canSubmit returns false when title is only whitespace', () {
      const state = NewsFormState(
        title: '   ',
        body: 'Body content',
        selectedSection: NewsSection.weather,
      );

      expect(state.canSubmit, false);
    });

    test('canSubmit returns false when body is empty', () {
      const state = NewsFormState(
        title: 'Title',
        body: '',
        selectedSection: NewsSection.weather,
      );

      expect(state.canSubmit, false);
    });

    test('canSubmit returns false when section is null', () {
      const state = NewsFormState(
        title: 'Title',
        body: 'Body content',
      );

      expect(state.canSubmit, false);
    });

    test('canSubmit returns false when submitting', () {
      const state = NewsFormState(
        title: 'Title',
        body: 'Body content',
        selectedSection: NewsSection.weather,
        status: FormStatus.submitting,
      );

      expect(state.canSubmit, false);
    });

    test('canAddMoreImages returns true when under max', () {
      const state = NewsFormState(images: [ImageItem(url: 'a.jpg')]);

      expect(state.canAddMoreImages, true);
    });

    test('canAddMoreImages returns false when at max', () {
      const state = NewsFormState(
        images: [
          ImageItem(url: '1.jpg'),
          ImageItem(url: '2.jpg'),
          ImageItem(url: '3.jpg'),
          ImageItem(url: '4.jpg'),
          ImageItem(url: '5.jpg'),
        ],
      );

      expect(state.canAddMoreImages, false);
    });

    test('hasUnsavedChanges detects title change', () {
      const state = NewsFormState(
        title: 'Changed',
        originalTitle: 'Original',
      );

      expect(state.hasUnsavedChanges, true);
    });

    test('hasUnsavedChanges detects body change', () {
      const state = NewsFormState(
        body: 'Changed',
        originalBody: 'Original',
      );

      expect(state.hasUnsavedChanges, true);
    });

    test('hasUnsavedChanges detects section change', () {
      const state = NewsFormState(
        selectedSection: NewsSection.arts,
        originalSection: NewsSection.weather,
      );

      expect(state.hasUnsavedChanges, true);
    });

    test('hasUnsavedChanges returns false when unchanged', () {
      const state = NewsFormState(
        title: 'Same',
        body: 'Same',
        selectedSection: NewsSection.weather,
        originalTitle: 'Same',
        originalBody: 'Same',
        originalSection: NewsSection.weather,
      );

      expect(state.hasUnsavedChanges, false);
    });

    test('copyWith preserves values when not specified', () {
      const original = NewsFormState(
        title: 'Title',
        body: 'Body',
        selectedSection: NewsSection.arts,
        isEditing: true,
      );

      final copied = original.copyWith(title: 'New Title');

      expect(copied.title, 'New Title');
      expect(copied.body, 'Body');
      expect(copied.selectedSection, NewsSection.arts);
      expect(copied.isEditing, true);
    });
  });
}
