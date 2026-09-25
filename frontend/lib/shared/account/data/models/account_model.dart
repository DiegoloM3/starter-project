import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_provider.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.isGuest,
    super.email,
    super.displayName,
    super.photoUrl,
    super.signInProvider,
  });

  factory AccountModel.fromRawData(Map<String, dynamic> data) {
    return AccountModel(
      id: data['uid'] as String? ?? '',
      isGuest: data['isAnonymous'] as bool? ?? true,
      email: data['email'] as String?,
      displayName: _normalizedName(data['displayName']),
      photoUrl: data['photoURL'] as String?,
      signInProvider: _providerFor(data['providerIds']),
    );
  }

  /// A blank string isn't a real name -- Firebase itself has returned one
  /// for at least one account seen during testing, likely a leftover from
  /// before this feature set a real display name. Every consumer
  /// (`ProfileHeader`'s title, `initialsFor`, the byline suggestion) reads
  /// `displayName == null` as "no name" already, so collapsing blank to
  /// null here, once, is simpler than guarding it again in each of them.
  static String? _normalizedName(Object? raw) {
    final name = (raw as String?)?.trim();
    return (name == null || name.isEmpty) ? null : name;
  }

  /// Firebase's provider ids: 'google.com' for Google, 'password' for email.
  static SignInProvider? _providerFor(Object? providerIds) {
    final ids = providerIds is List ? providerIds : const [];
    if (ids.contains('google.com')) return SignInProvider.google;
    if (ids.contains('password')) return SignInProvider.email;
    return null;
  }

  AccountEntity toEntity() {
    return AccountEntity(
      id: id,
      isGuest: isGuest,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      signInProvider: signInProvider,
    );
  }
}
