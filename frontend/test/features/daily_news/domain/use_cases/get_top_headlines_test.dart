import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_top_headlines.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('forwards the query and failures', () async {
    final news = MockNewsRepository();
    const query = NewsQuery();
    when(() => news.getTopHeadlines(query))
        .thenAnswer((_) async => const DataFailed(Failure.network()));

    final result = await GetTopHeadlinesUseCase(news)(query);

    expect(result.failureOrNull?.type, FailureType.network);
  });
}
