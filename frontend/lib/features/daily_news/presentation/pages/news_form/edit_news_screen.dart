import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/news_form/news_form_view.dart';

class EditNewsScreen extends StatelessWidget {
  final ArticleEntity article;
  final NewsSection? section;

  const EditNewsScreen({
    super.key,
    required this.article,
    this.section,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsFormBloc(
        existingArticle: article,
        existingSection: section,
      ),
      child: const NewsFormView(),
    );
  }
}
