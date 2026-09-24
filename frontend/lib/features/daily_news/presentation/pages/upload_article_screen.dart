import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/upload_article/upload_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/upload_article/upload_article_state.dart';

class UploadArticleScreen extends StatefulWidget {
  const UploadArticleScreen({Key? key}) : super(key: key);

  @override
  State<UploadArticleScreen> createState() => _UploadArticleScreenState();
}

class _UploadArticleScreenState extends State<UploadArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isPublished = true;
  XFile? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _handleUpload() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image');
      return;
    }

    context.read<UploadArticleCubit>().uploadArticle(
          title: _titleController.text,
          content: _contentController.text,
          author: _authorController.text,
          thumbnailPath: _selectedImage!.path,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          category: _categoryController.text.isEmpty
              ? null
              : _categoryController.text,
        );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Article'),
        elevation: 0,
      ),
      body: BlocListener<UploadArticleCubit, UploadArticleState>(
        listener: (context, state) {
          if (state is UploadArticleSuccess) {
            _showSuccessSnackBar('Article uploaded successfully');
            _resetForm();
          } else if (state is UploadArticleFailure) {
            _showErrorSnackBar('Upload failed: ${state.error}');
          } else if (state is UploadArticleValidationError) {
            final errorMessages =
                state.errors.values.join('\n');
            _showErrorSnackBar(errorMessages);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<UploadArticleCubit, UploadArticleState>(
            builder: (context, state) {
              final isLoading = state is UploadArticleLoading;

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThumbnailField(),
                    const SizedBox(height: 24),
                    _buildTitleField(),
                    const SizedBox(height: 16),
                    _buildAuthorField(),
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
                    const SizedBox(height: 16),
                    _buildCategoryField(),
                    const SizedBox(height: 16),
                    _buildContentField(),
                    const SizedBox(height: 16),
                    _buildPublishToggle(),
                    const SizedBox(height: 32),
                    if (state is UploadArticleLoading)
                      _buildUploadProgress(state.progress)
                    else
                      _buildUploadButton(isLoading),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailField() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to select thumbnail',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImage!.path),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedImage!.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title',
        hintText: 'Enter article title',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Title is required';
        }
        if (value.length < 5) {
          return 'Title must be at least 5 characters';
        }
        if (value.length > 200) {
          return 'Title must be less than 200 characters';
        }
        return null;
      },
    );
  }

  Widget _buildAuthorField() {
    return TextFormField(
      controller: _authorController,
      decoration: const InputDecoration(
        labelText: 'Author',
        hintText: 'Enter author name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Author is required';
        }
        if (value.length < 2) {
          return 'Author must be at least 2 characters';
        }
        if (value.length > 100) {
          return 'Author must be less than 100 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Enter article description',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Widget _buildCategoryField() {
    return TextFormField(
      controller: _categoryController,
      decoration: const InputDecoration(
        labelText: 'Category (Optional)',
        hintText: 'e.g., Technology, News, etc.',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: 'Content',
        hintText: 'Enter article content',
        border: OutlineInputBorder(),
      ),
      maxLines: 10,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Content is required';
        }
        if (value.length < 20) {
          return 'Content must be at least 20 characters';
        }
        return null;
      },
    );
  }

  Widget _buildPublishToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Publish immediately',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Switch(
          value: _isPublished,
          onChanged: (value) {
            setState(() {
              _isPublished = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildUploadProgress(double progress) {
    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 12),
        Text(
          'Uploading... ${(progress * 100).toStringAsFixed(0)}%',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUploadButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleUpload,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('Upload Article'),
        ),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _contentController.clear();
    _authorController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    setState(() {
      _selectedImage = null;
      _isPublished = true;
    });
  }
}
