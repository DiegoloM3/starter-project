import 'package:equatable/equatable.dart';

abstract class RewardState extends Equatable {
  const RewardState();

  @override
  List<Object?> get props => [];
}

class RewardInitial extends RewardState {}

class RewardClaiming extends RewardState {}

class RewardClaimSuccess extends RewardState {
  final double amount;
  final String message;

  const RewardClaimSuccess(this.amount, this.message);

  @override
  List<Object?> get props => [amount, message];
}

class RewardClaimError extends RewardState {
  final String message;

  const RewardClaimError(this.message);

  @override
  List<Object?> get props => [message];
}
