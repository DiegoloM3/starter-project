<<<<<<< HEAD
=======
import 'package:cached_network_image/cached_network_image.dart';
>>>>>>> fbce432 (Finish PR (project setup))
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
<<<<<<< HEAD
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);
=======
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/widgets/app_snackbar.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity article;

  const ArticleDetailsView({Key? key, required this.article}) : super(key: key);
>>>>>>> fbce432 (Finish PR (project setup))

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
<<<<<<< HEAD
      create: (_) => sl<LocalArticleBloc>(),
=======
      create: (_) => sl<LocalArticlesBloc>(),
>>>>>>> fbce432 (Finish PR (project setup))
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleTitleAndDate(),
          _buildArticleImage(),
          _buildArticleDescription(),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          // Title
          Text(
            article!.title!,
            style: const TextStyle(
                fontFamily: 'Butler',
                fontSize: 20,
                fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 14),
          // DateTime
=======
          Text(
            article.title,
            style: const TextStyle(
              fontFamily: 'Butler',
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
>>>>>>> fbce432 (Finish PR (project setup))
          Row(
            children: [
              const Icon(Ionicons.time_outline, size: 16),
              const SizedBox(width: 4),
              Text(
<<<<<<< HEAD
                article!.publishedAt!,
=======
                article.publishedAt ?? 'Unknown date',
>>>>>>> fbce432 (Finish PR (project setup))
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
<<<<<<< HEAD
=======
    final url = article.urlToImage;
>>>>>>> fbce432 (Finish PR (project setup))
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
<<<<<<< HEAD
      child: Image.network(article!.urlToImage!, fit: BoxFit.cover),
=======
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 64),
            )
          : const Icon(Icons.image_not_supported, size: 64),
>>>>>>> fbce432 (Finish PR (project setup))
    );
  }

  Widget _buildArticleDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
<<<<<<< HEAD
        '${article!.description ?? ''}\n\n${article!.content ?? ''}',
=======
        '${article.description ?? ''}\n\n${article.content ?? ''}',
>>>>>>> fbce432 (Finish PR (project setup))
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _onFloatingActionButtonPressed(context),
        child: const Icon(Ionicons.bookmark, color: Colors.white),
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
<<<<<<< HEAD
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.black,
        content: Text('Article saved successfully.'),
      ),
    );
=======
    BlocProvider.of<LocalArticlesBloc>(context).add(SaveArticle(article));
    AppSnackbar.success(context, 'Article saved successfully.');
>>>>>>> fbce432 (Finish PR (project setup))
  }
}
