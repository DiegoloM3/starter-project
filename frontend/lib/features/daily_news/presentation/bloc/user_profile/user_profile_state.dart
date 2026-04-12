import 'package:equatable/equatable.dart';

class UserProfileState extends Equatable {
  final String? name;
  final String? email;

  const UserProfileState({this.name, this.email});

  String? get displayName =>
      (name != null && name!.isNotEmpty) ? name : null;

  String get displayEmail => email ?? '';

  bool get hasProfile =>
      (name != null && name!.isNotEmpty) ||
      (email != null && email!.isNotEmpty);

  UserProfileState copyWith({String? name, String? email}) {
    return UserProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [name, email];
}
