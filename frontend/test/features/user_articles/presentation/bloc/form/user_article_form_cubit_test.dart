import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/create_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/delete_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/update_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/form/article_form_input.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/form/user_article_form_cubit.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/form/user_article_form_state.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/get_current_account_usecase.dart';

/// A working in-memory repository that records every write, and can hold
/// creates back ([holdCreates]) to line concurrent writes up on purpose.
class _RecordingArticleRepository implements UserArticleRepository {
  final createdAsDraft = <bool>[];
  final updatedIds = <String>[];
  final updatedTitles = <String>[];
  final deletedIds = <String>[];
  final uploadedImages = <Uint8List>[];
  Completer<void>? holdCreates;
  var _nextId = 1;

  UserArticleEntity _article(String id, String title, bool isDraft) {
    return UserArticleEntity(
      id: id,
      authorId: 'u1',
      authorName: 'Ana',
      title: title,
      description: '',
      content: '',
      thumbnailURL: '',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      isDraft: isDraft,
    );
  }

  @override
  Future<DataState<UserArticleEntity>> createArticle({
    required String authorName,
    required String title,
    required String description,
    required String content,
    required Uint8List? thumbnailBytes,
    required String? thumbnailExtension,
    required bool isDraft,
  }) async {
    final hold = holdCreates;
    if (hold != null) await hold.future;
    createdAsDraft.add(isDraft);
    if (thumbnailBytes != null) uploadedImages.add(thumbnailBytes);
    return DataSuccess(_article('a${_nextId++}', title, isDraft));
  }

  @override
  Future<DataState<UserArticleEntity>> updateArticle({
    required String id,
    required String authorName,
    required String title,
    required String description,
    required String content,
    Uint8List? newThumbnailBytes,
    String? newThumbnailExtension,
    required bool isDraft,
  }) async {
    updatedIds.add(id);
    updatedTitles.add(title);
    if (newThumbnailBytes != null) uploadedImages.add(newThumbnailBytes);
    return DataSuccess(_article(id, title, isDraft));
  }

  @override
  Future<DataState<bool>> deleteArticle(String id) async {
    deletedIds.add(id);
    return const DataSuccess(true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAccountRepository implements AccountRepository {
  final AccountEntity? account;

  _FakeAccountRepository(this.account);

  @override
  Future<DataState<AccountEntity>> getCurrentAccount() async {
    final account = this.account;
    return account == null
        ? DataFailed(Exception('no account'))
        : DataSuccess(account);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

UserArticleFormCubit _cubit({
  _RecordingArticleRepository? articles,
  AccountEntity? account,
}) {
  final repository = articles ?? _RecordingArticleRepository();
  final cubit = UserArticleFormCubit(
    CreateUserArticleUseCase(repository),
    UpdateUserArticleUseCase(repository),
    DeleteUserArticleUseCase(repository),
    GetCurrentAccountUseCase(_FakeAccountRepository(account)),
  );
  addTearDown(cubit.close);
  return cubit;
}

ArticleFormInput _input(String title, {Uint8List? image}) => ArticleFormInput(
      authorName: 'Ana',
      title: title,
      description: '',
      content: '',
      imageBytes: image,
      imageExtension: image == null ? null : 'jpg',
    );

UserArticleEntity _existingDraft() => UserArticleEntity(
      id: 'd1',
      authorId: 'u1',
      authorName: 'Ana',
      title: 'Original title',
      description: 'Original summary',
      content: 'Original body',
      thumbnailURL: 'https://example.com/d1.jpg',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      isDraft: true,
    );

void main() {
  group('suggestedAuthorName', () {
    test('offers the connected account\'s display name', () async {
      final cubit = _cubit(
        account: const AccountEntity(
            id: 'u1', isGuest: false, displayName: 'Ana Diaz'),
      );

      expect(await cubit.suggestedAuthorName(), 'Ana Diaz');
    });

    test('offers nothing for a guest', () async {
      final cubit =
          _cubit(account: const AccountEntity(id: 'guest', isGuest: true));

      expect(await cubit.suggestedAuthorName(), isNull);
    });

    test('offers nothing for an account with no display name (email)',
        () async {
      final cubit = _cubit(
        account: const AccountEntity(
            id: 'u2', isGuest: false, email: 'ana@example.com'),
      );

      expect(await cubit.suggestedAuthorName(), isNull);
    });

    test('offers nothing when the account could not be read', () async {
      expect(await _cubit().suggestedAuthorName(), isNull);
    });
  });

  group('explicit saves', () {
    test('a draft saves with no photo at all, through the overlay states',
        () async {
      final repository = _RecordingArticleRepository();
      final cubit = _cubit(articles: repository)..edit(null);
      final states = <UserArticleFormState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.saveDraft(_input('Just an idea'));
      // A Bloc's stream delivers asynchronously: let the last state arrive.
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(repository.createdAsDraft, [true]);
      expect(repository.uploadedImages, isEmpty);
      expect(states, [
        isA<UserArticleFormSubmitting>(),
        isA<UserArticleFormSuccess>(),
      ]);
      expect((cubit.state as UserArticleFormSuccess).article.isDraft, isTrue);
    });

    test('moving a published article to drafts updates it as a draft',
        () async {
      final repository = _RecordingArticleRepository();
      final published = UserArticleEntity(
        id: 'p1',
        authorId: 'u1',
        authorName: 'Ana',
        title: 'Live',
        description: '',
        content: '',
        thumbnailURL: '',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      final cubit = _cubit(articles: repository)..edit(published);

      await cubit.saveDraft(_input('Live'));

      expect(repository.updatedIds, ['p1']);
      expect((cubit.state as UserArticleFormSuccess).article.isDraft, isTrue);
    });
  });

  group('autosave', () {
    test(
        'never emits Submitting/Success/Error -- those drive the overlay '
        'and close the screen, which a background save must never do',
        () async {
      final cubit = _cubit()..edit(null);
      final states = <UserArticleFormState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.autosave(_input('A working title'));
      await subscription.cancel();

      expect(states, isEmpty);
      expect(cubit.state, isA<UserArticleFormIdle>());
    });

    test('creates the article the first time, updates it every time after',
        () async {
      final repository = _RecordingArticleRepository();
      final cubit = _cubit(articles: repository)..edit(null);

      final created = await cubit.autosave(_input('First pass'));
      await cubit.autosave(_input('Second pass'));

      expect(repository.createdAsDraft, [true]);
      expect(repository.updatedIds, [created!.id]);
    });

    test('is skipped while an explicit save is in flight', () async {
      final repository = _RecordingArticleRepository()
        ..holdCreates = Completer<void>();
      final cubit = _cubit(articles: repository)..edit(null);

      final publishing = cubit.publish(_input('Final'));
      expect(await cubit.autosave(_input('Final')), isNull);

      repository.holdCreates!.complete();
      await publishing;
      expect(repository.createdAsDraft, [false]);
    });
  });

  test(
      'publishing while an autosave is still creating the article updates '
      'that same article -- regression: it used to create a second copy',
      () async {
    final repository = _RecordingArticleRepository()
      ..holdCreates = Completer<void>();
    final cubit = _cubit(articles: repository)..edit(null);

    final autosaving = cubit.autosave(_input('Draft title'));
    final publishing = cubit.publish(_input('Final title'));
    repository.holdCreates!.complete();
    final autosaved = await autosaving;
    await publishing;

    expect(repository.createdAsDraft, [true]);
    expect(repository.updatedIds, [autosaved!.id]);
    expect(repository.updatedTitles, ['Final title']);
    expect(cubit.state, isA<UserArticleFormSuccess>());
  });

  group('photos', () {
    test('uploads a picked photo once, not again on every later save',
        () async {
      final repository = _RecordingArticleRepository();
      final cubit = _cubit(articles: repository)..edit(null);
      final photo = Uint8List.fromList([1, 2, 3]);

      await cubit.autosave(_input('One', image: photo));
      await cubit.autosave(_input('Two', image: photo));
      await cubit.publish(_input('Three', image: photo));

      expect(repository.uploadedImages, [photo]);
    });

    test(
        'on an existing draft, autosave leaves a new photo for the explicit '
        'save -- so discarding can still restore the draft exactly',
        () async {
      final repository = _RecordingArticleRepository();
      final cubit = _cubit(articles: repository)..edit(_existingDraft());
      final photo = Uint8List.fromList([1, 2, 3]);

      await cubit.autosave(_input('Edited', image: photo));
      expect(repository.uploadedImages, isEmpty);

      await cubit.saveDraft(_input('Edited', image: photo));
      expect(repository.uploadedImages, [photo]);
    });
  });

  group('discardChanges', () {
    test('deletes a new article that only exists because of autosave',
        () async {
      final repository = _RecordingArticleRepository();
      final cubit = _cubit(articles: repository)..edit(null);

      final autosaved = await cubit.autosave(_input('Never mind'));
      await cubit.discardChanges();

      expect(repository.deletedIds, [autosaved!.id]);
    });

    test('writes an existing draft back to how it was when opened',
        () async {
      final repository = _RecordingArticleRepository();
      final cubit = _cubit(articles: repository)..edit(_existingDraft());

      await cubit.autosave(_input('Half-rewritten'));
      await cubit.discardChanges();

      expect(repository.deletedIds, isEmpty);
      expect(repository.updatedIds, ['d1', 'd1']);
      expect(repository.updatedTitles.last, 'Original title');
    });

    test('does nothing when autosave never wrote', () async {
      final repository = _RecordingArticleRepository();
      final cubit = _cubit(articles: repository)..edit(_existingDraft());

      await cubit.discardChanges();

      expect(repository.updatedIds, isEmpty);
      expect(repository.deletedIds, isEmpty);
    });
  });
}
