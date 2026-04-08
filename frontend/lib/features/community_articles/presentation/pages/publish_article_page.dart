import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

const _maxImageBytes = 5 * 1024 * 1024; // 5 MB

class PublishArticlePage extends StatefulWidget {
  const PublishArticlePage({Key? key}) : super(key: key);

  @override
  State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _picker = ImagePicker();

  File? _pickedImage;
  bool _submitting = false;
  String? _submitStage; // 'uploading' | 'publishing'

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      final file = File(picked.path);
      final size = await file.length();
      if (size > _maxImageBytes) {
        if (!mounted) return;
        _showSnack('Image is too large. Pick one under 5 MB.');
        return;
      }
      setState(() => _pickedImage = file);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not open the gallery. Try again.');
    }
  }

  void _removeImage() => setState(() => _pickedImage = null);

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnack('You are not signed in. Restart the app and try again.');
      return;
    }

    setState(() {
      _submitting = true;
      _submitStage = _pickedImage != null ? 'uploading' : 'publishing';
    });

    final cubit = context.read<CommunityFeedCubit>();

    String? imageUrl;
    if (_pickedImage != null) {
      try {
        imageUrl = await cubit.uploadImage(uid: uid, imageFile: _pickedImage!);
      } catch (_) {
        if (!mounted) return;
        _showSnack(
          'Could not upload image. Try again or publish without image.',
        );
        setState(() {
          _submitting = false;
          _submitStage = null;
        });
        return;
      }
    }

    setState(() => _submitStage = 'publishing');

    try {
      await cubit.publish(
        ArticleEntity(
          uid: uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          content: _contentController.text.trim(),
          urlToImage: imageUrl,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not publish. Check your connection and try again.');
      setState(() {
        _submitting = false;
        _submitStage = null;
      });
    }
  }

  String? _validateLength(
    String? value, {
    required int min,
    required int max,
    required String label,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$label is required';
    if (trimmed.length < min) return '$label is too short';
    if (trimmed.length > max) return '$label must be ≤ $max characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final stageLabel = _submitStage == 'uploading'
        ? 'Uploading image…'
        : _submitStage == 'publishing'
            ? 'Publishing…'
            : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish Article'),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: Text(
              'Publish',
              style: TextStyle(
                color: _submitting
                    ? const Color(0xFFBBBBBB)
                    : const Color(0xFF1976D2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => _validateLength(
                  v,
                  min: 1,
                  max: 120,
                  label: 'Title',
                ),
                maxLength: 120,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => _validateLength(
                  v,
                  min: 1,
                  max: 280,
                  label: 'Description',
                ),
                maxLength: 280,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                validator: (v) => _validateLength(
                  v,
                  min: 1,
                  max: 5000,
                  label: 'Content',
                ),
                maxLength: 5000,
                minLines: 6,
                maxLines: 12,
              ),
              const SizedBox(height: 16),
              _ImagePickerSection(
                image: _pickedImage,
                onPick: _pickImage,
                onRemove: _removeImage,
              ),
              const SizedBox(height: 24),
              if (_submitting)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    if (stageLabel != null) ...[
                      const SizedBox(height: 8),
                      Text(stageLabel),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  final File? image;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImagePickerSection({
    required this.image,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.image_outlined),
        label: const Text('Add image (optional)'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            image!,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Replace'),
            ),
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }
}
