import 'dart:io';

import 'package:equatable/equatable.dart';

class ImageItem extends Equatable {
  final File? file;
  final String? url;

  const ImageItem({this.file, this.url});

  @override
  List<Object?> get props => [file?.path, url];
}
