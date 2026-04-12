import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/user_profile/user_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/news_form/news_form_view.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class AddNewsScreen extends StatelessWidget {
  const AddNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsFormBloc(
        createArticleUseCase: sl(),
        updateArticleUseCase: sl(),
        deleteArticleUseCase: sl(),
        authorName: sl<UserProfileCubit>().state.displayName ??
            kDefaultAuthorName,
      ),
      child: const NewsFormView(),
    );
  }
}
