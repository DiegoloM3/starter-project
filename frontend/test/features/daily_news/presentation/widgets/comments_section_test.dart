import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/comment/comment_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/comment/comment_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/comment/comment_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/comment_tile.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/comments_section.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../helpers/test_fixtures.dart';

class FakeCommentBloc extends Fake implements CommentBloc {
  FakeCommentBloc(this._state);

  CommentState _state;
  final _controller = StreamController<CommentState>.broadcast();
  final List<CommentEvent> added = [];

  @override
  CommentState get state => _state;

  @override
  Stream<CommentState> get stream => _controller.stream;

  @override
  void add(CommentEvent event) => added.add(event);

  @override
  void emit(CommentState s) {
    _state = s;
    _controller.add(s);
  }

  @override
  Future<void> close() async => _controller.close();

  @override
  bool get isClosed => _controller.isClosed;
}

Widget _wrap(
  FakeCommentBloc bloc, {
  String? currentUserId,
  String? currentUserName,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: SingleChildScrollView(
        child: BlocProvider<CommentBloc>.value(
          value: bloc,
          child: CommentsSection(
            articleId: tArticleId,
            currentUserId: currentUserId,
            currentUserName: currentUserName,
          ),
        ),
      ),
    ),
  );
}

void main() {
  const error = AppException(message: 'oops', code: 'err');

  testWidgets('shows empty state when there are no comments', (tester) async {
    final bloc = FakeCommentBloc(const CommentsDone([]));

    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.text('No comments yet. Be the first!'), findsOneWidget);
  });

  testWidgets('renders the comment list on CommentsDone', (tester) async {
    final bloc = FakeCommentBloc(CommentsDone(testCommentList()));

    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.byType(CommentTile), findsNWidgets(3));
    expect(find.text('Comment 0'), findsOneWidget);
  });

  testWidgets('CommentsActionFailure keeps the list rendered', (tester) async {
    final bloc = FakeCommentBloc(
      CommentsActionFailure(error, comments: testCommentList()),
    );

    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    // The list is NOT wiped by an action failure.
    expect(find.byType(CommentTile), findsNWidgets(3));
  });

  testWidgets('shows snackbar when transitioning to CommentsActionFailure',
      (tester) async {
    final bloc = FakeCommentBloc(CommentsDone(testCommentList()));

    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    bloc.emit(CommentsActionFailure(error, comments: testCommentList()));
    await tester.pump(); // process the emitted state
    await tester.pump(); // let the snackbar appear

    expect(find.text('oops'), findsOneWidget);
    expect(find.byType(CommentTile), findsNWidgets(3));
  });

  testWidgets('load failure shows retry that re-subscribes', (tester) async {
    final bloc = FakeCommentBloc(const CommentsLoadFailure(error));

    await tester.pumpWidget(_wrap(bloc));
    await tester.pump();

    expect(find.text('Failed to load comments'), findsOneWidget);
    final retry = find.text('Try again');
    expect(retry, findsOneWidget);

    await tester.tap(retry);
    await tester.pump();

    expect(
      bloc.added.whereType<CommentsSubscriptionRequested>().single.articleId,
      tArticleId,
    );
  });

  testWidgets('send does nothing when there is no logged-in user',
      (tester) async {
    final bloc = FakeCommentBloc(const CommentsDone([]));

    await tester.pumpWidget(_wrap(bloc, currentUserId: null));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(bloc.added.whereType<CommentAdded>(), isEmpty);
  });

  testWidgets('send dispatches CommentAdded with the resolved author name',
      (tester) async {
    final bloc = FakeCommentBloc(const CommentsDone([]));

    await tester.pumpWidget(
      _wrap(bloc, currentUserId: tUserId, currentUserName: 'Bob'),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Nice read');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    final event = bloc.added.whereType<CommentAdded>().single;
    expect(event.comment.authorId, tUserId);
    expect(event.comment.authorName, 'Bob');
    expect(event.comment.content, 'Nice read');
  });

  testWidgets('input avatar shows the first letter of the author name',
      (tester) async {
    final bloc = FakeCommentBloc(const CommentsDone([]));

    await tester.pumpWidget(_wrap(bloc, currentUserName: 'Bob'));
    await tester.pump();

    expect(find.text('B'), findsOneWidget);
  });
}
