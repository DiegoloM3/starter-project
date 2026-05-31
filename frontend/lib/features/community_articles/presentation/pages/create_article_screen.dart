import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/community_article_entity.dart';
import '../../domain/params/community_article_params.dart';
import '../bloc/editor/community_article_editor_bloc.dart';
import '../bloc/editor/community_article_editor_event.dart';
import '../bloc/editor/community_article_editor_state.dart';

const _kCategories = [
  'Politics',
  'Technology',
  'Economy',
  'Community',
  'Opinion',
  'Architecture',
  'Local News',
];

/// Create / Edit article screen using flutter_quill for the body editor.
class CreateArticleScreen extends HookWidget {
  const CreateArticleScreen({super.key, this.article});

  final CommunityArticleEntity? article;

  @override
  Widget build(BuildContext context) {
    final headlineCtrl = useTextEditingController(text: article?.title ?? '');
    final quillCtrl = useMemoized(
      () => _quillControllerFromContent(article?.content),
      [article?.content],
    );
    final selectedCategory = useState<String?>(
      _categoryValueFor(article?.category),
    );
    final focusNode = useFocusNode();

    useEffect(() {
      return quillCtrl.dispose;
    }, [quillCtrl]);

    useEffect(() {
      headlineCtrl.text = article?.title ?? '';
      selectedCategory.value = _categoryValueFor(article?.category);

      final editorBloc = context.read<CommunityArticleEditorBloc>();
      final existingArticle = article;
      if (existingArticle != null) {
        editorBloc.add(CommunityArticleEditorLoaded(existingArticle));
      } else {
        editorBloc.add(const CommunityArticleEditorResetRequested());
      }

      return null;
    }, [article?.id, article?.title, article?.category]);

    return BlocConsumer<
      CommunityArticleEditorBloc,
      CommunityArticleEditorState
    >(
      listener: (context, state) {
        switch (state.status) {
          case CommunityArticleEditorStatus.success:
            _clearDraft(headlineCtrl, quillCtrl, selectedCategory);
            context.read<CommunityArticleEditorBloc>().add(
              const CommunityArticleEditorResetRequested(),
            );
            _closeEditor(context);
          case CommunityArticleEditorStatus.failure:
            context.showSnackBar(
              state.failure?.message ?? 'Something went wrong.',
              isError: true,
            );
          case _:
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: context.colorScheme.onSurface),
              onPressed: () {
                _clearDraft(headlineCtrl, quillCtrl, selectedCategory);
                context.read<CommunityArticleEditorBloc>().add(
                  const CommunityArticleEditorResetRequested(),
                );
                _closeEditor(context);
              },
            ),
            centerTitle: true,
            title: Text(
              'DRAFT ARTICLE',
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: context.colorScheme.onSurface,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ElevatedButton(
                  onPressed:
                      state.status == CommunityArticleEditorStatus.submitting
                      ? null
                      : () => _onPublishPressed(
                          context,
                          state,
                          headlineCtrl.text,
                          quillCtrl,
                          selectedCategory.value,
                          state.selectedImageFile,
                          state.removeImage,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.outlineVariant,
                    disabledForegroundColor:
                        context.colorScheme.onSurfaceVariant,
                    minimumSize: const Size(96, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    textStyle: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  child: state.status == CommunityArticleEditorStatus.submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('PUBLISH'),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                TextField(
                  controller: headlineCtrl,
                  maxLines: null,
                  style: GoogleFonts.newsreader(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    height: 1.08,
                    color: context.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Headline goes here...',
                    hintStyle: GoogleFonts.newsreader(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      height: 1.08,
                      color: context.colorScheme.outline,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'CATEGORY',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCategory.value,
                      hint: Text(
                        'Select editorial section...',
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      onChanged: (v) => selectedCategory.value = v,
                      items: _kCategories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: GoogleFonts.workSans(
                                  fontSize: 14,
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'COVER MEDIA',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                _CoverImagePicker(
                  imageFile: state.selectedImageFile,
                  imageUrl: state.removeImage ? null : article?.imageUrl,
                  onPickImage: () => context
                      .read<CommunityArticleEditorBloc>()
                      .add(const CommunityArticleCoverImagePickRequested()),
                  onRemoveImage: () =>
                      context.read<CommunityArticleEditorBloc>().add(
                        CommunityArticleCoverImageRemoveRequested(
                          hadExistingImage: article?.imageUrl != null,
                        ),
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'BODY',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Container(
                        color: context.colorScheme.surfaceContainerLow,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: QuillSimpleToolbar(
                          controller: quillCtrl,
                          config: const QuillSimpleToolbarConfig(
                            showBoldButton: true,
                            showItalicButton: true,
                            showHeaderStyle: true,
                            showQuote: true,
                            showLink: true,
                            showUnderLineButton: false,
                            showStrikeThrough: false,
                            showListNumbers: true,
                            showListBullets: true,
                            showIndent: false,
                            showAlignmentButtons: false,
                            showCodeBlock: false,
                            showInlineCode: false,
                            showSearchButton: false,
                            showFontFamily: false,
                            showFontSize: false,
                            showBackgroundColorButton: false,
                            showColorButton: false,
                            showClearFormat: false,
                            showDividers: true,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      SizedBox(
                        height: 420,
                        child: QuillEditor.basic(
                          controller: quillCtrl,
                          focusNode: focusNode,
                          config: QuillEditorConfig(
                            placeholder: 'Begin writing...',
                            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                            customStyles: DefaultStyles(
                              paragraph: DefaultTextBlockStyle(
                                GoogleFonts.newsreader(
                                  fontSize: 18,
                                  height: 1.45,
                                  color: context.colorScheme.onSurface,
                                ),
                                const HorizontalSpacing(0, 0),
                                const VerticalSpacing(0, 10),
                                const VerticalSpacing(0, 0),
                                null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onPublishPressed(
    BuildContext context,
    CommunityArticleEditorState state,
    String title,
    QuillController quillController,
    String? category,
    File? imageFile,
    bool removeImage,
  ) {
    if (state.status == CommunityArticleEditorStatus.submitting) {
      return;
    }

    final trimmedTitle = title.trim();
    final plainText = quillController.document.toPlainText().trim();
    if (trimmedTitle.isEmpty || plainText.isEmpty) {
      context.showSnackBar('Title and content are required.', isError: true);
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      context.showSnackBar('Please sign in to publish.', isError: true);
      return;
    }

    final existingArticle = article;
    final content = _quillControllerToJson(quillController);
    if (existingArticle == null) {
      context.read<CommunityArticleEditorBloc>().add(
        CommunityArticlePublishRequested(
          CreateArticleParams(
            title: trimmedTitle,
            content: content,
            authorId: authState.user.uid,
            authorName: authState.user.displayName ?? authState.user.email,
            description: plainText,
            imageFile: imageFile,
            category: category,
          ),
        ),
      );
      return;
    }

    context.read<CommunityArticleEditorBloc>().add(
      CommunityArticleUpdateRequested(
        UpdateArticleParams(
          id: existingArticle.id,
          authorId: authState.user.uid,
          title: trimmedTitle,
          content: content,
          description: plainText,
          imageFile: imageFile,
          removeImage: removeImage,
          category: category,
        ),
      ),
    );
  }
}

void _closeEditor(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }

  context.go('/community');
}

void _clearDraft(
  TextEditingController headlineController,
  QuillController quillController,
  ValueNotifier<String?> selectedCategory,
) {
  headlineController.clear();
  quillController.clear();
  selectedCategory.value = null;
}

class _CoverImagePicker extends StatelessWidget {
  const _CoverImagePicker({
    required this.imageFile,
    required this.imageUrl,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  bool get _hasImage =>
      imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPickImage,
      child: Container(
        width: double.infinity,
        height: 168,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLowest,
          border: Border.all(color: AppColors.outlineVariant, width: 1.5),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageFile != null)
              Image.file(imageFile!, fit: BoxFit.cover)
            else if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(imageUrl!, fit: BoxFit.cover)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 26,
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add a cover image',
                      style: GoogleFonts.workSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to choose an image from your gallery.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            if (_hasImage)
              Positioned(
                right: 8,
                top: 8,
                child: IconButton.filled(
                  onPressed: onRemoveImage,
                  icon: const Icon(Icons.close, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            if (_hasImage)
              Positioned(
                left: 12,
                bottom: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      'Change cover',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

QuillController _quillControllerFromContent(String? content) {
  if (content == null || content.trim().isEmpty) {
    return QuillController.basic();
  }

  try {
    final decoded = jsonDecode(content);
    final List<dynamic>? operations = switch (decoded) {
      final List<dynamic> ops => ops,
      final Map<String, dynamic> map => map['ops'] as List<dynamic>?,
      _ => null,
    };

    if (operations != null) {
      return QuillController(
        document: Document.fromJson(operations),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  } catch (_) {
    // Existing community articles may contain plain text from the previous editor.
  }

  final controller = QuillController.basic();
  controller.document.insert(0, content);
  return controller;
}

String _quillControllerToJson(QuillController controller) {
  return jsonEncode(controller.document.toDelta().toJson());
}

String? _categoryValueFor(String? category) {
  if (category == null || category.trim().isEmpty) {
    return null;
  }

  for (final option in _kCategories) {
    if (option.toLowerCase() == category.trim().toLowerCase()) {
      return option;
    }
  }

  return null;
}
