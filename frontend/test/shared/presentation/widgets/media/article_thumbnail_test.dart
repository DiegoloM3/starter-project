import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/article_thumbnail.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/thumbnail_fallback.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('an article without an image gets the typographic fallback in a Hero',
      (tester) async {
    final article = buildArticle(imageUrl: null, category: NewsCategory.science);
    await pumpApp(tester, ArticleThumbnail(article: article));

    expect(find.byType(ThumbnailFallback), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
    expect(tester.widget<Hero>(find.byType(Hero)).tag, ArticleThumbnail.heroTag(article));
  });

}
