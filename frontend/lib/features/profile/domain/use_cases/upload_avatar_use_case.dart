import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/profile/domain/repository/profile_repository.dart';

class UploadAvatarParams extends Equatable {
  final File imageFile;
  final String userId;

  const UploadAvatarParams({required this.imageFile, required this.userId});

  @override
  List<Object?> get props => [imageFile, userId];
}

class UploadAvatarUseCase
    implements UseCase<DataState<String>, UploadAvatarParams> {
  final ProfileRepository _repository;

  UploadAvatarUseCase(this._repository);

  @override
  Future<DataState<String>> call(UploadAvatarParams params) {
    return _repository.uploadAvatar(params.imageFile, params.userId);
  }
}
