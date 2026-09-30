import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/widgets/article_draft_error_messages.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  final spanish = lookupAppLocalizations(const Locale('es'));

  test('has no message for a field without errors', () {
    final messages = ArticleDraftErrorMessages(const {ArticleDraftError.titleEmpty}, english);

    expect(messages.author, isNull);
    expect(messages.content, isNull);
    expect(messages.thumbnail, isNull);
  });

  test('gives each field the message of its own error', () {
    final messages = ArticleDraftErrorMessages(const {
      ArticleDraftError.titleTooLong,
      ArticleDraftError.authorEmpty,
      ArticleDraftError.contentTooLong,
      ArticleDraftError.thumbnailTooLarge,
    }, english);

    expect(messages.title, 'The title can have up to 100 characters.');
    expect(messages.author, 'Sign the article with your name.');
    expect(messages.content, 'The article can have up to 10,000 characters.');
    expect(messages.thumbnail, 'Choose an image of 5 MB or less.');
  });

  test('shows one message per field, the most basic first', () {
    final messages = ArticleDraftErrorMessages(const {
      ArticleDraftError.thumbnailMissing,
      ArticleDraftError.thumbnailUnsupportedFormat,
    }, english);

    expect(messages.thumbnail, 'Attach an image to illustrate your article.');
  });

  test('speaks the language of the phone, numbers included', () {
    final messages = ArticleDraftErrorMessages(const {
      ArticleDraftError.titleEmpty,
      ArticleDraftError.contentTooLong,
      ArticleDraftError.thumbnailUnsupportedFormat,
    }, spanish);

    expect(messages.title, 'Añade un título a tu artículo.');
    expect(messages.content, 'El artículo puede tener hasta 10.000 caracteres.');
    expect(messages.thumbnail, 'Elige una imagen JPG, PNG o WebP.');
  });
}
