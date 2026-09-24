import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/remote/firestore_article_service.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/models/journalist_article_model.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';

/// Stand in for the one class that talks to Firestore.
///
/// It exists so `JournalistArticleRepositoryImpl` can be tested for what it
/// is actually responsible for — turning provider errors into the domain's
/// failures — without a Firestore instance or an emulator in the loop.
///
/// Like the real service it *throws*, and it throws what the real one throws:
/// a [RemoteException] carrying Firestore's code. Faking it needs nothing of
/// the Firestore SDK, which is what rule 1.2.4 buys.
class FakeFirestoreArticleService implements FirestoreArticleService {
  /// Thrown by whichever method is called next, when set.
  Object? errorToThrow;

  /// Returned by [getArticleById]. Null stands for a document that is not
  /// there, which the real service also reports as null rather than throwing.
  JournalistArticleModel? articleById;

  List<JournalistArticleModel> articles = const [];

  /// What the repository handed down, so a test can assert on the stamps and
  /// conversions the repository applies on the way.
  JournalistArticleModel? lastWritten;
  String? lastDeletedId;
  String? lastViewedId;
  String? lastRenamedUserId;
  String? lastAuthorName;

  /// How many articles [updateAuthorName] claims to have rewritten.
  int renamedCount = 0;

  void _throwIfArmed() {
    final error = errorToThrow;

    if (error != null) {
      throw error;
    }
  }

  @override
  Future<List<JournalistArticleModel>> getUserArticles({
    required String userId,
    ArticleStatus? status,
    String? searchQuery,
  }) async {
    _throwIfArmed();

    return articles;
  }

  @override
  Future<JournalistArticleModel?> getArticleById(String articleId) async {
    _throwIfArmed();

    return articleById;
  }

  @override
  Future<List<JournalistArticleModel>> getPublishedArticles({
    int limit = 10,
    String? authorId,
    String? excludeArticleId,
    String? startAfterArticleId,
    DateTime? publishedAfter,
  }) async {
    _throwIfArmed();

    return articles;
  }

  @override
  Future<JournalistArticleModel> createArticle(
    JournalistArticleModel article,
  ) async {
    _throwIfArmed();
    lastWritten = article;

    return article;
  }

  @override
  Future<JournalistArticleModel> updateArticle(
    JournalistArticleModel article,
  ) async {
    _throwIfArmed();
    lastWritten = article;

    return article;
  }

  @override
  Future<int> updateAuthorName({
    required String userId,
    required String authorName,
  }) async {
    _throwIfArmed();
    lastRenamedUserId = userId;
    lastAuthorName = authorName;

    return renamedCount;
  }

  @override
  Future<void> deleteArticle(String articleId) async {
    _throwIfArmed();
    lastDeletedId = articleId;
  }

  @override
  Future<void> incrementViewCount(String articleId) async {
    _throwIfArmed();
    lastViewedId = articleId;
  }

  /// Anything else the real service grows later fails loudly here rather than
  /// quietly returning null and making a test pass for the wrong reason.
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      '${invocation.memberName} is not faked by FakeFirestoreArticleService',
    );
  }
}

/// A data source error carrying the Firestore code the repository is expected
/// to recognise.
RemoteException firestoreError(String code) => RemoteException(code);
