import 'package:equatable/equatable.dart';

class DraftIdParams extends Equatable {
  final int draftId;

  const DraftIdParams({required this.draftId});

  @override
  List<Object?> get props => [draftId];
}
