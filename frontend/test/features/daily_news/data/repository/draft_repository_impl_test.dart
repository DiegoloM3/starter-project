import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/draft_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/in_memory_auth_repository.dart';

void main() {
  late InMemoryAuthRepository auth;

  Future<DraftRepositoryImpl> newRepository({bool photoExists = true}) async => DraftRepositoryImpl(
        DraftLocalDataSource(await SharedPreferences.getInstance(), fileExists: (_) => photoExists),
        auth,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = InMemoryAuthRepository(latency: Duration.zero);
    await auth.signUpWithEmail(const SignUpParams(displayName: 'Ada', email: 'ada@example.com', password: 'secret123'));
  });
  tearDown(() => auth.dispose());

  test('each account keeps its own draft', () async {
    final repository = await newRepository();
    await repository.saveDraft(const SavedDraft(title: 'Mine'));

    await auth.signOut();
    await auth.signInWithGoogle();
    expect(await repository.loadDraft(), isNull);
    await repository.saveDraft(const SavedDraft(title: 'Theirs'));

    await auth.signOut();
    await auth.signInWithEmail(const SignInParams(email: 'ada@example.com', password: 'secret123'));
    expect(await repository.loadDraft(), const SavedDraft(title: 'Mine'));
  });

  test('starts empty, keeps a save for the next read, and clear forgets it', () async {
    final repository = await newRepository();
    expect(await repository.loadDraft(), isNull);

    final draft = SavedDraft(title: 'T', content: 'C', image: buildImage());
    expect((await repository.saveDraft(draft)).isSuccess, isTrue);
    expect(await (await newRepository()).loadDraft(), draft);

    expect((await repository.clearDraft()).isSuccess, isTrue);
    expect(await repository.loadDraft(), isNull);
  });

  test('a photo whose file is gone is dropped; a draft left with nothing is forgotten', () async {
    final withText = await newRepository(photoExists: false);
    await withText.saveDraft(SavedDraft(title: 'T', image: buildImage()));
    expect(await withText.loadDraft(), const SavedDraft(title: 'T'));

    await withText.saveDraft(SavedDraft(image: buildImage()));
    expect(await withText.loadDraft(), isNull);
    expect((await SharedPreferences.getInstance()).containsKey(DraftLocalDataSource.scopedKey(auth.currentUser!.id)), isFalse);
  });

  test('text that is not a draft document reads as no draft', () async {
    SharedPreferences.setMockInitialValues({DraftLocalDataSource.scopedKey(auth.currentUser!.id): '{not json'});

    expect(await (await newRepository()).loadDraft(), isNull);
  });
}
