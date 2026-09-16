import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/apply_article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/reader_lens/reader_lens_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ApplyArticleLensParams(lens: ArticleLens.brief, article: buildArticle()));
  });

  late MockApplyArticleLensUseCase apply;
  late ReaderLensCubit cubit;
  final article = buildArticle();
  const brief = ArticleLensResult(lens: ArticleLens.brief, bullets: ['a', 'b', 'c']);

  setUp(() {
    apply = MockApplyArticleLensUseCase();
    when(() => apply(any())).thenAnswer((_) async => const DataSuccess(brief));
    cubit = ReaderLensCubit(apply, article: article);
  });
  tearDown(() => cubit.close());

  test('toggling a lens fetches once, toggling again shows the original, third time is cached', () async {
    await cubit.toggle(ArticleLens.brief);
    expect(cubit.state.active, ArticleLens.brief);
    expect(cubit.state.current, brief);
    expect(cubit.state.isLoading, isFalse);

    await cubit.toggle(ArticleLens.brief);
    expect(cubit.state.active, isNull);
    expect(cubit.state.current, isNull);

    await cubit.toggle(ArticleLens.brief);
    expect(cubit.state.current, brief);
    verify(() => apply(any())).called(1);
  });

  test('a failed lens falls back to the original and reports', () async {
    when(() => apply(any())).thenAnswer((_) async => const DataFailed(Failure.server()));

    await cubit.toggle(ArticleLens.plain);

    expect(cubit.state.active, isNull);
    expect(cubit.state.failure, const Failure.server());
  });

  test('showOriginal clears the active lens but keeps the cache', () async {
    await cubit.toggle(ArticleLens.brief);

    cubit.showOriginal();

    expect(cubit.state.active, isNull);
    expect(cubit.state.results.containsKey(ArticleLens.brief), isTrue);
  });
}
