import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/presentation/widgets/article_tile.dart';

void main() {
  const tArticle = ArticleEntity(
    id: 'user-article-1',
    authorDisplayName: 'Camilo',
    title: 'Test de un articulo',
    urlToImage: 'https://example.com/large-photo.jpg',
    publishedAt: '2026-09-27T12:11:50.732200',
    content: 'offline copy',
  );

  testWidgets(
      'tile bounds image decode size (regression: full-res camera uploads '
      'must not decode at native resolution in ~130px tiles)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ArticleWidget(article: tArticle)),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.memCacheWidth, 400);
  });

  testWidgets(
      'long ISO timestamp does not overflow the tile on narrow screens '
      '(regression: user-created publishedAt overflowed the date row)',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Short title/content isolate the date row: vertical fit of multi-line
    // titles under test-font metrics is a separate concern.
    const tLongDateArticle = ArticleEntity(
      id: 'user-article-1',
      authorDisplayName: 'Camilo',
      title: 'Short title',
      urlToImage: 'https://example.com/large-photo.jpg',
      publishedAt: '2026-09-27T12:11:50.732200',
      content: 'Short content',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ArticleWidget(article: tLongDateArticle)),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
