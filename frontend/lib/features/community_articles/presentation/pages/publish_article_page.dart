import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

const _maxImageBytes = 5 * 1024 * 1024; // 5 MB

/// One form, two modes:
///
/// - **Publish mode** (default): empty fields, submit creates a new Firestore
///   document.
/// - **Edit mode**: pass [initialArticle]. Fields are pre-populated, the
///   submit action says "Save", and submit calls `updateArticle` which
///   preserves `publishedAt` and `uid`.
class PublishArticlePage extends StatefulWidget {
  final ArticleEntity? initialArticle;

  const PublishArticlePage({Key? key, this.initialArticle}) : super(key: key);

  bool get isEditMode => initialArticle != null;

  @override
  State<PublishArticlePage> createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contentController;
  final _picker = ImagePicker();

  /// A new image picked locally for upload (overrides any existing image).
  File? _pickedImage;

  /// In edit mode, the URL of the image that the article currently has on
  /// Firestore. Used to (a) show a preview before the user picks a new one,
  /// and (b) tell the data source which old image to clean up after a
  /// successful save. Cleared when the user taps "Remove".
  String? _existingImageUrl;

  bool _submitting = false;
  String? _submitStage; // 'uploading' | 'publishing' | 'saving'

  @override
  void initState() {
    super.initState();
    final initial = widget.initialArticle;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController =
        TextEditingController(text: initial?.description ?? '');
    _contentController = TextEditingController(text: initial?.content ?? '');
    _existingImageUrl = initial?.urlToImage;
  }

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
      setState(() {
        _pickedImage = file;
      });
    } catch (_) {
      if (!mounted) return;
      _showSnack('Could not open the gallery. Try again.');
    }
  }

  void _removeImage() => setState(() {
        _pickedImage = null;
        _existingImageUrl = null;
      });

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
      _submitStage = _pickedImage != null ? 'uploading' : 'saving';
    });

    final cubit = context.read<CommunityFeedCubit>();

    // Upload a new image if the user picked one. In edit mode, this overrides
    // the existing image.
    String? imageUrlForWrite;
    if (_pickedImage != null) {
      try {
        imageUrlForWrite = await cubit.uploadImage(
          uid: uid,
          imageFile: _pickedImage!,
        );
      } catch (_) {
        if (!mounted) return;
        _showSnack(
          'Could not upload image. Try again or save without image.',
        );
        setState(() {
          _submitting = false;
          _submitStage = null;
        });
        return;
      }
    } else {
      // No new image was picked. Use whatever the existing one is (which may
      // be null if the user removed it).
      imageUrlForWrite = _existingImageUrl;
    }

    setState(() => _submitStage = widget.isEditMode ? 'saving' : 'publishing');

    try {
      if (widget.isEditMode) {
        final initial = widget.initialArticle!;
        await cubit.updateArticle(
          firestoreId: initial.firestoreId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          content: _contentController.text.trim(),
          imageUrl: imageUrlForWrite,
          oldImageUrl: initial.urlToImage,
        );
        if (!mounted) return;
        // Return the updated entity so the detail page can refresh in place,
        // preserving firestoreId, uid, and publishedAt from the original.
        final updated = ArticleEntity(
          firestoreId: initial.firestoreId,
          uid: initial.uid,
          publishedAt: initial.publishedAt,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          content: _contentController.text.trim(),
          urlToImage: imageUrlForWrite,
        );
        Navigator.of(context).pop(updated);
      } else {
        await cubit.publish(
          ArticleEntity(
            uid: uid,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            content: _contentController.text.trim(),
            urlToImage: imageUrlForWrite,
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack(
        widget.isEditMode
            ? 'Could not save. Check your connection and try again.'
            : 'Could not publish. Check your connection and try again.',
      );
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

  String _stageLabel() {
    switch (_submitStage) {
      case 'uploading':
        return 'Uploading image…';
      case 'saving':
        return 'Saving…';
      case 'publishing':
        return 'Publishing…';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEditMode;
    final title = isEdit ? 'Edit Article' : 'Publish Article';
    final actionLabel = isEdit ? 'Save' : 'Publish';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: Text(
              actionLabel,
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
                pickedImage: _pickedImage,
                existingImageUrl: _pickedImage == null ? _existingImageUrl : null,
                onPick: _pickImage,
                onRemove: _removeImage,
              ),
              const SizedBox(height: 24),
              if (_submitting)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(_stageLabel()),
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
  /// Local file the user just picked. Wins over [existingImageUrl].
  final File? pickedImage;

  /// URL of the image the article already has (edit mode). Shown only when
  /// no local file has been picked yet.
  final String? existingImageUrl;

  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImagePickerSection({
    required this.pickedImage,
    required this.existingImageUrl,
    required this.onPick,
    required this.onRemove,
  });

  bool get _hasAnyImage =>
      pickedImage != null ||
      (existingImageUrl != null && existingImageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    if (!_hasAnyImage) {
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
          child: pickedImage != null
              ? Image.file(
                  pickedImage!,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: existingImageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 200,
                    color: const Color(0xFFEEEEEE),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: const Color(0xFFEEEEEE),
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined,
                        color: Color(0xFF9E9E9E)),
                  ),
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
