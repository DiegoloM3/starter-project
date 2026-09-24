import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/edit_article/edit_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/edit_article/edit_article_state.dart';

class EditArticleScreen extends StatefulWidget {
  final String articleId;
  final String initialTitle;
  final String initialContent;
  final String initialAuthor;
  final String? initialDescription;
  final String? initialCategory;
  final String? initialThumbnailPath;

  const EditArticleScreen({
    Key? key,
    required this.articleId,
    required this.initialTitle,
    required this.initialContent,
    required this.initialAuthor,
    this.initialDescription,
    this.initialCategory,
    this.initialThumbnailPath,
  }) : super(key: key);

  @override
  State<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _authorController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  final _imagePicker = ImagePicker();

  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _authorController = TextEditingController(text: widget.initialAuthor);
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _categoryController = TextEditingController(text: widget.initialCategory ?? '');

    if (widget.initialThumbnailPath != null) {
      _selectedImage = XFile(widget.initialThumbnailPath!);
    }
  }

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
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _handleUpdate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<EditArticleCubit>().updateArticle(
      articleId: widget.articleId,
      title: _titleController.text,
      content: _contentController.text,
      author: _authorController.text,
      thumbnailPath: _selectedImage?.path,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      category: _categoryController.text.isEmpty ? null : _categoryController.text,
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
        title: const Text('Edit Article'),
        elevation: 0,
      ),
      body: BlocListener<EditArticleCubit, EditArticleState>(
        listener: (context, state) {
          if (state is EditArticleSuccess) {
            _showSuccessSnackBar('Article updated successfully');
            Navigator.pop(context, state.article);
          } else if (state is EditArticleFailure) {
            _showErrorSnackBar('Update failed: ${state.error}');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<EditArticleCubit, EditArticleState>(
            builder: (context, state) {
              final isLoading = state is EditArticleLoading;

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
                    const SizedBox(height: 32),
                    _buildUpdateButton(isLoading),
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
                  Text(_selectedImage!.name),
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

  Widget _buildUpdateButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleUpdate,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update Article'),
        ),
      ),
    );
  }
}
