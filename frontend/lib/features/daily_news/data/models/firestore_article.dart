import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';

class FirestoreArticleModel extends ArticleEntity {
  const FirestoreArticleModel({
    super.documentId,
    super.title,
    super.author,
    super.description,
    super.content,
    super.section,
    super.images,
    super.userId,
    super.publishedAt,
  });

  factory FirestoreArticleModel.fromRawData(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return FirestoreArticleModel(
      documentId: documentId,
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      description: data['description'] as String?,
      content: data['body'] as String? ?? '',
      section: _parseSectionFromString(data['section'] as String?),
      images: List<String>.from(data['images'] ?? []),
      userId: data['userId'] as String?,
      publishedAt: _parseTimestamp(data['createdAt']),
    );
  }

  factory FirestoreArticleModel.fromEntity(ArticleEntity entity) {
    return FirestoreArticleModel(
      documentId: entity.documentId,
      title: entity.title,
      author: entity.author,
      description: entity.description,
      content: entity.content,
      section: entity.section,
      images: entity.images,
      userId: entity.userId,
      publishedAt: entity.publishedAt,
    );
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      documentId: documentId,
      title: title,
      author: author,
      description: description,
      content: content,
      section: section,
      images: images,
      userId: userId,
      publishedAt: publishedAt,
    );
  }

  /// Converts the model to a Firestore-compatible map.
  ///
  /// Note: `createdAt` is intentionally excluded. The data_source must add it
  /// using `FieldValue.serverTimestamp()` on create operations, per rule 1.2.4.
  Map<String, dynamic> toFirestoreMap() {
    return {
      'title': title ?? '',
      'body': content ?? '',
      'section': _sectionToFirestoreValue(section),
      'author': author ?? '',
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (images.isNotEmpty) 'images': images,
      if (userId != null) 'userId': userId,
    };
  }

  static const _sectionToFirestore = {
    NewsSection.politics: 'politica',
    NewsSection.weather: 'clima',
    NewsSection.sports: 'deportes',
    NewsSection.arts: 'artes',
    NewsSection.crime: 'policiaca',
  };

  static const _firestoreToSection = {
    'politica': NewsSection.politics,
    'clima': NewsSection.weather,
    'deportes': NewsSection.sports,
    'artes': NewsSection.arts,
    'policiaca': NewsSection.crime,
  };

  static String _sectionToFirestoreValue(NewsSection? section) {
    if (section == null) return '';
    return _sectionToFirestore[section] ?? '';
  }

  static NewsSection? _parseSectionFromString(String? value) {
    if (value == null) return null;
    return _firestoreToSection[value];
  }

  /// Parses a Firestore timestamp field into an ISO 8601 string.
  ///
  /// The data_source should convert Firestore [Timestamp] objects to [DateTime]
  /// before passing raw data to [fromRawData]. This method also handles
  /// [DateTime] and [String] for resilience.
  static String? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toIso8601String();
    if (value is String) return value;
    return null;
  }
}
