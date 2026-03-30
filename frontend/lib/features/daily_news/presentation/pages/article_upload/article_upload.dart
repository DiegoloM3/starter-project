import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/upload_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/upload_article_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class ArticleUploadPage extends StatefulWidget {
  const ArticleUploadPage({Key? key}) : super(key: key);

  @override
  State<ArticleUploadPage> createState() => _ArticleUploadPageState();
}

class _ArticleUploadPageState extends State<ArticleUploadPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UploadArticleCubit>(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
      ),
    );
  }

  _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Publish Article', style: TextStyle(color: Colors.black)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  _buildBody() {
    return BlocConsumer<UploadArticleCubit, UploadArticleState>(
      listener: (context, state) {
        if (state is UploadArticleDone) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article Published!')),
          );
          Navigator.pop(context);
        }
        if (state is UploadArticleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        }
      },
      builder: (context, state) {
        if (state is UploadArticleLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(_titleController, 'Title', maxLines: 2),
              const SizedBox(height: 16),
              _buildTextField(_authorController, 'Author'),
              const SizedBox(height: 16),
              _buildTextField(_descController, 'Description', maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(_contentController, 'Content', maxLines: 10),
              const SizedBox(height: 16),
              _buildTextField(_imageUrlController, 'Image URL (Optional)'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _onUploadPressed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Publish Article', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }

  void _onUploadPressed(BuildContext context) {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and author')),
      );
      return;
    }

    final article = ArticleEntity(
      title: _titleController.text,
      author: _authorController.text,
      description: _descController.text,
      content: _contentController.text,
      urlToImage: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
      publishedAt: DateTime.now().toIso8601String(),
    );

    context.read<UploadArticleCubit>().uploadArticle(article);
  }
}
