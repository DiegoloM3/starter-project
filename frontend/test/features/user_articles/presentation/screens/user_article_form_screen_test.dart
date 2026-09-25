import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/create_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/delete_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/update_user_article_usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/form/user_article_form_cubit.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/screens/user_article_form_screen.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/get_current_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/connectivity/domain/repository/connectivity_repository.dart';
import 'package:news_app_clean_architecture/shared/connectivity/domain/usecases/watch_connectivity_usecase.dart';
import 'package:news_app_clean_architecture/shared/connectivity/presentation/bloc/connectivity_cubit.dart';

/// For tests that never reach a write -- any call through it fails loudly.
class _UnusedArticleRepository implements UserArticleRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedAccountRepository implements AccountRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A working repository, so the whole path (screen -> cubit -> use case ->
/// repository) can be observed instead of stubbed away.
class _RecordingArticleRepository implements UserArticleRepository {
  int createCalls = 0;
  int updateCalls = 0;
  final deletedIds = <String>[];

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
    createCalls++;
    return DataSuccess(_article('autosaved-1', title, isDraft));
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
    updateCalls++;
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

/// The real cubit, with only the byline suggestion stubbed: returns [name]
/// (or nothing) after one microtask, like a real account read -- close
/// enough to catch a prefill that races the widget's own build.
class _TestFormCubit extends UserArticleFormCubit {
  final String? name;
  final VoidCallback? onAsk;

  _TestFormCubit({
    UserArticleRepository? articles,
    this.name,
    this.onAsk,
  }) : super(
          CreateUserArticleUseCase(articles ?? _UnusedArticleRepository()),
          UpdateUserArticleUseCase(articles ?? _UnusedArticleRepository()),
          DeleteUserArticleUseCase(articles ?? _UnusedArticleRepository()),
          GetCurrentAccountUseCase(_UnusedAccountRepository()),
        );

  @override
  Future<String?> suggestedAuthorName() async {
    onAsk?.call();
    await Future<void>.delayed(Duration.zero);
    return name;
  }
}

class _FakeConnectivityRepository implements ConnectivityRepository {
  final bool online;

  _FakeConnectivityRepository({required this.online});

  @override
  Stream<bool> watch() => Stream.value(online);
}

Widget _app(Widget child, {bool online = true}) {
  return BlocProvider<ConnectivityCubit>(
    // Not lazy: in the app this cubit is a singleton created at startup, so
    // its first connectivity reading is in long before any screen asks.
    lazy: false,
    create: (_) => ConnectivityCubit(
      WatchConnectivityUseCase(_FakeConnectivityRepository(online: online)),
    ),
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

Widget _form(UserArticleFormCubit cubit, {UserArticleEntity? article}) {
  return BlocProvider<UserArticleFormCubit>(
    create: (_) => cubit,
    child: UserArticleFormScreen(existingArticle: article),
  );
}

/// The form pushed over a launcher screen, so leaving it is observable:
/// "open" is on screen again once the form has actually closed.
Future<void> _pumpPushed(
  WidgetTester tester,
  UserArticleFormCubit cubit, {
  UserArticleEntity? article,
}) async {
  await tester.pumpWidget(_app(Builder(
    builder: (context) => ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => _form(cubit, article: article)),
      ),
      child: const Text('open'),
    ),
  )));
  await tester.tap(find.text('open'));
  // Not pumpAndSettle: an existing article's fake thumbnail URL never
  // resolves in a test (HTTP is stubbed to always fail) and its loading
  // placeholder animates on a loop, so it would never see a settled frame.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

UserArticleEntity _article({bool isDraft = false, String thumbnailURL = 'https://example.com/x.jpg'}) {
  return UserArticleEntity(
    id: 'a1',
    authorId: 'u1',
    authorName: 'Original Author',
    title: 'Original title',
    description: 'Original description long enough to pass.',
    content: 'x' * 60,
    thumbnailURL: thumbnailURL,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    isDraft: isDraft,
  );
}

TextFormField _bylineField(WidgetTester tester) =>
    tester.widget(find.byType(TextFormField).first);

Finder _dialogButton(String text) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(text));

Future<void> _goBack(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('byline suggestion', () {
    testWidgets('a new article offers the account name as the byline',
        (tester) async {
      await tester.pumpWidget(_app(_form(_TestFormCubit(name: 'Ana Diaz'))));
      await tester.pumpAndSettle();

      expect(_bylineField(tester).controller!.text, 'Ana Diaz');
    });

    testWidgets('never overwrites a byline the writer already started typing',
        (tester) async {
      await tester.pumpWidget(_app(_form(_TestFormCubit(name: 'Ana Diaz'))));
      // Types before the (delayed) suggestion has a chance to arrive.
      await tester.enterText(find.byType(TextFormField).first, 'My own name');
      await tester.pumpAndSettle();

      expect(_bylineField(tester).controller!.text, 'My own name');
    });

    testWidgets('is skipped when the name is longer than a byline allows',
        (tester) async {
      await tester.pumpWidget(_app(_form(_TestFormCubit(name: 'x' * 61))));
      await tester.pumpAndSettle();

      expect(_bylineField(tester).controller!.text, isEmpty);
    });

    testWidgets('editing an existing article never asks for a suggestion',
        (tester) async {
      var asked = false;
      await tester.pumpWidget(_app(_form(
        _TestFormCubit(name: 'Ana Diaz', onAsk: () => asked = true),
        article: _article(),
      )));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(asked, isFalse);
      expect(_bylineField(tester).controller!.text, 'Original Author');
    });

    testWidgets(
        'opening a new article and leaving writes nothing and asks nothing '
        '-- regression: the suggested byline counted as an edit, so just '
        'opening the form autosaved an empty draft', (tester) async {
      final repository = _RecordingArticleRepository();
      await tester.pumpWidget(_app(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => _form(
                _TestFormCubit(articles: repository, name: 'Ana Diaz'),
              ),
            ),
          ),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      // Well past autosave's debounce.
      await tester.pump(const Duration(seconds: 4));

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(repository.createCalls, 0);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('leaving with changes', () {
    testWidgets(
        'a published article asks before discarding typed edits -- '
        'regression: typing alone never rebuilt the screen, so the check '
        'stayed stuck on its stale, no-changes answer', (tester) async {
      await _pumpPushed(tester, _TestFormCubit(), article: _article());

      await tester.enterText(find.byType(TextFormField).at(1), 'Edited title');
      await tester.pump();
      await _goBack(tester);

      expect(find.text('Discard changes?'), findsOneWidget);
      expect(_dialogButton('Save draft'), findsNothing);
    });

    testWidgets('going back with no changes made leaves quietly',
        (tester) async {
      await _pumpPushed(tester, _TestFormCubit(), article: _article());

      await _goBack(tester);

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets(
        'a draft is asked what to do with it: discard, save as draft or '
        'publish', (tester) async {
      await _pumpPushed(tester, _TestFormCubit(),
          article: _article(isDraft: true));

      await tester.enterText(find.byType(TextFormField).at(1), 'Edited title');
      await tester.pump();
      await _goBack(tester);

      expect(find.text('Save your changes?'), findsOneWidget);
      expect(_dialogButton('Discard'), findsOneWidget);
      expect(_dialogButton('Save draft'), findsOneWidget);
      expect(_dialogButton('Publish'), findsOneWidget);
    });

    testWidgets(
        'discarding a new article autosave already saved deletes it -- '
        'regression: the autosaved draft stayed behind after "Discard"',
        (tester) async {
      final repository = _RecordingArticleRepository();
      await _pumpPushed(tester, _TestFormCubit(articles: repository));

      await tester.enterText(find.byType(TextFormField).at(1), 'Never mind');
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      expect(repository.createCalls, 1);

      await _goBack(tester);
      await tester.tap(_dialogButton('Discard'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repository.deletedIds, ['autosaved-1']);
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('actions', () {
    testWidgets('a new article offers Save draft and Publish', (tester) async {
      await tester.pumpWidget(_app(_form(_TestFormCubit())));
      await tester.pumpAndSettle();

      expect(find.text('Save draft'), findsOneWidget);
      expect(find.text('Publish'), findsOneWidget);
    });

    testWidgets(
        'an existing draft offers Save draft next to Publish -- not Save, '
        'which read as "keep it a draft" but published it', (tester) async {
      await tester.pumpWidget(
          _app(_form(_TestFormCubit(), article: _article(isDraft: true))));
      await tester.pump();

      expect(find.text('Save draft'), findsOneWidget);
      expect(find.text('Publish'), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets(
        'a published article offers Save, and moving it back to drafts '
        'behind a confirmation', (tester) async {
      await tester.pumpWidget(_app(_form(_TestFormCubit(), article: _article())));
      await tester.pump();

      expect(find.text('Save draft'), findsNothing);
      expect(find.text('Save'), findsOneWidget);

      await tester.tap(find.text('Move to drafts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Move to drafts?'), findsOneWidget);
    });

    testWidgets(
        'publishing a draft saved without a photo asks for one first, '
        'instead of sending it and failing on the server', (tester) async {
      await tester.pumpWidget(_app(_form(
        _TestFormCubit(),
        article: _article(isDraft: true, thumbnailURL: ''),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();

      // Once as the empty picker's prompt, once as the error under it.
      expect(find.text('Choose a cover image'), findsNWidgets(2));
    });

    testWidgets(
        'offline, saving says why instead of spinning forever -- a Firestore '
        'write never completes without a connection', (tester) async {
      final repository = _RecordingArticleRepository();
      await tester.pumpWidget(
          _app(_form(_TestFormCubit(articles: repository)), online: false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save draft'));
      await tester.pump();

      expect(find.textContaining("You're offline"), findsOneWidget);
      expect(repository.createCalls, 0);
      // Lets the toast's own timers run out before the test ends.
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('autosave', () {
    testWidgets(
        'typing pauses for a few seconds, then the draft saves itself in '
        'the background and shows a small confirmation -- no navigation, '
        'no overlay, just a quiet write', (tester) async {
      final repository = _RecordingArticleRepository();
      await tester.pumpWidget(_app(_form(_TestFormCubit(articles: repository))));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).at(1), 'A working title');
      await tester.pump();
      expect(find.textContaining('Draft saved'), findsNothing);

      // Past the 3-second debounce, plus a couple of bare pumps so the
      // autosave's own chain of awaits (cubit -> use case -> repository)
      // resolves before the frame is checked.
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      await tester.pump();

      expect(repository.createCalls, 1);
      expect(find.textContaining('Draft saved'), findsOneWidget);
      expect(find.byType(UserArticleFormScreen), findsOneWidget);
    });

    testWidgets(
        'backgrounding the app saves the draft right away, instead of '
        'waiting out the debounce or the periodic safety net', (tester) async {
      final repository = _RecordingArticleRepository();
      await tester.pumpWidget(_app(_form(_TestFormCubit(articles: repository))));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).at(1), 'A working title');
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      await tester.pump();

      expect(repository.createCalls, 1);
    });

    testWidgets('never runs against an article that is already published',
        (tester) async {
      final repository = _RecordingArticleRepository();
      await tester.pumpWidget(
          _app(_form(_TestFormCubit(articles: repository), article: _article())));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(1), 'Edited title');
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      expect(repository.createCalls, 0);
      expect(repository.updateCalls, 0);
    });

    testWidgets('waits while offline instead of starting a write that hangs',
        (tester) async {
      final repository = _RecordingArticleRepository();
      await tester.pumpWidget(_app(
        _form(_TestFormCubit(articles: repository)),
        online: false,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).at(1), 'A working title');
      await tester.pump(const Duration(seconds: 4));

      expect(repository.createCalls, 0);
    });
  });

  // A test tapping Save on this screen and asserting the overlay appears
  // was tried here and dropped: the assertions themselves passed every
  // time, but the test run never returned afterward -- this screen's
  // BlocListener, its thumbnail's loading animation and the overlay's
  // OverlayEntry together hang the test framework's own teardown, not the
  // application code. The overlay itself (loading -> checkmark -> dismiss)
  // is covered in submit_progress_overlay_test.dart, and the whole
  // save/overlay ordering at the cubit level in user_article_form_cubit_test.
}
