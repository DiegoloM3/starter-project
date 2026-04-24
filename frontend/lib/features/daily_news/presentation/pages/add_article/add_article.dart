import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/ui_parameters.dart';
import '../../../../../core/services/media_service.dart';
import '../../../../../core/utils/datetime_extensions.dart';
import '../../../../../injection_container.dart';
import '../../../data/data_sources/remote/firebase_storage_service.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class AddArticle extends StatefulWidget {
  const AddArticle({Key? key}) : super(key: key);

  @override
  State<AddArticle> createState() => _AddArticleState();
}

class _AddArticleState extends State<AddArticle> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageController = TextEditingController();

  File? _selectedImage;

  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _contentController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(AppImageSource source) async {
    try {
      final File? image = await sl<MediaService>().pickImage(source);

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _imageController.text = image.path.split('/').last;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            UIParameters.paddingS,
          ),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(AppImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(AppImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onSavePressed(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        String? finalImageUrl = _imageController.text;

        if (_selectedImage != null) {
          final storageService = sl<FirebaseStorageService>();
          finalImageUrl =
              await storageService.uploadArticleImage(_selectedImage!);
        }

        final article = ArticleEntity(
          title: _titleController.text,
          description: _descController.text,
          urlToImage: finalImageUrl.isNotEmpty ? finalImageUrl : null,
          publishedAt: DateTime.now().toUtc().toIso8601Short(),
          content: _contentController.text,
        );

        context.read<LocalArticleBloc>().add(SaveArticle(article));

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article saved successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        setState(() => _isUploading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving article: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isUploading,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait until the upload is finished'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Scaffold(
        appBar: _buildAppbar(context),
        body: _buildBody(context),
      ),
    );
  }

  _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Add New Article',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(UIParameters.paddingM),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildTextField(
              _titleController,
              'Title',
              'Enter article title',
            ),
            UIParameters.sBoxVS,
            _buildTextField(
              _descController,
              'Description',
              'Enter description',
            ),
            UIParameters.sBoxVS,
            _buildTextField(
              _contentController,
              'Content',
              'Full article content',
              maxLines: 6,
            ),
            UIParameters.sBoxVS,
            _buildTextField(
              _imageController,
              'Image URL',
              'Paste image link (optional)',
            ),
            UIParameters.sBoxVM,
            _buildImagePickerSection(),
            UIParameters.sBoxVM,
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _isUploading ? null : () => _showImageSourceOptions(context),
          child: Container(
            width: double.infinity,
            height: UIParameters.imagePickerHeight,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: UIParameters.borderCard,
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: _buildImagePreviewContent(), // Lógica extraída
          ),
        ),
        if (_selectedImage != null && !_isUploading) _buildRemoveButton(),
      ],
    );
  }

  Widget _buildImagePreviewContent() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: UIParameters.borderCard,
        child: Image.file(_selectedImage!, fit: BoxFit.cover),
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: UIParameters.iconSizeXL,
          color: Colors.grey,
        ),
        UIParameters.sBoxVS,
        Text(
          "Tap to select image",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () => setState(() => _selectedImage = null),
        icon: const Icon(
          Icons.delete_outline,
          size: 20,
        ),
        label: const Text(
          "Remove image",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
      ),
      onPressed: () => _onSavePressed(context),
      child: const Text(
        'Save Article',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
