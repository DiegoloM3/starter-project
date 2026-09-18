import '../../domain/entities/publishable_article.dart';

class PublishableArticleModel extends PublishableArticle {
  const PublishableArticleModel({
    required String id,
    required String author,
    required String title,
    required String description,
    required String content,
    required String thumbnailUrl,
    required DateTime publishedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          author: author,
          title: title,
          description: description,
          content: content,
          thumbnailUrl: thumbnailUrl,
          publishedAt: publishedAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory PublishableArticleModel.fromRawData({
    required String id,
    required Map<String, dynamic> data,
  }) {
    const expectedFields = <String>{
      'author',
      'title',
      'description',
      'content',
      'thumbnailURL',
      'publishedAt',
      'createdAt',
      'updatedAt',
    };

    final hasExpectedFields = data.length == expectedFields.length &&
        expectedFields.every(data.containsKey);

    if (!hasExpectedFields) {
      throw const FormatException(
        'Article data does not match the expected schema.',
      );
    }

    String readString(String field) {
      final value = data[field];

      if (value is! String) {
        throw FormatException(
          'Article field "$field" must be a String.',
        );
      }

      return value;
    }

    DateTime readDateTime(String field) {
      final value = data[field];

      if (value is! DateTime) {
        throw FormatException(
          'Article field "$field" must be a DateTime.',
        );
      }

      return value;
    }

    return PublishableArticleModel(
      id: id,
      author: readString('author'),
      title: readString('title'),
      description: readString('description'),
      content: readString('content'),
      thumbnailUrl: readString('thumbnailURL'),
      publishedAt: readDateTime('publishedAt'),
      createdAt: readDateTime('createdAt'),
      updatedAt: readDateTime('updatedAt'),
    );
  }

  PublishableArticle toEntity() {
    return PublishableArticle(
      id: id,
      author: author,
      title: title,
      description: description,
      content: content,
      thumbnailUrl: thumbnailUrl,
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
