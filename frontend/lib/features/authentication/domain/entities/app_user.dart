import 'package:equatable/equatable.dart';

/// A person signed in to the app.
///
/// [id] is the backend's user id, and it is what `firestore.rules` compares
/// against an article's `userId`: it is the identity that owns everything a
/// journalist writes.
class AppUserEntity extends Equatable {
  final String id;
  final String email;

  /// Name shown to readers as the article's author. It falls back to
  /// [anonymousName] when the person never chose one.
  final String displayName;

  /// The byline for somebody who did not give a name.
  ///
  /// It used to be the part of the email before the `@`, which published a
  /// piece of somebody's address to every reader — under a field whose whole
  /// point is that filling it in was optional. Leaving the name blank has to
  /// mean anonymous, not "we picked one for you".
  ///
  /// Not translated: it is stored on the article as the byline, and a name
  /// that changed with the reader's language would not be a name.
  static const String anonymousName = 'Anonymous';

  const AppUserEntity({
    required this.id,
    required this.email,
    this.displayName = '',
  });

  AppUserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
  }) {
    return AppUserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  /// Name to publish articles under.
  String get authorName {
    final chosen = displayName.trim();

    return chosen.isEmpty ? anonymousName : chosen;
  }

  @override
  List<Object?> get props => [id, email, displayName];
}
