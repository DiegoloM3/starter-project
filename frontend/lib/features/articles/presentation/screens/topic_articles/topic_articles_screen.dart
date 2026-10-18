import 'package:flutter/material.dart';

import '../../../../../config/routes/routes.dart';
import '../../../domain/entities/topic_trend.dart';
import '../../widgets/article_list.dart';
import '../../widgets/topic_names.dart';

/// Articles of a trending topic from the last week, newest first.
class TopicArticlesScreen extends StatelessWidget {
  final TopicTrend trend;

  const TopicArticlesScreen({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(trend.topic.displayName)),
      body: ArticleList(
        articles: trend.articles,
        onArticleTap: (article) => Navigator.of(context).pushNamed(AppRoutes.articleDetail, arguments: article),
      ),
    );
  }
}
