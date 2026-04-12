import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/draft_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/user_profile/user_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/news_form/news_form_view.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class AddNewsScreen extends StatelessWidget {
  const AddNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DraftArticle?>(
      future: sl<DraftService>().loadDraft(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: context.colors.bgPage,
            body: const Center(child: CupertinoActivityIndicator()),
          );
        }

        final draft = snapshot.data;
        final profileCubit = sl<UserProfileCubit>();
        final authorName = draft?.author ??
            profileCubit.state.displayName ??
            kDefaultAuthorName;

        return BlocProvider(
          create: (_) {
            final bloc = NewsFormBloc(
              createArticleUseCase: sl(),
              updateArticleUseCase: sl(),
              deleteArticleUseCase: sl(),
              draftService: sl(),
              authorName: authorName,
            );
            if (draft != null) {
              bloc
                ..add(NewsFormTitleChanged(draft.title))
                ..add(NewsFormBodyChanged(draft.body));
              if (draft.section != null) {
                final section = NewsSection.values.where(
                  (s) => s.name == draft.section,
                );
                if (section.isNotEmpty) {
                  bloc.add(NewsFormSectionChanged(section.first));
                }
              }
            }
            return bloc;
          },
          child: NewsFormView(hasDraft: draft != null),
        );
      },
    );
  }
}
