import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isVerified;
  final int reputationScore;
  final String? bio;

  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isVerified = false,
    this.reputationScore = 0,
    this.bio,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, isVerified, reputationScore, bio];
}
