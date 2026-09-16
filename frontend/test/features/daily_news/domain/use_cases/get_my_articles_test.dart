import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_my_articles.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockUserArticleRepository userArticles;
  late MockAuthRepository auth;
  late GetMyArticlesUseCase useCase;

  setUp(() {
    userArticles = MockUserArticleRepository();
    auth = MockAuthRepository();
    useCase = GetMyArticlesUseCase(userArticles, auth);
  });

  test('fails with unauthenticated when nobody is signed in', () async {
    when(() => auth.currentUser).thenReturn(null);

    final result = await useCase(const NoParams());

    expect(result.failureOrNull?.type, FailureType.unauthenticated);
    verifyNever(() => userArticles.getArticlesByAuthor(any()));
  });

  test('asks for the signed-in author articles', () async {
    final own = buildUserArticle(authorId: user.id);
    when(() => auth.currentUser).thenReturn(user);
    when(() => userArticles.getArticlesByAuthor(user.id))
        .thenAnswer((_) async => DataSuccess([own]));

    final result = await useCase(const NoParams());

    expect(result.dataOrNull, [own]);
  });
}
