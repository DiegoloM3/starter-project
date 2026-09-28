import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/create/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/article_detail/article_detail.dart';

/// Page hosting the create-article form and its [CreateArticleBloc].
class CreateArticlePage extends StatelessWidget {
  const CreateArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateArticleBloc>(),
      child: const _CreateArticleView(),
    );
  }
}

class _CreateArticleView extends StatefulWidget {
  const _CreateArticleView();

  @override
  State<_CreateArticleView> createState() => _CreateArticleViewState();
}

class _CreateArticleViewState extends State<_CreateArticleView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      // Cap pixel dimensions: imageQuality only shrinks JPEG bytes, so
      // without this a 12MP camera photo (≈48MB decoded) is uploaded and
      // later decoded at full resolution in ~130px list tiles.
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  void _removeImage() => setState(() => _pickedImage = null);

  // ── Publish ───────────────────────────────────────────────────────────────

  void _onPublish(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<CreateArticleBloc>().add(
          PublishArticle(
            title: _titleController.text,
            content: _contentController.text,
            imageFile: _pickedImage,
          ),
        );
  }

  // ── Preview ───────────────────────────────────────────────────────────────

  /// Opens a read-only preview of the draft. No validation: an unfinished
  /// draft must still be previewable. The raw markdown passes through
  /// untouched, exactly as it will be stored on publish.
  void _onPreview(BuildContext context) {
    final preview = ArticleEntity(
      authorDisplayName: 'You',
      title: _titleController.text,
      urlToImage: null,
      publishedAt: 'Preview',
      content: _contentController.text,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailsView(
          article: preview,
          previewImageFile: _pickedImage,
          hideSaveButton: true,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateArticleBloc, CreateArticleState>(
      listener: _onStateChanged,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: const Icon(Ionicons.chevronBack, color: Colors.black),
      ),
      title: const Text('New Article'),
      actions: [
        BlocBuilder<CreateArticleBloc, CreateArticleState>(
          builder: (context, state) {
            if (state is CreateArticleLoading) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: CupertinoActivityIndicator(),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: () => _onPublish(context),
                child: const Text(
                  'Publish',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(),
            const SizedBox(height: 24),
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildContentField(),
            const SizedBox(height: 16),
            _buildPreviewButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────────────────────

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Title'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Butler',
            color: Colors.black87,
          ),
          decoration: const InputDecoration(
            hintText: 'Write your headline...',
            hintStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Butler',
              color: Color(0xFFBDBDBD),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          maxLines: 3,
          minLines: 1,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Title is required.' : null,
        ),
        const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Thumbnail'),
        const SizedBox(height: 10),
        _pickedImage == null ? _buildImagePlaceholder() : _buildImagePreview(),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.imageOutline, size: 40, color: Color(0xFFBDBDBD)),
            SizedBox(height: 8),
            Text(
              'Tap to add a thumbnail',
              style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _pickedImage!,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
        // Remove button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Ionicons.close, size: 18, color: Colors.white),
            ),
          ),
        ),
        // Change button
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Ionicons.swapHorizontalOutline,
                      size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Change',
                      style:
                          TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Content'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
          decoration: const InputDecoration(
            hintText: 'Tell your story...',
            hintStyle:
                TextStyle(color: Color(0xFFBDBDBD), fontSize: 16),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          maxLines: null,
          minLines: 8,
          keyboardType: TextInputType.multiline,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Content is required.' : null,
        ),
        const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
        const SizedBox(height: 4),
        const Text(
          'Styling with markdown is supported.',
          style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }

  // ── Preview button ────────────────────────────────────────────────────────

  Widget _buildPreviewButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _onPreview(context),
        icon: const Icon(Ionicons.eyeOutline, size: 18),
        label: const Text('Preview'),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: Color(0xFF9E9E9E),
      ),
    );
  }

  void _onStateChanged(BuildContext context, CreateArticleState state) {
    if (state is CreateArticleSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text('Article published successfully!'),
        ),
      );
      Navigator.pop(context);
    }

    if (state is CreateArticleError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(state.message),
        ),
      );
      context
          .read<CreateArticleBloc>()
          .add(const ResetCreateArticle());
    }
  }
}
