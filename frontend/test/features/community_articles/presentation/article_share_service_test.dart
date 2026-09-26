import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/screens/community_article_detail_screen.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/services/article_share_service.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/services/web_share.dart';

const _article = CommunityArticleEntity(
  id: 'article/42',
  author: 'Reporter',
  title: 'Shared article',
  description: 'A concise summary.',
  url: '',
  urlToImage: '',
  publishedAt: '',
  content: 'The article body.',
  thumbnailPath: '',
  payloadHash: '',
  ownerUid: 'owner-1',
);

class _RecordingShareService implements ArticleShareService {
  String? title;
  String? summary;
  String? articleId;
  Rect? sharePositionOrigin;

  @override
  Future<void> shareArticle({
    required String title,
    required String summary,
    required String articleId,
    Rect? sharePositionOrigin,
  }) async {
    this.title = title;
    this.summary = summary;
    this.articleId = articleId;
    this.sharePositionOrigin = sharePositionOrigin;
  }
}

class _UnavailableShareService implements ArticleShareService {
  @override
  Future<void> shareArticle({
    required String title,
    required String summary,
    required String articleId,
    Rect? sharePositionOrigin,
  }) async {
    throw ArticleShareUnavailable(
      title: title,
      link: articleDeepLink(articleId),
    );
  }
}

class _RejectedShareService implements ArticleShareService {
  @override
  Future<void> shareArticle({
    required String title,
    required String summary,
    required String articleId,
    Rect? sharePositionOrigin,
  }) async {
    throw StateError('navigator.share rejected the request');
  }
}

void main() {
  test('builds an app-relative web deep link without a hosting URL', () {
    expect(
      articleDeepLink(
        'article/42',
        baseUri: Uri.parse('https://news.example.test/'),
      ),
      'https://news.example.test/?article=article%2F42',
    );
    expect(
      articleDeepLink('article/42', baseUri: Uri.parse('file:///tmp/app')),
      'case-study-symmetry://article/article%2F42',
    );
  });

  test('web fallback copies the exact deep link', () async {
    String? copied;
    final service = ClipboardArticleShareService(
      copy: (link) async => copied = link,
    );

    await service.shareArticle(
      title: _article.title,
      summary: _article.description,
      articleId: _article.id,
    );

    expect(copied, articleDeepLink(_article.id));
  });

  test('builds explicit fallback target URLs without launching them', () {
    const link = 'http://localhost:8088/?article=article%2F42';

    final whatsapp = articleShareTargetUri(
      target: ArticleShareTarget.whatsapp,
      title: _article.title,
      link: link,
    );
    expect(whatsapp.scheme, 'https');
    expect(whatsapp.host, 'wa.me');
    expect(
      whatsapp.queryParameters['text'],
      articleShareMessage(title: _article.title, link: link),
    );

    final telegram = articleShareTargetUri(
      target: ArticleShareTarget.telegram,
      title: _article.title,
      link: link,
    );
    expect(telegram.scheme, 'https');
    expect(telegram.host, 't.me');
    expect(telegram.path, '/share/url');
    expect(telegram.queryParameters['url'], link);
    expect(telegram.queryParameters['text'], _article.title);

    final email = articleShareTargetUri(
      target: ArticleShareTarget.email,
      title: _article.title,
      link: link,
    );
    expect(email.scheme, 'mailto');
    expect(email.queryParameters['subject'], _article.title);
    expect(
      email.queryParameters['body'],
      articleShareMessage(title: _article.title, link: link),
    );
  });

  test('recognizes local preview links for fallback guidance', () {
    expect(isLocalShareLink('http://localhost:8088/?article=article%2F42'),
        isTrue);
    expect(isLocalShareLink('http://127.0.0.1:8088/?article=article%2F42'),
        isTrue);
    expect(isLocalShareLink('https://news.example.test/?article=article%2F42'),
        isFalse);
  });

  test('native share includes the title, summary, and deep link', () async {
    String? sharedText;
    String? receivedSubject;
    Rect? receivedOrigin;
    final service = SharePlusArticleShareService(
      share: (text, {String? subject, Rect? sharePositionOrigin}) async {
        sharedText = text;
        receivedSubject = subject;
        receivedOrigin = sharePositionOrigin;
      },
    );

    const origin = Rect.fromLTWH(1, 2, 40, 44);

    await service.shareArticle(
      title: _article.title,
      summary: _article.description,
      articleId: _article.id,
      sharePositionOrigin: origin,
    );

    expect(receivedSubject, _article.title);
    expect(receivedOrigin, origin);
    expect(
      sharedText,
      articleShareText(
        title: _article.title,
        summary: _article.description,
        link: articleDeepLink(_article.id),
      ),
    );
  }, skip: kIsWeb);

  test(
    'web share forwards the title, summary, and link when supported',
    () async {
      String? receivedTitle;
      String? receivedText;
      String? receivedLink;
      final service = SharePlusArticleShareService(
        webShare: ({required title, required text, required link}) async {
          receivedTitle = title;
          receivedText = text;
          receivedLink = link;
          return WebShareStatus.shared;
        },
      );

      await service.shareArticle(
        title: _article.title,
        summary: _article.description,
        articleId: _article.id,
      );

      expect(receivedTitle, _article.title);
      expect(receivedText, _article.description);
      expect(receivedLink, articleDeepLink(_article.id));
    },
    skip: !kIsWeb,
  );

  test('web share treats unsupported browsers as an error', () async {
    final service = SharePlusArticleShareService(
      webShare: ({required title, required text, required link}) async =>
          WebShareStatus.unsupported,
    );

    await expectLater(
      service.shareArticle(
        title: _article.title,
        summary: _article.description,
        articleId: _article.id,
      ),
      throwsA(isA<UnsupportedError>()),
    );
  }, skip: !kIsWeb);

  test('web share treats user dismissal as a completed decision', () async {
    var called = false;
    final service = SharePlusArticleShareService(
      webShare: ({required title, required text, required link}) async {
        called = true;
        return WebShareStatus.dismissed;
      },
    );

    await service.shareArticle(
      title: _article.title,
      summary: _article.description,
      articleId: _article.id,
    );

    expect(called, isTrue);
  }, skip: !kIsWeb);

  test('web share propagates unexpected failures', () async {
    final service = SharePlusArticleShareService(
      webShare: ({required title, required text, required link}) async {
        throw StateError('share failed');
      },
    );

    await expectLater(
      service.shareArticle(
        title: _article.title,
        summary: _article.description,
        articleId: _article.id,
      ),
      throwsA(isA<StateError>()),
    );
  }, skip: !kIsWeb);

  testWidgets('detail share action delegates title, summary, and ID',
      (tester) async {
    final shareService = _RecordingShareService();
    await tester.pumpWidget(
      MaterialApp(
        home: CommunityArticleDetailScreen(
          article: _article,
          shareService: shareService,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Share article'));
    await tester.pump();

    expect(shareService.title, _article.title);
    expect(shareService.summary, _article.description);
    expect(shareService.articleId, _article.id);
    expect(shareService.sharePositionOrigin, isNotNull);
    expect(shareService.sharePositionOrigin!.width, greaterThan(0));
    expect(shareService.sharePositionOrigin!.height, greaterThan(0));
  });

  testWidgets('shows explicit web fallback targets without auto-copying',
      (tester) async {
    final launched = <Uri>[];
    String? copied;
    await tester.pumpWidget(
      MaterialApp(
        home: CommunityArticleDetailScreen(
          article: _article,
          shareService: _UnavailableShareService(),
          copyArticleLink: (link) async => copied = link,
          launchShareOption: (
            url, {
            required mode,
            webOnlyWindowName,
          }) async {
            launched.add(url);
            expect(mode, LaunchMode.externalApplication);
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.byTooltip('Share article'));
    await tester.pumpAndSettle();

    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Copy link'), findsOneWidget);
    expect(launched, isEmpty);
    expect(copied, isNull);

    await tester.tap(find.text('WhatsApp'));
    await tester.pumpAndSettle();

    expect(launched, hasLength(1));
    expect(
      launched.single,
      articleShareTargetUri(
        target: ArticleShareTarget.whatsapp,
        title: _article.title,
        link: articleDeepLink(_article.id),
      ),
    );
    expect(copied, isNull);
  });

  testWidgets('shows fallback when web share is rejected without auto-copying',
      (tester) async {
    String? copied;
    await tester.pumpWidget(
      MaterialApp(
        home: CommunityArticleDetailScreen(
          article: _article,
          shareService: _RejectedShareService(),
          copyArticleLink: (link) async => copied = link,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Share article'));
    await tester.pumpAndSettle();

    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Copy link'), findsOneWidget);
    expect(copied, isNull);
  }, skip: !kIsWeb);

  testWidgets('launches email only after the email option is tapped',
      (tester) async {
    final launched = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: CommunityArticleDetailScreen(
          article: _article,
          shareService: _UnavailableShareService(),
          launchShareOption: (
            url, {
            required mode,
            webOnlyWindowName,
          }) async {
            launched.add(url);
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.byTooltip('Share article'));
    await tester.pumpAndSettle();
    expect(launched, isEmpty);

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();

    expect(launched, hasLength(1));
    expect(launched.single.scheme, 'mailto');
    expect(launched.single.queryParameters['subject'], _article.title);
    expect(
      launched.single.queryParameters['body'],
      articleShareMessage(
        title: _article.title,
        link: articleDeepLink(_article.id),
      ),
    );
  });

  testWidgets('copies only after the copy-link option is tapped',
      (tester) async {
    String? copied;
    await tester.pumpWidget(
      MaterialApp(
        home: CommunityArticleDetailScreen(
          article: _article,
          shareService: _UnavailableShareService(),
          copyArticleLink: (link) async => copied = link,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Share article'));
    await tester.pumpAndSettle();
    expect(copied, isNull);

    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();

    expect(copied, articleDeepLink(_article.id));
    expect(find.text('Article link copied.'), findsOneWidget);
  });
}
