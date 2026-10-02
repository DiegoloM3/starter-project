import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/hidden_character_counter.dart';
import 'package:news_app_clean_architecture/config/theme/app_glass_pill.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_comment_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/add_article_comment/add_article_comment_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/add_article_comment/add_article_comment_state.dart';

/// Glass pill, like the navigation bar, where the journalist writes a comment and sends it.
/// The text is cleared once the comment is added.
class CommentComposer extends StatefulWidget {
  static const double height = 64;

  const CommentComposer({super.key});

  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddArticleCommentCubit>();
    return BlocConsumer<AddArticleCommentCubit, AddArticleCommentState>(
      listenWhen: (previous, current) => current is AddArticleCommentSuccess,
      listener: (context, state) {
        _controller.clear();
        FocusScope.of(context).unfocus();
      },
      builder: (context, state) => AppGlassPill(
        height: CommentComposer.height,
        padding: const EdgeInsets.only(left: 22, right: 8),
        child: Row(
          children: [
            Expanded(child: _buildTextField(context, cubit)),
            const SizedBox(width: 10),
            _SendButton(
              isSending: state is AddArticleCommentInProgress,
              onPressed: state.draft.isValid ? cubit.send : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, AddArticleCommentCubit cubit) {
    return TextField(
      controller: _controller,
      maxLength: ArticleCommentDraftEntity.maxContentLength,
      buildCounter: hideCharacterCounter,
      textInputAction: TextInputAction.send,
      textCapitalization: TextCapitalization.sentences,
      onChanged: cubit.updateContent,
      onSubmitted: (_) => cubit.send(),
      style: const TextStyle(fontSize: 15),
      decoration: const InputDecoration(
        hintText: 'Write a comment…',
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isCollapsed: true,
      ),
    );
  }

}

class _SendButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback? onPressed;

  const _SendButton({required this.isSending, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isEnabled = onPressed != null && !isSending;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (isEnabled)
            BoxShadow(color: palette.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: IconButton(
        onPressed: isEnabled ? onPressed : null,
        tooltip: 'Send comment',
        style: IconButton.styleFrom(
          fixedSize: const Size.square(48),
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.primary.withValues(alpha: isSending ? 1 : 0.35),
          disabledForegroundColor: palette.onPrimary,
        ),
        icon: isSending
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: palette.onPrimary),
              )
            : const Icon(Ionicons.paperPlaneOutline, size: 20),
      ),
    );
  }
}
