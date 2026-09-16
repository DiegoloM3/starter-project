import 'package:equatable/equatable.dart';

/// A signed-in journalist.
class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Name to show in the UI and to sign articles with. Falls back to the part
  /// of the email before `@`, then to a neutral label.
  String get preferredName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final mail = email?.trim();
    if (mail != null && mail.contains('@')) return mail.split('@').first;

    return 'Journalist';
  }

  /// First word of [preferredName], for greetings.
  String get firstName => preferredName.split(RegExp(r'\s+')).first;

  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  UserEntity copyWith({String? email, String? displayName, String? photoUrl}) {
    return UserEntity(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}
