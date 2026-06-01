import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';

class PreviewArticleScreen extends StatefulWidget {
  final String title;
  final String categoryId;
  final String bodyJson;
  final String? coverVerticalUrl;
  final String? coverHorizontalUrl;

  const PreviewArticleScreen({
    super.key,
    required this.title,
    required this.categoryId,
    required this.bodyJson,
    this.coverVerticalUrl,
    this.coverHorizontalUrl,
  });

  @override
  State<PreviewArticleScreen> createState() => _PreviewArticleScreenState();
}

class _PreviewArticleScreenState extends State<PreviewArticleScreen> {
  late final QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _quillController = _buildController();
  }

  QuillController _buildController() {
    try {
      final json = jsonDecode(widget.bodyJson);
      final doc = Document.fromJson(json as List);
      return QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      return QuillController.basic();
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl =
        widget.coverHorizontalUrl ?? widget.coverVerticalUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: AppSpacing.coverImageHeight,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: coverUrl != null
                  ? Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => const ColoredBox(
                        color: AppColors.surface,
                      ),
                    )
                  : const ColoredBox(color: AppColors.surface),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PreviewBanner(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(widget.title, style: AppTypography.h1),
                  const SizedBox(height: AppSpacing.xl),
                  QuillEditor.basic(
                    controller: _quillController,
                    config: const QuillEditorConfig(
                      showCursor: false,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.categoryHealthyFood.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.categoryHealthyFood),
      ),
      child: Text(
        'This is a preview — not published yet',
        style: AppTypography.label.copyWith(color: AppColors.textOnYellow),
        textAlign: TextAlign.center,
      ),
    );
  }
}
