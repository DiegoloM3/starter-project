import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_draft_entity.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/article_upload_cubit.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/article_upload_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/validators/article_form_validators.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/thumbnail_picker_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/app_snackbar.dart';

class ComposeSheet extends StatelessWidget {
  const ComposeSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _ComposeSheetView();
  }
}

class _ComposeSheetView extends StatefulWidget {
  const _ComposeSheetView({Key? key}) : super(key: key);

  @override
  State<_ComposeSheetView> createState() => _ComposeSheetViewState();
}

class _ComposeSheetViewState extends State<_ComposeSheetView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _localThumbnailPath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _titleController.addListener(_onFormChanged);
    _contentController.addListener(_onFormChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForExistingDraft());
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _contentController.removeListener(_onFormChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _hasThumbnail => _localThumbnailPath != null;

  bool get _isFormReady => ArticleFormValidators.isFormReady(
        title: _titleController.text,
        content: _contentController.text,
        hasThumbnail: _hasThumbnail,
      );

  void _onFormChanged() {
    setState(() {});
    context.read<ArticleUploadCubit>().scheduleDraftSave(
          title: _titleController.text,
          content: _contentController.text,
          tags: const [],
          thumbnailLocalPath: _localThumbnailPath,
        );
  }

  Future<void> _checkForExistingDraft() async {
    final draft = await context.read<ArticleUploadCubit>().loadExistingDraft();
    if (draft == null || draft.isEmpty || !mounted) return;
    _showRestoreDraftDialog(draft);
  }

  void _showRestoreDraftDialog(ArticleDraftEntity draft) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Draft found'),
        content: const Text('You have an unsaved draft. Continue editing?'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ArticleUploadCubit>().discardDraft();
              Navigator.of(ctx).pop();
            },
            child: const Text('Discard', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _restoreDraft(draft);
              context.read<ArticleUploadCubit>().notifyDraftRestored();
            },
            child: const Text('Continue', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _restoreDraft(ArticleDraftEntity draft) {
    _titleController.text = draft.title;
    _contentController.text = draft.content;
    if (draft.thumbnailLocalPath != null) {
      setState(() => _localThumbnailPath = draft.thumbnailLocalPath);
    }
  }

  void _submit() {
    final user = FirebaseAuth.instance.currentUser;
    context.read<ArticleUploadCubit>().submitArticle(
          title: _titleController.text,
          content: _contentController.text,
          authorId: user?.uid ?? 'anonymous',
          authorName: user?.displayName ?? 'Anonymous',
          tags: const [],
        );
  }

  void _onThumbnailPicked(String path) {
    setState(() => _localThumbnailPath = path);
    final user = FirebaseAuth.instance.currentUser;
    context.read<ArticleUploadCubit>().pickAndUploadThumbnail(
          localFilePath: path,
          authorId: user?.uid ?? 'anonymous',
        );
    _onFormChanged();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticleUploadCubit, ArticleUploadState>(
      listener: (context, state) {
        if (state is ArticleUploadSuccess) {
          HapticFeedback.heavyImpact();
          Navigator.of(context).pop(true);
        }
        if (state is ArticleUploadFailure) {
          AppSnackbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              _buildHeader(state),
              const Divider(height: 1, color: AppColors.surfaceBorder),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      ThumbnailPickerWidget(
                        isLoading: state is ArticleUploadThumbnailLoading,
                        thumbnailUrl: state is ArticleUploadThumbnailReady
                            ? state.thumbnailUrl
                            : null,
                        onImagePicked: _onThumbnailPicked,
                      ),
                      const SizedBox(height: 16),
                      _buildContentField(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(ArticleUploadState state) {
    final isLoading = state is ArticleUploading;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ),
          const Spacer(),
          const Text(
            'New Article',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: (_isFormReady && !isLoading) ? _submit : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Publish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: const InputDecoration(
        hintText: 'Write your title here...',
        hintStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textHint,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: null,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        height: 1.6,
      ),
      decoration: const InputDecoration(
        hintText: 'Write your article...',
        hintStyle: TextStyle(fontSize: 15, color: AppColors.textHint),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: null,
      minLines: 5,
    );
  }

  Widget _buildBottomBar(ArticleUploadState state) {
    final isLoading = state is ArticleUploading;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: _isFormReady ? AppColors.accent : AppColors.surface,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: 14 + MediaQuery.of(context).padding.bottom,
      ),
      child: GestureDetector(
        onTap: (_isFormReady && !isLoading) ? _submit : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            else
              Icon(
                Icons.arrow_forward,
                color: _isFormReady ? Colors.white : AppColors.textHint,
                size: 18,
              ),
            const SizedBox(width: 8),
            Text(
              isLoading ? 'Publishing...' : 'Publish Article',
              style: TextStyle(
                color: _isFormReady ? Colors.white : AppColors.textHint,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
