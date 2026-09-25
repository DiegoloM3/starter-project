import 'package:equatable/equatable.dart';

import 'sign_in_provider.dart';

/// Connecting a sign-in method to a guest keeps the same [id], so articles
/// written as a guest keep their owner. [displayName] and [photoUrl] come
/// from the connected provider (Google has both; email/password has neither).
class AccountEntity extends Equatable {
  final String id;
  final bool isGuest;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final SignInProvider? signInProvider;

  const AccountEntity({
    required this.id,
    required this.isGuest,
    this.email,
    this.displayName,
    this.photoUrl,
    this.signInProvider,
  });

  @override
  List<Object?> get props =>
      [id, isGuest, email, displayName, photoUrl, signInProvider];
}
