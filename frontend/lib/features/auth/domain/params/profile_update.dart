import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/shared/media/domain/entities/local_image.dart';

/// What the Edit profile form can change. A `null` field means "leave it".
class ProfileUpdate extends Equatable {
  final String? displayName;

  /// A new photo picked on the device.
  final LocalImage? photo;

  const ProfileUpdate({this.displayName, this.photo});

  String? get trimmedDisplayName => displayName?.trim();

  bool get isEmpty => trimmedDisplayName == null && photo == null;

  List<CredentialValidationError> validate() {
    final name = trimmedDisplayName;
    if (name == null) return const [];
    if (name.isEmpty) return const [CredentialValidationError.emptyDisplayName];
    if (name.length < CredentialRules.displayNameMinLength) {
      return const [CredentialValidationError.shortDisplayName];
    }
    if (name.length > CredentialRules.displayNameMaxLength) {
      return const [CredentialValidationError.longDisplayName];
    }
    return const [];
  }

  @override
  List<Object?> get props => [displayName, photo];
}
