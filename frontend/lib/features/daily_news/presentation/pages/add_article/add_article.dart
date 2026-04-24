import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/ui_parameters.dart';

import '../../../../../core/utils/datetime_extensions.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../../domain/entities/article.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: _buildBody(context),
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
                _contentController, 'Content', 'Full article content',
                maxLines: 6),
            UIParameters.sBoxVS,
            _buildTextField(
              _imageController,
              'Image URL',
              'Paste image link (optional)',
            ),
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

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
      onPressed: () => _onSavePressed(context),
      child: const Text('Save Article', style: TextStyle(color: Colors.white)),
    );
  }

  void _onSavePressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final article = ArticleEntity(
        title: _titleController.text,
        description: _descController.text,
        urlToImage:
            _imageController.text.isNotEmpty ? _imageController.text : null,
        publishedAt: DateTime.now().toUtc().toIso8601Short(),
        content: _contentController.text,
      );

      context.read<LocalArticleBloc>().add(SaveArticle(article));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article saved successfully!')),
      );

      Navigator.pop(context);
    }
  }
}
