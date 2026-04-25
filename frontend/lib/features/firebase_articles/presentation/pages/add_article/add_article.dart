import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/core/constants/colors.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_state.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/widgets/markdown_toolbar.dart';

class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key});

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _aiPromptController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _thumbnailFile;
  bool _isGenerating = false;

  @override
  void dispose() {
    _aiPromptController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FirebaseArticlesCubit, FirebaseArticlesState>(
      listener: (context, state) {
        if (state is FirebaseArticleCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('Article published successfully!'),
            ),
          );
          Navigator.pop(context);
        }
        if (state is FirebaseArticlesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(state.message),
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Ionicons.close, color: AppColors.textPrimary),
      ),
      centerTitle: true,
      title: const Text(
        'New Article',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        _buildPublishButton(),
      ],
    );
  }

  Widget _buildPublishButton() {
    return BlocBuilder<FirebaseArticlesCubit, FirebaseArticlesState>(
      builder: (context, state) {
        final isLoading = state is FirebaseArticlesLoading;

        return GestureDetector(
          onTap: isLoading ? null : _handlePublish,
          child: Container(
            margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Publish',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnailPicker(),
          const SizedBox(height: 20),
          _buildAIAssistantCard(),
          const SizedBox(height: 24),
          _buildTitleField(),
          const SizedBox(height: 12),
          _buildDescriptionField(),
          const SizedBox(height: 24),
          _buildContentSection(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildThumbnailPicker() {
    return GestureDetector(
      onTap: _pickThumbnail,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _thumbnailFile == null
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary,
                    AppColors.primary,
                  ],
                )
              : null,
          image: _thumbnailFile != null
              ? DecorationImage(
                  image: FileImage(_thumbnailFile!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _thumbnailFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Ionicons.camera_outline,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to add cover image',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: _pickThumbnail,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Ionicons.pencil,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAIAssistantCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Ionicons.sparkles, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'AI Assistant',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Write a short description or key points',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.captionText,
            ),
          ),
          const SizedBox(height: 10),
          _buildAIPromptField(),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _handleGenerateWithAI,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Ionicons.sparkles, size: 16),
              label: Text(
                _isGenerating ? 'Generating...' : 'Generate with AI',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPromptField() {
    return TextField(
      controller: _aiPromptController,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      maxLines: null,
      minLines: 3,
      decoration: InputDecoration(
        hintText:
            'E.g. The city\'s new tech park will open its doors in October with 50 new startups...',
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 13,
          height: 1.5,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      maxLines: null,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: AppColors.titleDark,
        fontFamily: 'Butler',
      ),
      decoration: const InputDecoration(
        hintText: 'Article title...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintStyle: TextStyle(color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.captionText,
      ),
      maxLines: null,
      decoration: const InputDecoration(
        hintText: 'Write a short description...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintStyle: TextStyle(color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.captionText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        MarkdownToolbar(
          controller: _contentController,
          onImageTap: _pickThumbnail,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          maxLines: null,
          minLines: 12,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Write your article using markdown...\n\n'
                '**Bold text** for emphasis\n'
                '*Italic text* for style\n'
                '- Bullet points for lists',
            hintStyle: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
              height: 1.6,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Future<void> _pickThumbnail() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _thumbnailFile = File(pickedFile.path));
    }
  }

  Future<void> _handleGenerateWithAI() async {
    final prompt = _aiPromptController.text.trim();

    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Write a prompt or key points first'),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final cubit = context.read<FirebaseArticlesCubit>();

      final generated = await cubit.generateArticleContent(prompt);

      await _typewriterEffect(_titleController, generated.title);
      await _typewriterEffect(_descriptionController, generated.description);
      _contentController.text = generated.content;

      final imageFile = await cubit.generateArticleImage(generated.title);

      if (mounted) {
        setState(() => _thumbnailFile = imageFile);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Generation failed: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Generation failed: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _handlePublish() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || description.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Please fill in title, description and content'),
        ),
      );
      return;
    }

    if (_thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Please add a cover image'),
        ),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return;

    context.read<FirebaseArticlesCubit>().createArticle(
          CreateArticleParams(
            title: title,
            description: description,
            content: content,
            author: authState.user.displayName ?? 'Unknown',
            authorId: authState.user.uid,
            thumbnailPath: _thumbnailFile!.path,
          ),
        );
  }

  Future<void> _typewriterEffect(
    TextEditingController controller,
    String text,
  ) async {
    controller.clear();
    for (int i = 0; i < text.length; i++) {
      if (!mounted) return;
      controller.text = text.substring(0, i + 1);
      controller.selection = TextSelection.collapsed(offset: i + 1);
      await Future.delayed(const Duration(milliseconds: 3));
    }
  }
}
