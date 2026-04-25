import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/ui_parameters.dart';
import '../../../../../core/services/media_service.dart';
import '../../../../../core/utils/datetime_extensions.dart';
import '../../../../../injection_container.dart';
import '../../../data/data_sources/remote/firebase_storage_service.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/add_article/remote/remote_add_article_bloc.dart';
import '../../bloc/add_article/remote/remote_add_article_event.dart';
import '../../bloc/add_article/remote/remote_add_article_state.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/image_picker_section.dart';

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

  ArticleEntity _createArticleEntity(String? imageUrl) {
    return ArticleEntity(
      title: _titleController.text,
      description: _descController.text,
      urlToImage: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null,
      publishedAt: DateTime.now().toUtc().toIso8601Short(),
      content: _contentController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteAddArticleBloc>(
      create: (_) => sl<RemoteAddArticleBloc>(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<RemoteAddArticleBloc, RemoteAddArticleState>(
            listener: (context, state) {
              if (state is AIImageSuccess) {
                setState(() {
                  _selectedImage = null;
                  _imageController.text = state.imageUrl;
                });
              }
              if (state is AIImageError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('AI Error: ${state.message}'),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isGenerating = state is AIImageLoading;
              return PopScope(
                canPop: !isGenerating,
                onPopInvokedWithResult: (bool didPop, Object? result) {
                  if (didPop) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please wait until the AI generation is finished',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Scaffold(
                  appBar: _buildAppbar(context),
                  body: _buildBody(context, isGenerating),
                ),
              );
            },
          );
        },
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

  Widget _buildBody(BuildContext context, bool isGenerating) {
    return Padding(
      padding: const EdgeInsets.all(UIParameters.paddingM),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Enter article title',
            ),
            UIParameters.sBoxVS,
            CustomTextField(
              controller: _descController,
              label: 'Description',
              hint: 'Enter description',
            ),
            UIParameters.sBoxVS,
            CustomTextField(
              controller: _contentController,
              label: 'Content',
              hint: 'Full article content',
              maxLines: 6,
            ),
            UIParameters.sBoxVS,
            CustomTextField(
              controller: _imageController,
              label: 'Image URL',
              hint: 'Paste image link (optional)',
            ),
            UIParameters.sBoxVM,
            ImagePickerSection(
              isGenerating: isGenerating,
              preview: _getPreviewImage(),
              onTap: () => _showImageSourceOptions(
                  context, context.read<RemoteAddArticleBloc>()),
            ),
            UIParameters.sBoxVM,
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  void _showImageSourceOptions(
      BuildContext context, RemoteAddArticleBloc bloc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            UIParameters.paddingS,
          ),
        ),
      ),
      builder: (modalContext) {
        return BlocProvider.value(
          value: bloc,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                  title: const Text('Generate with AI (Demo)'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _generateAIImage(bloc);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _pickImage(AppImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _pickImage(AppImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _generateAIImage(RemoteAddArticleBloc bloc) {
    final content = _contentController.text.isNotEmpty
        ? _contentController.text
        : _titleController.text;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter title or content for the AI')),
      );
      return;
    }

    bloc.add(GenerateAIImageEvent(content));
  }

  ImageProvider? _getPreviewImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (_imageController.text.isNotEmpty &&
        _imageController.text.startsWith('http')) {
      return CachedNetworkImageProvider(_imageController.text);
    }
    return null;
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

  void _onSavePressed(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
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

        final article = _createArticleEntity(finalImageUrl);
        context.read<LocalArticleBloc>().add(SaveArticle(article));

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article saved successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving article: $e')),
        );
      }
    }
  }
}
