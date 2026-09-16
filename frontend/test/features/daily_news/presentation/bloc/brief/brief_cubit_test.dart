import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(const NewsQuery()));

  late MockGetTopHeadlinesUseCase getTopHeadlines;
  late BriefCubit cubit;

  setUp(() {
    getTopHeadlines = MockGetTopHeadlinesUseCase();
    cubit = BriefCubit(getTopHeadlines);
  });
  tearDown(() => cubit.close());

  test('topics toggle, Surprise me selects all, and nothing starts without one', () async {
    expect(cubit.state.canStart, isFalse);
    await cubit.start();
    verifyNever(() => getTopHeadlines(any()));

    cubit.toggleTopic(NewsCategory.health);
    cubit.toggleTopic(NewsCategory.science);
    cubit.toggleTopic(NewsCategory.health);
    expect(cubit.state.selectedTopics, {NewsCategory.science});

    cubit.selectAllTopics();
    expect(cubit.state.selectedTopics, BriefCubit.topics.toSet());
  });

  test('start interleaves the chosen topics, drops duplicates and keeps five', () async {
    when(() => getTopHeadlines(const NewsQuery(category: NewsCategory.health)))
        .thenAnswer((_) async => DataSuccess([for (var i = 0; i < 4; i++) buildArticle(id: 'h$i')]));
    when(() => getTopHeadlines(const NewsQuery(category: NewsCategory.science)))
        .thenAnswer((_) async => DataSuccess([buildArticle(id: 's0'), buildArticle(id: 'h1')]));
    cubit
      ..toggleTopic(NewsCategory.health)
      ..toggleTopic(NewsCategory.science);

    await cubit.start();

    expect(cubit.state.step, BriefStep.reading);
    final ids = cubit.state.articles.map((a) => a.id).toList();
    expect(ids.length, 5);
    expect(ids.toSet().length, 5);
    expect(ids.take(2).toSet(), {'h0', 's0'});
  });

  test('a topic that fails is skipped; all failing ends in failure', () async {
    when(() => getTopHeadlines(any())).thenAnswer((_) async => const DataFailed(Failure.network()));
    cubit.toggleTopic(NewsCategory.sports);

    await cubit.start();

    expect(cubit.state.step, BriefStep.failure);
    expect(cubit.state.failure, const Failure.network());
  });

  test('reading tracks the cards shown, finish stamps today, restart keeps it', () async {
    when(() => getTopHeadlines(any())).thenAnswer((_) async => DataSuccess([buildArticle(id: 'a'), buildArticle(id: 'b')]));
    cubit.toggleTopic(NewsCategory.sports);
    await cubit.start();

    cubit.cardShown(0);
    cubit.cardShown(1);
    cubit.cardShown(9);
    expect(cubit.state.readIds, {'a', 'b'});
    expect(cubit.state.index, 1);

    final now = DateTime(2026, 9, 16, 8);
    cubit.finish(now);
    expect(cubit.state.step, BriefStep.summary);
    expect(cubit.state.isCompletedOn(now), isTrue);
    expect(cubit.state.isCompletedOn(now.add(const Duration(days: 1))), isFalse);
    expect(cubit.state.totalMinutes, greaterThanOrEqualTo(1));

    cubit.restart();
    expect(cubit.state.step, BriefStep.picking);
    expect(cubit.state.isCompletedOn(now), isTrue);
  });

  test('reset forgets the brief and its completion', () async {
    cubit.finish(DateTime(2026, 9, 16));
    expect(cubit.state.isCompletedOn(DateTime(2026, 9, 16)), isTrue);

    cubit.reset();

    expect(cubit.state, const BriefState());
  });

  test('markRead counts a story opened from its card', () async {
    when(() => getTopHeadlines(any())).thenAnswer((_) async => DataSuccess([buildArticle(id: 'a'), buildArticle(id: 'b')]));
    cubit.toggleTopic(NewsCategory.sports);
    await cubit.start();

    cubit.markRead(buildArticle(id: 'b'));

    expect(cubit.state.readIds, contains('b'));
  });
}
