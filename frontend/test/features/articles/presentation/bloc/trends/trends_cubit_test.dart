import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/topic_trend.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_trending_topics.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/trends/trends_cubit.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/trends/trends_state.dart';

import '../article_presentation_test_data.dart';

class MockGetTrendingTopicsUseCase extends Mock implements GetTrendingTopicsUseCase {}

void main() {
  late MockGetTrendingTopicsUseCase getTrendingTopics;
  final trends = [
    TopicTrend(topic: ArticleTopic.technology, articles: [buildArticle()]),
  ];

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() => getTrendingTopics = MockGetTrendingTopicsUseCase());

  blocTest<TrendsCubit, TrendsState>(
    'loads the trending topics',
    setUp: () => when(() => getTrendingTopics(any())).thenAnswer((_) async => DataSuccess(trends)),
    build: () => TrendsCubit(getTrendingTopics),
    act: (cubit) => cubit.load(),
    expect:
        () => [
          const TrendsState(status: TrendsStatus.loading),
          TrendsState(status: TrendsStatus.success, trends: trends),
        ],
  );

  blocTest<TrendsCubit, TrendsState>(
    'keeps the current trends when they cannot be loaded',
    setUp: () => when(() => getTrendingTopics(any())).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: () => TrendsCubit(getTrendingTopics),
    seed: () => TrendsState(status: TrendsStatus.success, trends: trends),
    act: (cubit) => cubit.load(),
    expect:
        () => [
          TrendsState(status: TrendsStatus.loading, trends: trends),
          TrendsState(status: TrendsStatus.failure, trends: trends),
        ],
  );
}
