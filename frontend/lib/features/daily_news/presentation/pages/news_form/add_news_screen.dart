import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/news_form/news_form_view.dart';

class AddNewsScreen extends StatelessWidget {
  const AddNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsFormBloc(),
      child: const NewsFormView(),
    );
  }
}
