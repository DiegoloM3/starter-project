import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/repository/auth_service.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/create_article/create_article_cubit.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/create_article/create_article_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

class CreateArticleScreen extends StatelessWidget {
  const CreateArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateArticleCubit>(
      create: (_) => sl<CreateArticleCubit>(),
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
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  late final TextEditingController _authorCtrl;
  final _sourceCtrl = TextEditingController();

  File? _thumbnail;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final auth = sl<AuthService>();
    _authorCtrl = TextEditingController(text: auth.displayName ?? '');
    for (final c in [_titleCtrl, _descriptionCtrl, _contentCtrl, _authorCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _contentCtrl.dispose();
    _authorCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _thumbnail = File(picked.path));
    }
  }

  int get _filledCount {
    int count = 0;
    if (_thumbnail != null) count++;
    if (_titleCtrl.text.trim().isNotEmpty) count++;
    if (_descriptionCtrl.text.trim().isNotEmpty) count++;
    if (_contentCtrl.text.trim().isNotEmpty) count++;
    if (_authorCtrl.text.trim().isNotEmpty) count++;
    return count;
  }

  void _submit() {
    if (_thumbnail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectThumbnail),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final params = CreateArticleParams(
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      thumbnailFile: _thumbnail!,
      sourceName:
          _sourceCtrl.text.trim().isEmpty ? null : _sourceCtrl.text.trim(),
      publishedAt: DateTime.now(),
    );

    context.read<CreateArticleCubit>().submit(params);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.publishArticle),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _filledCount == 5
                    ? colors.primary.withValues(alpha: 0.15)
                    : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_filledCount / 5',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _filledCount == 5 ? colors.primary : colors.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<CreateArticleCubit, CreateArticleState>(
        listener: (context, state) {
          if (state is CreateArticleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.articlePublished),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          }
          if (state is CreateArticleFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.publishFailed(state.reason)),
                backgroundColor: colors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is CreateArticleSubmitting;
          return AbsorbPointer(
            absorbing: isSubmitting,
            child: Column(
              children: [
                if (isSubmitting)
                  LinearProgressIndicator(color: colors.primary),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PremiumThumbnailPicker(
                            file: _thumbnail,
                            onTap: _pickImage,
                          ),
                          const SizedBox(height: 24),
                          const _SectionHeader(
                            icon: Icons.article_outlined,
                            title: 'Article Details',
                          ),
                          const SizedBox(height: 12),
                          _PremiumField(
                            controller: _titleCtrl,
                            label: l10n.titleLabel,
                            hint: 'A compelling headline...',
                            maxLength: 120,
                            prefixIcon: Icons.title,
                            validator: _required(l10n.titleLabel),
                          ),
                          _PremiumField(
                            controller: _descriptionCtrl,
                            label: l10n.descriptionLabel,
                            hint: 'Brief summary of your article...',
                            maxLength: 300,
                            maxLines: 2,
                            prefixIcon: Icons.short_text,
                            validator: _required(l10n.descriptionLabel),
                          ),
                          _PremiumField(
                            controller: _contentCtrl,
                            label: l10n.contentLabel,
                            hint: 'Write your full article here...',
                            maxLength: 20000,
                            maxLines: 8,
                            prefixIcon: Icons.edit_note,
                            validator: _required(l10n.contentLabel),
                          ),
                          const SizedBox(height: 20),
                          const _SectionHeader(
                            icon: Icons.person_outline,
                            title: 'Author Info',
                          ),
                          const SizedBox(height: 12),
                          _PremiumField(
                            controller: _authorCtrl,
                            label: l10n.authorLabel,
                            maxLength: 80,
                            prefixIcon: Icons.badge_outlined,
                            validator: _required(l10n.authorLabel),
                          ),
                          _PremiumField(
                            controller: _sourceCtrl,
                            label: l10n.sourceLabel,
                            hint: 'e.g. Symmetry Newsroom',
                            maxLength: 60,
                            prefixIcon: Icons.link,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CreateArticleCubit, CreateArticleState>(
        builder: (context, state) {
          final isSubmitting = state is CreateArticleSubmitting;
          final ready = _filledCount == 5 && !isSubmitting;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                onPressed: ready ? _submit : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isSubmitting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  isSubmitting ? l10n.publishing : l10n.publish,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  FormFieldValidator<String> _required(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return AppLocalizations.of(context).fieldRequired(label);
      }
      return null;
    };
  }
}

class _PremiumThumbnailPicker extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;

  const _PremiumThumbnailPicker({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: file == null
          ? 'Pick a thumbnail image'
          : 'Thumbnail selected. Tap to change',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 200,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: file != null
                  ? colors.primary.withValues(alpha: 0.5)
                  : colors.outlineVariant,
              width: file != null ? 2 : 1,
            ),
            boxShadow: file != null
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: file == null ? _emptyState(colors) : _filledState(colors),
        ),
      ),
    );
  }

  Widget _emptyState(ColorScheme colors) {
    final hint = colors.onSurface.withValues(alpha: 0.5);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_a_photo_outlined,
                size: 32, color: colors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'Add Cover Image',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to select from gallery',
            style: TextStyle(fontSize: 13, color: hint),
          ),
        ],
      ),
    );
  }

  Widget _filledState(ColorScheme colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(file!, fit: BoxFit.cover),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6)
                ],
              ),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Change image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 16, color: colors.onPrimary),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PremiumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLength;
  final int maxLines;
  final IconData? prefixIcon;
  final FormFieldValidator<String>? validator;

  const _PremiumField({
    required this.controller,
    required this.label,
    this.hint,
    required this.maxLength,
    this.maxLines = 1,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filled = controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(color: colors.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: colors.onSurface.withValues(alpha: 0.35)),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: filled
                      ? colors.primary
                      : colors.onSurface.withValues(alpha: 0.4),
                )
              : null,
          filled: true,
          fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: filled
                  ? colors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.error, width: 2),
          ),
          counterStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
