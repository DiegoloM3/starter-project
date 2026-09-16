import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/assistant_functions_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_lens_result_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/editor_suggestions_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_assistant_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';

import '../../../../helpers/fixtures.dart';

class MockAssistantFunctionsService extends Mock implements AssistantFunctionsService {}

void main() {
  late MockAssistantFunctionsService service;
  late ArticleAssistantRepositoryImpl repository;

  setUp(() {
    service = MockAssistantFunctionsService();
    repository = ArticleAssistantRepositoryImpl(service);
  });

  test('suggest sends the draft as the suggest task and maps the answer', () async {
    when(() => service.call(task: 'suggest', title: 'A valid title', content: 'A valid body.'))
        .thenAnswer((_) async => {'headlines': ['H1', 'H2'], 'summary': 'S'});

    final result = await repository.suggest(buildDraft());

    expect(result.dataOrNull?.headlines, ['H1', 'H2']);
    expect(result.dataOrNull?.summary, 'S');
  });

  test('each lens maps to its task', () async {
    final article = buildArticle();
    when(() => service.call(task: 'plain', title: 'Title', content: 'Content'))
        .thenAnswer((_) async => {'text': 'Simple body'});
    when(() => service.call(task: 'brief', title: 'Title', content: 'Content'))
        .thenAnswer((_) async => {'bullets': ['a', 'b']});

    expect((await repository.apply(ArticleLens.plain, article)).dataOrNull?.text, 'Simple body');
    expect((await repository.apply(ArticleLens.brief, article)).dataOrNull?.bullets, ['a', 'b']);
  });

  test('an empty answer and function errors become failures', () async {
    when(() => service.call(task: any(named: 'task'), title: any(named: 'title'), content: any(named: 'content')))
        .thenAnswer((_) async => {'headlines': []});
    expect((await repository.suggest(buildDraft())).failureOrNull?.type, FailureType.server);

    when(() => service.call(task: any(named: 'task'), title: any(named: 'title'), content: any(named: 'content')))
        .thenThrow(FirebaseFunctionsException(code: 'resource-exhausted', message: 'busy'));
    expect((await repository.suggest(buildDraft())).failureOrNull?.type, FailureType.server);

    when(() => service.call(task: any(named: 'task'), title: any(named: 'title'), content: any(named: 'content')))
        .thenThrow(FirebaseFunctionsException(code: 'unauthenticated', message: 'no'));
    expect((await repository.suggest(buildDraft())).failureOrNull?.type, FailureType.unauthenticated);
  });

  test('models tolerate sloppy answers', () {
    final suggestions = EditorSuggestionsModel.fromRawData({'headlines': ['ok', 3, ' ']});
    expect(suggestions.headlines, ['ok']);
    expect(suggestions.summary, '');

    final lens = ArticleLensResultModel.fromRawData(ArticleLens.plain, {});
    expect(lens.isEmpty, isTrue);
  });
}
