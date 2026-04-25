import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? displayName;
  final String? email;
  final bool isAnonymous;

  const UserEntity({
    required this.uid,
    this.displayName,
    this.email,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [uid, displayName, email, isAnonymous];
}
