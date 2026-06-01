import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingRoleSelected extends OnboardingState {
  final String role;
  const OnboardingRoleSelected(this.role);

  @override
  List<Object?> get props => [role];
}

class OnboardingComplete extends OnboardingState {
  const OnboardingComplete();
}

class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
