import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/article_upload_form.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/publishing_overlay.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class ArticleUploadPage extends StatelessWidget {
  const ArticleUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UploadArticleBloc, UploadArticleState>(
      listenWhen: (prev, curr) =>
          curr.isPublished != prev.isPublished || curr.error != prev.error,
      listener: (context, state) {
        if (state.isPublished) {
          context.go('/');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).publishedSnack)),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!.localizedMessage)),
          );
        }
      },
      child: BlocBuilder<UploadArticleBloc, UploadArticleState>(
        builder: (context, state) {
          final t = AppLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(t.newArticleTitle),
              actions: [
                TextButton(
                  onPressed: state.isPublishing
                      ? null
                      : () => context
                          .read<UploadArticleBloc>()
                          .add(const SaveDraftManuallyEvent()),
                  child: Text(t.saveDraftAction),
                ),
              ],
            ),
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
                  : const Icon(Icons.send_outlined),
              label: Text(state.isPublishing ? 'Publishing…' : 'Publish'),
            ),
          );
        },
      ),
    );
  }
}

