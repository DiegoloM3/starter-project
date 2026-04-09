import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/core/constants/dimens.dart';
import 'package:news_app_clean_architecture/core/extensions/context_extensions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/button/base_button.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/button/button_size.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/button/loading_button.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/text_field/base_markdown_text_field.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/text_field/base_text_field.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

class PublishArticle extends StatelessWidget {
  const PublishArticle({
    super.key,
    required this.onPublishSuccess,
  });

  final VoidCallback onPublishSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RemoteArticlesBloc>(),
      child: _PublishArticleBody(onPublishSuccess: onPublishSuccess),
    );
  }
}

class _PublishArticleBody extends StatefulWidget {
  const _PublishArticleBody({required this.onPublishSuccess});

  final VoidCallback onPublishSuccess;

  @override
  State<_PublishArticleBody> createState() => _PublishArticleBodyState();
}

class _PublishArticleBodyState extends State<_PublishArticleBody> {
  final _titleController = TextEditingController();
  final _articleController = TextEditingController();

  bool _isLoading = false;
  bool _titleIsEmpty = false;
  bool _photoIsEmpty = false;
  bool _articleIsEmpty = false;

  XFile? _photo;

  static const _imageHeight = 200.0;

  @override
  void dispose() {
    _titleController.dispose();
    _articleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return BlocListener<RemoteArticlesBloc, RemoteArticlesState>(
      listenWhen: (previous, current) =>
          current is RemoteArticlesDone &&
          current.status != RemoteArticleStatus.none,
      listener: (context, state) {
        switch (state.status) {
          case RemoteArticleStatus.createdArticleSuccess:
            context.pop();
            context.showSnackBar(
              message: AppLocalizations.of(context).published_article,
              backgroundColor: Colors.black,
            );

            widget.onPublishSuccess();

            break;
          case RemoteArticleStatus.genericError:
            context.pop();
            context.showSnackBar(
              message: AppLocalizations.of(context).generic_error,
              backgroundColor: Colors.red,
            );

            break;
          case RemoteArticleStatus.none:
            break;
        }
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          top: Dimens.l,
          start: Dimens.screenPaddingHorizontal,
          end: Dimens.screenPaddingHorizontal,
          bottom: MediaQuery.of(context).viewInsets.bottom + Dimens.l,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BaseTextField(
                controller: _titleController,
                hint: AppLocalizations.of(context).write_your_title_here,
                errorText: _titleIsEmpty
                    ? AppLocalizations.of(context).required_field
                    : null,
                maxLength: 100,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: Dimens.m,
                ),
                child: Column(
                  children: [
                    if (_photo == null)
                      BaseButton(
                        text: AppLocalizations.of(context).attach_image,
                        leftSvgPath: 'assets/svgs/camera_plus.svg',
                        size: ButtonSize.small,
                        onTap: () async {
                          final photo = await _pickImage();

                          setState(() {
                            _photo = photo;
                          });
                        },
                      ),
                    if (_photoIsEmpty)
                      Text(
                        AppLocalizations.of(context).required_field,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    if (_photo != null)
                      GestureDetector(
                        onTap: () async {
                          final photo = await _pickImage();

                          setState(() {
                            _photo = photo;
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(
                            Dimens.cardRadius,
                          ),
                          child: Image.file(
                            File(_photo!.path),
                            width: double.maxFinite,
                            height: _imageHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: Dimens.m,
                ),
                child: BaseMarkdownTextField(
                  controller: _articleController,
                  hint: AppLocalizations.of(context).add_article_here,
                  maxLines: 5,
                  errorText: _articleIsEmpty
                      ? AppLocalizations.of(context).required_field
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: Dimens.l),
                child: LoadingButton(
                  text: AppLocalizations.of(context).publish_article,
                  onTap: () {
                    final userState = context.read<LoginBloc>().state;
                    final titleIsEmpty = _titleController.text.isEmpty;
                    final articleIsEmpty = _articleController.text.isEmpty;

                    if (!_isLoading &&
                        (titleIsEmpty || articleIsEmpty || _photo == null)) {
                      setState(() {
                        _titleIsEmpty = titleIsEmpty;
                        _articleIsEmpty = articleIsEmpty;
                        _photoIsEmpty = _photo == null;
                      });
                    } else if (!_isLoading && userState is LoggedIn) {
                      setState(() {
                        _isLoading = true;
                      });

                      final article = ArticleEntity(
                        author: userState.user.email,
                        title: _titleController.text,
                        description: _articleController.text.substring(
                          0,
                          _articleController.text.length > 200
                              ? 200
                              : _articleController.text.length,
                        ),
                        content: _articleController.text,
                        publishedAt: DateTime.now().toString(),
                      );

                      context.read<RemoteArticlesBloc>().add(
                            CreateArticle(
                              article: article,
                              image: File(_photo!.path),
                            ),
                          );
                    }
                  },
                  isLoading: _isLoading,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<XFile?> _pickImage() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
    );

    return photo;
  }
}
