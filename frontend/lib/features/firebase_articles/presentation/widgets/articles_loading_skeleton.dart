import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/constants/dimensions.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/widgets/article_tile_skeleton.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/widgets/featured_article_skeleton.dart';

class ArticlesLoadingSkeleton extends StatelessWidget {
  const ArticlesLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.screenPadding,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            const FeaturedArticleSkeleton(),
            ...List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: ArticleTileSkeleton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
