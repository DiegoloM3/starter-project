import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/upload_article_cubit.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/upload_article_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class AddArticlePage extends StatefulWidget {
  const AddArticlePage({Key? key}) : super(key: key);

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _authorController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _urlController = TextEditingController();
  final _urlToImageController = TextEditingController();

  @override
  void dispose() {
    _authorController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    _urlToImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UploadArticleCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Article', style: TextStyle(color: Colors.black)),
        ),
        body: BlocConsumer<UploadArticleCubit, UploadArticleState>(
          listener: (context, state) {
            if (state is UploadArticleSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Article uploaded successfully')),
              );
              Navigator.pop(context);
            }

            if (state is UploadArticleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInput(
                      controller: _authorController,
                      label: 'Author',
                      minLength: 2,
                    ),
                    const SizedBox(height: 12),
                    _buildInput(
                      controller: _titleController,
                      label: 'Title',
                      minLength: 5,
                    ),
                    const SizedBox(height: 12),
                    _buildInput(
                      controller: _descriptionController,
                      label: 'Description',
                      minLength: 10,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _buildInput(
                      controller: _contentController,
                      label: 'Content',
                      minLength: 30,
                      maxLines: 8,
                    ),
                    const SizedBox(height: 12),
                    _buildInput(
                      controller: _urlController,
                      label: 'Article URL (optional)',
                      required: false,
                    ),
                    const SizedBox(height: 12),
                    _buildInput(
                      controller: _urlToImageController,
                      label: 'Image URL',
                      minLength: 5,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is UploadArticleLoading
                            ? null
                            : () => _onSubmit(context),
                        child: state is UploadArticleLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Publish Article'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    int minLength = 1,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final current = value?.trim() ?? '';
        if (!required && current.isEmpty) {
          return null;
        }
        if (current.isEmpty) {
          return '$label is required';
        }
        if (current.length < minLength) {
          return '$label must have at least $minLength characters';
        }
        return null;
      },
    );
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final article = UploadArticleEntity(
      author: _authorController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      content: _contentController.text.trim(),
      url: _urlController.text.trim(),
      urlToImage: _urlToImageController.text.trim(),
    );

    context.read<UploadArticleCubit>().upload(article);
  }
}
