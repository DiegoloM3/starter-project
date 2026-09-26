import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'web_share.dart' if (dart.library.js_interop) 'web_share_web.dart'
    as web_share;

/// Builds a link that can reopen the article in this app when the current
/// runtime has a web origin. Native runtimes receive a readable fallback URI.
String articleDeepLink(String articleId, {Uri? baseUri}) {
  final base = baseUri ?? Uri.base;
  final isWebOrigin =
      (base.scheme == 'http' || base.scheme == 'https') && base.host.isNotEmpty;
  if (isWebOrigin) {
    return Uri(
      scheme: base.scheme,
      userInfo: base.userInfo,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/',
      queryParameters: <String, String>{'article': articleId},
    ).toString();
  }
  return 'case-study-symmetry://article/${Uri.encodeComponent(articleId)}';
}

abstract class ArticleShareService {
  Future<void> shareArticle({
    required String title,
    required String summary,
    required String articleId,
    Rect? sharePositionOrigin,
  });
}

typedef CopyArticleLink = Future<void> Function(String link);
typedef NativeArticleShare = Future<void> Function(
  String text, {
  String? subject,
  Rect? sharePositionOrigin,
});

typedef WebArticleShare = Future<web_share.WebShareStatus> Function({
  required String title,
  required String text,
  required String link,
});

enum ArticleShareTarget { whatsapp, telegram, email }

class ArticleShareUnavailable extends UnsupportedError {
  final String title;
  final String link;

  ArticleShareUnavailable({required this.title, required this.link})
      : super('The browser does not support native sharing.');
}

String articleShareMessage({required String title, required String link}) {
  return '$title\n\n$link';
}

Uri articleShareTargetUri({
  required ArticleShareTarget target,
  required String title,
  required String link,
}) {
  final message = articleShareMessage(title: title, link: link);
  switch (target) {
    case ArticleShareTarget.whatsapp:
      return Uri.https('wa.me', '/', <String, String>{'text': message});
    case ArticleShareTarget.telegram:
      return Uri.https('t.me', '/share/url', <String, String>{
        'url': link,
        'text': title,
      });
    case ArticleShareTarget.email:
      return Uri(
        scheme: 'mailto',
        queryParameters: <String, String>{
          'subject': title,
          'body': message,
        },
      );
  }
}

bool isLocalShareLink(String link) {
  final uri = Uri.tryParse(link);
  final host = uri?.host;
  return host == 'localhost' || host == '127.0.0.1' || host == '::1';
}

Future<void> copyArticleLinkToClipboard(String link) {
  return Clipboard.setData(ClipboardData(text: link));
}

Future<void> shareArticleText(
  String text, {
  String? subject,
  Rect? sharePositionOrigin,
}) {
  return Share.share(
    text,
    subject: subject,
    sharePositionOrigin: sharePositionOrigin,
  );
}

String articleShareText({
  required String title,
  required String summary,
  required String link,
}) {
  return <String>[
    title,
    if (summary.trim().isNotEmpty) summary.trim(),
    'Read it in Case Study Symmetry: $link',
  ].join('\n\n');
}

/// Web fallback for browsers without a usable Web Share target. Copying the
/// exact deep link is deterministic and gives the detail screen a reliable
/// success state instead of silently opening a mail client.
class ClipboardArticleShareService implements ArticleShareService {
  final CopyArticleLink _copy;

  const ClipboardArticleShareService(
      {CopyArticleLink copy = copyArticleLinkToClipboard})
      : _copy = copy;

  @override
  Future<void> shareArticle({
    required String title,
    required String summary,
    required String articleId,
    Rect? sharePositionOrigin,
  }) {
    return _copy(articleDeepLink(articleId));
  }
}

class SharePlusArticleShareService implements ArticleShareService {
  final NativeArticleShare _share;
  final WebArticleShare _webShare;

  const SharePlusArticleShareService({
    NativeArticleShare share = shareArticleText,
    WebArticleShare webShare = web_share.performWebShare,
  })  : _share = share,
        _webShare = webShare;

  @override
  Future<void> shareArticle({
    required String title,
    required String summary,
    required String articleId,
    Rect? sharePositionOrigin,
  }) async {
    final link = articleDeepLink(articleId);
    final text = articleShareText(title: title, summary: summary, link: link);

    if (kIsWeb) {
      final status = await _webShare(
        title: title,
        text: summary.trim().isEmpty
            ? 'Read it in Case Study Symmetry.'
            : summary.trim(),
        link: link,
      );
      if (status == web_share.WebShareStatus.unsupported) {
        throw ArticleShareUnavailable(title: title, link: link);
      }
      return;
    }

    await _share(
      text,
      subject: title,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
