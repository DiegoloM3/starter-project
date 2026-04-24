import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_article_entity.freezed.dart';

/// Publishing status modelled as a Dart enum so the domain never leaks
/// raw strings. Mapping to/from the Firestore `status` field (`draft` |
/// `published`) happens in the data layer.
enum UserArticleStatus { draft, published }

/// A piece of content authored by the currently-signed-in user.
///
/// Pure Dart: no Flutter, Firebase or IO imports. Kept immutable so Cubits
/// can diff state safely.
@freezed
class UserArticleEntity with _$UserArticleEntity {
  const factory UserArticleEntity({
    required String id,
    required String authorId,
    required String authorName,
    required String title,
    required String description,
    required String content,
    required String thumbnailURL,
    required DateTime publishedAt,
    required DateTime updatedAt,
    @Default(UserArticleStatus.draft) UserArticleStatus status,
    @Default(<String>[]) List<String> tags,
  }) = _UserArticleEntity;

  const UserArticleEntity._();

  /// Whether this draft meets the publish criteria enforced both in the
  /// UI (to gate the button) and by the rules (`isValidArticle`).
  bool get canPublish =>
      title.length >= 5 && content.length >= 50 && thumbnailURL.isNotEmpty;

  bool get isPublished => status == UserArticleStatus.published;
}
