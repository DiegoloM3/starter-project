import 'package:equatable/equatable.dart';

import '../entities/auth_failures.dart';

/// Input of `UpdateDisplayNameUseCase`.
class UpdateDisplayNameParams extends Equatable {
  /// The longest a byline may be. Long enough for any real name, short enough
  /// that it cannot push an article's author line off the screen.
  static const int maxLength = 50;

  final String displayName;

  const UpdateDisplayNameParams(this.displayName);

  List<CredentialsValidationError> validate() {
    final trimmed = displayName.trim();

    if (trimmed.isEmpty || trimmed.length > maxLength) {
      return const [CredentialsValidationError.displayNameInvalid];
    }

    return const [];
  }

  @override
  List<Object?> get props => [displayName];
}
