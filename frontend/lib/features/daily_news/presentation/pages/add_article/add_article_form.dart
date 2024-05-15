import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_form_text_field.dart';

class AddArticleForm extends StatefulWidget {
  const AddArticleForm({super.key});

  @override
  State<AddArticleForm> createState() => _AddArticleFormState();
}

class _AddArticleFormState extends State<AddArticleForm> {
  XFile? _selectedImage;
  final _titleController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildArticleForm(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
      title:
          const Text('Add your Article', style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildArticleForm(BuildContext context) {
    final addArticleFormKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: addArticleFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ArticleFormTextField(
                  controller: _titleController,
                  autofoucs: true,
                  labelText: 'Article Title',
                  validationMessage: 'Please, enter a title.'),
              const SizedBox(
                height: 10.0,
              ),
              ArticleFormTextField(
                  controller: _authorNameController,
                  labelText: 'Author Name',
                  validationMessage: 'Please, enter your author name.'),
              const SizedBox(height: 10.0),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Image.file(File(_selectedImage!.path)),
                ),
              const SizedBox(height: 10.0),
              ElevatedButton.icon(
                onPressed: _uploadImageFromGallery,
                icon: const Icon(Ionicons.cloud_upload_outline),
                label: const Text('Upload your image'),
              ),
              const SizedBox(height: 10.0),
              ArticleFormTextField(
                controller: _descriptionController,
                labelText: 'Article Description',
                validationMessage: 'Please, add an article description.',
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  if (addArticleFormKey.currentState!.validate()) {
                    var article = ArticleEntity(
                      author: _authorNameController.text,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      urlToImage: _selectedImage?.path,
                      publishedAt: DateTime.now().toString(),
                      content: _descriptionController.text.length > 100
                          ? _descriptionController.text.substring(0, 100)
                          : _descriptionController.text,
                    );
                    BlocProvider.of<RemoteArticlesBloc>(context)
                        .add(AddArticle(article));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
                child: const Text('Submit Article'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _uploadImageFromGallery() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        _selectedImage = selectedImage;
      });
    }
  }
}
