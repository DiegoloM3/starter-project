import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/app_design_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article_draft.dart';
import '../../bloc/article/publish/publish_article_cubit.dart';
import '../../bloc/article/publish/publish_article_state.dart';
import '../../widgets/article_content_editor.dart';
import '../../widgets/article_thumbnail_preview.dart';
import '../../widgets/attach_image_button.dart';
import '../../widgets/field_error_text.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/outlined_text_area.dart';
import '../../widgets/publish_article_bar.dart';
import 'article_draft_error_messages.dart';

class PublishArticleView extends StatelessWidget {
  static const double horizontalMargin = 26;
  static const double titleBoxHeight = 114;
  static const double minContentBoxHeight = 248;

  static const List<ArticleDraftError> _titleErrors = [ArticleDraftError.emptyTitle, ArticleDraftError.titleTooLong];
  static const List<ArticleDraftError> _contentErrors = [
    ArticleDraftError.emptyContent,
    ArticleDraftError.contentTooLong,
  ];

  static const TextStyle _titleStyle = TextStyle(fontFamily: AppFonts.inter, fontSize: 24, color: Colors.black);
  static const TextStyle _titleHintStyle =
      TextStyle(fontFamily: AppFonts.inter, fontSize: 24, fontWeight: FontWeight.w300, color: AppColors.hintText);
  static const TextStyle _contentStyle =
      TextStyle(fontFamily: AppFonts.inter, fontSize: 16, height: 22 / 16, color: AppColors.contentText);
  static const TextStyle _contentHintStyle =
      TextStyle(fontFamily: AppFonts.inter, fontSize: 16, fontWeight: FontWeight.w300, color: AppColors.hintText);

  const PublishArticleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PublishArticleCubit>(),
      child: BlocConsumer<PublishArticleCubit, PublishArticleState>(
        listener: _onStateChanged,
        builder: _buildPage,
      ),
    );
  }

  Widget _buildPage(BuildContext context, PublishArticleState state) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(hasScrollBody: false, child: _buildForm(context, state)),
              ],
            ),
          ),
          bottomNavigationBar: PublishArticleBar(onPressed: () => _onPublishPressed(context)),
        ),
        if (state.isPublishing) const LoadingOverlay(message: 'Publishing article…'),
      ],
    );
  }

  Widget _buildForm(BuildContext context, PublishArticleState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBackButton(context),
        const SizedBox(height: 13),
        _buildTitleSection(context, state),
        _buildThumbnailSection(context, state),
        Expanded(child: _buildContentSection(context, state)),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.pop(context),
        icon: SvgPicture.asset('assets/icons/back.svg', width: 24, height: 24),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, PublishArticleState state) {
    return _buildMarginedColumn([
      SizedBox(
        height: titleBoxHeight,
        child: OutlinedTextArea(
          hintText: 'Write your title here...',
          textStyle: _titleStyle,
          hintStyle: _titleHintStyle,
          maxLength: ArticleDraftEntity.maxTitleLength,
          hasError: _hasTitleError(state),
          onChanged: context.read<PublishArticleCubit>().changeTitle,
        ),
      ),
      ..._findErrors(state, _titleErrors).map(FieldErrorText.new),
    ]);
  }

  Widget _buildThumbnailSection(BuildContext context, PublishArticleState state) {
    final thumbnailPath = state.thumbnailPath;
    if (thumbnailPath != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 26),
        child: ArticleThumbnailPreview(imagePath: thumbnailPath, onTap: () => _onPickThumbnailPressed(context)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 36),
      child: Column(
        children: [
          AttachImageButton(onPressed: () => _onPickThumbnailPressed(context)),
          ..._findErrors(state, [ArticleDraftError.missingThumbnail]).map(FieldErrorText.new),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, PublishArticleState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildMarginedColumn([
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minContentBoxHeight),
            child: ArticleContentEditor(
              hintText: 'Add article here, .....',
              textStyle: _contentStyle,
              hintStyle: _contentHintStyle,
              maxLength: ArticleDraftEntity.maxContentLength,
              hasError: _hasContentError(state),
              onChanged: context.read<PublishArticleCubit>().changeContent,
            ),
          ),
        ),
        ..._findErrors(state, _contentErrors).map(FieldErrorText.new),
      ]),
    );
  }

  Widget _buildMarginedColumn(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  bool _hasTitleError(PublishArticleState state) {
    return _findErrors(state, _titleErrors).isNotEmpty;
  }

  bool _hasContentError(PublishArticleState state) {
    return _findErrors(state, _contentErrors).isNotEmpty;
  }

  List<String> _findErrors(PublishArticleState state, List<ArticleDraftError> fieldErrors) {
    return state.validationErrors.where(fieldErrors.contains).map((error) => error.message).toList();
  }

  void _onPickThumbnailPressed(BuildContext context) {
    context.read<PublishArticleCubit>().pickThumbnail();
  }

  void _onPublishPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<PublishArticleCubit>().publish();
  }

  void _onStateChanged(BuildContext context, PublishArticleState state) {
    if (state.status == PublishArticleStatus.published) {
      _showMessage(context, 'Article published successfully.');
      Navigator.pop(context, true);
    } else if (state.status == PublishArticleStatus.failure) {
      _showMessage(context, 'Something went wrong. Please try again.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.black, content: Text(message)),
    );
  }
}
