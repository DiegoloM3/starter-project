import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_article_by_id.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/article_upload_form.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/publishing_overlay.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class ArticleEditPage extends StatefulWidget {
  final String articleId;

  const ArticleEditPage({super.key, required this.articleId});

  @override
  State<ArticleEditPage> createState() => _ArticleEditPageState();
}

class _ArticleEditPageState extends State<ArticleEditPage> {
  late final Stream<JournalistArticleEntity?> _stream;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _stream = sl<WatchArticleByIdUseCase>().call(params: widget.articleId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UploadArticleBloc, UploadArticleState>(
      listenWhen: (prev, curr) =>
          curr.isPublished != prev.isPublished || curr.error != prev.error,
      listener: (context, state) {
        if (state.isPublished) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).savedSnack)),
          );
          context.pop();
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!.localizedMessage)),
          );
        }
      },
      child: StreamBuilder<JournalistArticleEntity?>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final article = snapshot.data;
          if (article == null) {
            return Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.of(context).editArticleTitle)),
              body: Center(child: Text(AppLocalizations.of(context).articleDetailNotFound)),
            );
          }
          final currentUid = sl<FirebaseAuth>().currentUser?.uid;
          if (currentUid == null || article.userId != currentUid) {
            return Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.of(context).editArticleTitle)),
              body: const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "You don't have permission to edit this article.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          if (!_loaded) {
            _loaded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context
                  .read<UploadArticleBloc>()
                  .add(LoadArticleForEditEvent(article));
            });
          }
          return BlocBuilder<UploadArticleBloc, UploadArticleState>(
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(title: Text(AppLocalizations.of(context).editArticleTitle)),
                body: Stack(
                  children: [
                    ArticleUploadForm(state: state),
                    if (state.isPublishing) const PublishingOverlay(),
                  ],
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: state.isPublishing
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          context
                              .read<UploadArticleBloc>()
                              .add(const PublishEvent());
                        },
                  icon: state.isPublishing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(state.isPublishing ? 'Saving…' : 'Save changes'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
