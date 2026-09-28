import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';

class ImagePickerFieldWidget extends StatelessWidget {
  final File? selectedImage;
  final ValueChanged<File> onImagePicked;

  static const double _height = 180;

  const ImagePickerFieldWidget({
    super.key,
    required this.selectedImage,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickAndCropImage(context),
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: selectedImage != null ? _buildSelectedImage() : _buildEmptyPlaceholder(context),
      ),
    );
  }


  Future<void> _pickAndCropImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (!context.mounted) return; 

    final cropped = await _cropImage(context, picked.path);
    if (cropped != null) {
      onImagePicked(File(cropped.path));
    }
  }


  Future<CroppedFile?> _cropImage(BuildContext context, String sourcePath) {
    final colorScheme = Theme.of(context).colorScheme;
    return ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar imagen',
          toolbarColor: colorScheme.surface,
          toolbarWidgetColor: colorScheme.onSurface,
          activeControlsWidgetColor: colorScheme.secondary,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Ajustar imagen',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
  }


  Widget _buildSelectedImage() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: GlobalTheme.kInk, width: 1)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(selectedImage!, fit: BoxFit.cover),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildChangeImageLabel()),
        ],
      ),
    );
  }

  Widget _buildChangeImageLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: GlobalTheme.kInk.withValues(alpha: 0.75),
      child: const Text(
        'TOCA PARA CAMBIAR',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: GlobalTheme.kPaper,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }


  Widget _buildEmptyPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: GlobalTheme.kRule, width: 1.5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, color: colorScheme.onSurface.withValues(alpha: 0.5), size: 22),
          const SizedBox(height: 8),
          Text(
            'ADJUNTAR IMAGEN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}