import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/network_failure.dart';
import 'package:news_app_clean_architecture/features/authentication/presentation/widgets/auth_failure_text.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/article_failure_text.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations_en.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations_es.dart';

/// [NetworkUnavailableException] exists to be *said*, so what is worth testing
/// about it is the wording both features give it.
///
/// Before it, signing in or publishing with no connection reported "Something
/// went wrong", which names nothing the person can act on — while the one
/// thing they could do was turn their connection back on.
void main() {
  const failure = NetworkUnavailableException();
  final en = AppLocalizationsEn();
  final es = AppLocalizationsEs();

  test('is not confused with a generic failure', () {
    expect(AuthFailureText.messageFor(en, failure), isNot(en.errorGeneric));
    expect(ArticleFailureText.messageFor(en, failure), isNot(en.errorGeneric));
  });

  test('authentication names the connection', () {
    expect(AuthFailureText.messageFor(en, failure), en.errorNoConnection);
    expect(
      AuthFailureText.messageFor(en, failure).toLowerCase(),
      contains('connection'),
    );
  });

  test('writing an article names the connection', () {
    expect(ArticleFailureText.messageFor(en, failure), en.errorNoConnection);
  });

  test('both features say the same thing, in either language', () {
    expect(
      AuthFailureText.messageFor(en, failure),
      ArticleFailureText.messageFor(en, failure),
    );
    expect(
      AuthFailureText.messageFor(es, failure),
      ArticleFailureText.messageFor(es, failure),
    );
    expect(
      AuthFailureText.messageFor(es, failure).toLowerCase(),
      contains('conexión'),
    );
  });

  test('an unrecognised failure still falls back to the generic message', () {
    expect(AuthFailureText.messageFor(en, Exception('?')), en.errorGeneric);
    expect(ArticleFailureText.messageFor(en, Exception('?')), en.errorGeneric);
  });
}
