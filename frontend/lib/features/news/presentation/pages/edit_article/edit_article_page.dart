import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/edit/edit_article_bloc.dart';

/// Page hosting the edit-article form for one [ArticleEntity].
class EditArticlePage extends StatelessWidget {
  final ArticleEntity article;

  const EditArticlePage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EditArticleBloc>(),
      child: _EditArticleView(article: article),
    );
  }
}

class _EditArticleView extends StatefulWidget {
  final ArticleEntity article;

  const _EditArticleView({required this.article});

  @override
  State<_EditArticleView> createState() => _EditArticleViewState();
}

class _EditArticleViewState extends State<_EditArticleView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();
  File? _newImage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article.title ?? '');
    _contentController =
        TextEditingController(text: widget.article.content ?? '');
  }

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
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _newImage = File(picked.path));
    }
  }

  void _revertImage() => setState(() => _newImage = null);

  // ── Save ──────────────────────────────────────────────────────────────────

  void _onSave(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<EditArticleBloc>().add(
          SaveArticleEdits(
            original: widget.article,
            title: _titleController.text,
            content: _contentController.text,
            imageFile: _newImage,
          ),
        );
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> _onDeletePressed(BuildContext context) async {
    final confirmed = await _confirmDelete(context);
    if (confirmed != true || !context.mounted) return;
    context.read<EditArticleBloc>().add(
          DeleteArticleRequested(widget.article),
        );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete article?'),
        content: const Text(
          'This article will be permanently removed. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditArticleBloc, EditArticleState>(
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
      title: const Text('Edit Article'),
      actions: [
        BlocBuilder<EditArticleBloc, EditArticleState>(
          builder: (context, state) {
            if (state is EditArticleLoading) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: CupertinoActivityIndicator(),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: () => _onSave(context),
                child: const Text(
                  'Save',
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
            const SizedBox(height: 32),
            _buildDeleteSection(context),
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
        _newImage != null ? _buildNewImagePreview() : _buildCurrentImage(),
      ],
    );
  }

  Widget _buildCurrentImage() {
    final currentUrl = widget.article.urlToImage;
    if (currentUrl == null || currentUrl.isEmpty) {
      return _buildImagePlaceholder();
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: currentUrl,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            memCacheWidth: 800,
            errorWidget: (_, __, ___) => _buildImagePlaceholder(),
          ),
        ),
        _buildChangeButton(),
      ],
    );
  }

  Widget _buildNewImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _newImage!,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _revertImage,
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
        _buildChangeButton(),
      ],
    );
  }

  Widget _buildChangeButton() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
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

  // ── Delete ────────────────────────────────────────────────────────────────

  Widget _buildDeleteSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<EditArticleBloc, EditArticleState>(
        builder: (context, state) {
          final isLoading = state is EditArticleLoading;
          return OutlinedButton.icon(
            onPressed:
                isLoading ? null : () => _onDeletePressed(context),
            icon: const Icon(Ionicons.trashOutline,
                size: 18, color: Colors.red),
            label: const Text(
              'Delete article',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          );
        },
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

  void _onStateChanged(BuildContext context, EditArticleState state) {
    if (state is EditArticleSaved) {
      Navigator.pop(context, true);
    }

    if (state is EditArticleDeleted) {
      Navigator.pop(context, 'deleted');
    }

    if (state is EditArticleError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(state.message),
        ),
      );
      context.read<EditArticleBloc>().add(const ResetEditArticle());
    }
  }
}
