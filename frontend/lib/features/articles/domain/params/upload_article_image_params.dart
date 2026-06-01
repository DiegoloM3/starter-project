import 'dart:io';
import 'package:equatable/equatable.dart';

class UploadArticleImageParams extends Equatable {
  final String userId;
  final File imageFile;
  final bool isVertical;

  const UploadArticleImageParams({
    required this.userId,
    required this.imageFile,
    required this.isVertical,
  });

  @override
  List<Object?> get props => [userId, imageFile, isVertical];
}
