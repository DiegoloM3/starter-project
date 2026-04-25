import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/core/constants/colors.dart';
import 'package:news_app_clean_architecture/core/constants/dimensions.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../injection_container.dart';
import '../../../../../shared/article/domain/entities/article.dart';
import '../../../../../shared/widgets/app_cached_image.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../widgets/article_avatar.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
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
        builder: (context) => Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: _CircularButton(
            icon: Icons.arrow_back,
            onTap: () => _onBackButtonTapped(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: AppDimensions.screenPadding,
      child: Column(
        spacing: 20,
        children: [
          _buildArticleImage(),
          _buildArticleTitleAndDate(),
          _buildArticleDescription(),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article!.title!,
            style: const TextStyle(
              fontFamily: 'Butler',
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 20),
          // DateTime
          Row(
            children: [
              ArticleAvatar(
                text: article?.author ?? 'AU',
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Text(
                  article!.author ?? 'Unknown Author',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Text(
                DateFormatter.format(article!.publishedAt!),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: AppCachedImage(
        imageUrl: article!.urlToImage ?? '',
        width: double.infinity,
        height: 250,
        borderRadius: BorderRadius.circular(40),
        heroTag: article!.heroTag,
      ),
    );
  }

  Widget _buildArticleDescription() {
    final description = article!.description ?? '';
    final content = article!.content ?? '';

    final text = [
      if (description.isNotEmpty) description,
      if (content.isNotEmpty) content,
    ].join('\n\n');

    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      style: const TextStyle(fontSize: 16),
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
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.black,
        content: Text('Article saved successfully.'),
      ),
    );
  }
}

class _CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircularButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 15,
              spreadRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 20,
        ),
      ),
    );
  }
}
