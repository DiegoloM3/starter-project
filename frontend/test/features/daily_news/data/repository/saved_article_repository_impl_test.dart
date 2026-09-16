import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/saved_article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/saved_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

class MockSavedArticleDao extends Mock implements SavedArticleDao {}

void main() {
  late MockSavedArticleDao dao;
  late MockAuthRepository auth;
  late SavedArticleRepositoryImpl repository;

  final entity = buildUserArticle(id: 'doc-1');
  final model = SavedArticleModel.fromEntity(entity, ownerId: user.id);

  setUpAll(() => registerFallbackValue(model));

  setUp(() {
    dao = MockSavedArticleDao();
    auth = MockAuthRepository();
    when(() => auth.currentUser).thenReturn(user);
    repository = SavedArticleRepositoryImpl(dao, auth);
  });

  test('every operation is filed under the signed-in account', () async {
    when(() => dao.getArticles(user.id)).thenAnswer((_) async => [model]);
    when(() => dao.insertArticle(any())).thenAnswer((_) async {});
    when(() => dao.deleteById(user.id, 'doc-1')).thenAnswer((_) async {});
    when(() => dao.findById(user.id, 'doc-1')).thenAnswer((_) async => model);

    final listed = await repository.getSavedArticles();
    expect(listed.dataOrNull, [entity]);
    expect(listed.dataOrNull!.single, isNot(isA<SavedArticleModel>()));

    await repository.saveArticle(entity);
    final inserted = verify(() => dao.insertArticle(captureAny())).captured.single as SavedArticleModel;
    expect(inserted.ownerId, user.id);

    expect((await repository.removeArticle('doc-1')).isSuccess, isTrue);
  });

  test('without a session there is no owner to file under', () async {
    when(() => auth.currentUser).thenReturn(null);

    final result = await repository.getSavedArticles();

    expect(result.failureOrNull?.type, FailureType.unauthenticated);
    verifyNever(() => dao.getArticles(any()));
  });

  test('a database error is reported as unknown, not thrown', () async {
    when(() => dao.getArticles(any())).thenThrow(Exception('disk'));

    final result = await repository.getSavedArticles();

    expect(result, isA<DataFailed<List<ArticleEntity>>>());
    expect(result.failureOrNull?.type, FailureType.unknown);
  });

}
