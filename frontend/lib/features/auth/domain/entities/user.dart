import 'package:news_app_clean_architecture/core/util/value_equality.dart';
import 'package:news_app_clean_architecture/core/util/initials.dart';

/// Journalist signed in to the app.
class UserEntity with ValueEquality {
  final String id;
  final String name;
  final String email;

  const UserEntity({required this.id, required this.name, required this.email});

  /// Letters for the avatar: "Jane Doe" → "JD". Without a name, the first letter of the email is used.
  String get initials {
    final nameInitials = initialsOf(name);
    if (nameInitials.isNotEmpty) return nameInitials;
    return email.isEmpty ? '?' : email[0].toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, email];
}
