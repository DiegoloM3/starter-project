import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/network_failure.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/update_articles_byline.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_byline/article_byline_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_byline/article_byline_state.dart';

import '../../../../../helpers/fake_journalist_article_repository.dart';

void main() {
  late FakeJournalistArticleRepository repository;
  late ArticleBylineCubit cubit;

  setUp(() {
    repository = FakeJournalistArticleRepository();
    cubit = ArticleBylineCubit(UpdateArticlesBylineUseCase(repository));
  });

  tearDown(() => cubit.close());

  test('starts with nothing to report', () {
    expect(cubit.state.status, ArticleBylineStatus.idle);
    expect(cubit.state.renamedCount, 0);
    expect(cubit.state.error, isNull);
  });

  test('says how many articles the rename reached', () async {
    repository.updateAuthorNameResult = const DataSuccess(4);

    await cubit.renameTo(userId: 'journalist-1', authorName: 'Alex Rivera');

    expect(cubit.state.status, ArticleBylineStatus.done);
    expect(cubit.state.renamedCount, 4);
  });

  test('reports itself busy while the rename is in flight', () {
    final states = <ArticleBylineStatus>[];
    cubit.stream.listen((state) => states.add(state.status));

    cubit.renameTo(userId: 'journalist-1', authorName: 'Alex Rivera');

    expect(cubit.state.isWorking, isTrue);
    expect(cubit.state.status, ArticleBylineStatus.working);
  });

  /// Renaming the account and renaming the catalogue are two writes to two
  /// backends, so they can come apart. The screen can only say so if the
  /// second one reports what happened.
  test('keeps the failure so the screen can admit the half rename', () async {
    repository.updateAuthorNameResult =
        const DataFailed(NetworkUnavailableException());

    await cubit.renameTo(userId: 'journalist-1', authorName: 'Alex Rivera');

    expect(cubit.state.status, ArticleBylineStatus.failure);
    expect(cubit.state.error, isA<NetworkUnavailableException>());
    expect(cubit.state.renamedCount, 0);
  });

  test('a later success clears the earlier failure', () async {
    repository.updateAuthorNameResult =
        const DataFailed(NetworkUnavailableException());
    await cubit.renameTo(userId: 'journalist-1', authorName: 'Alex Rivera');

    repository.updateAuthorNameResult = const DataSuccess(2);
    await cubit.renameTo(userId: 'journalist-1', authorName: 'Alex Rivera');

    expect(cubit.state.status, ArticleBylineStatus.done);
    expect(cubit.state.error, isNull);
  });
}
