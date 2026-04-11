import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';

extension ArticleSectionExtension on ArticleEntity {
  static const int _hashMultiplier = 31;
  static const int _hashBitmask = 0x7FFFFFFF;

  NewsSection get section {
    final key = url ?? title ?? '';
    var hash = 0;
    for (var i = 0; i < key.length; i++) {
      hash = (hash * _hashMultiplier + key.codeUnitAt(i)) & _hashBitmask;
    }
    final assignable =
        NewsSection.values.where((s) => s != NewsSection.todos).toList();
    return assignable[hash % assignable.length];
  }
}

extension SectionColors on NewsSection {
  Color backgroundColor(AppColorsExtension colors) {
    switch (this) {
      case NewsSection.clima:
        return colors.sectionClimaBackground;
      case NewsSection.politica:
        return colors.sectionPoliticaBackground;
      case NewsSection.artes:
        return colors.sectionArtesBackground;
      case NewsSection.deportes:
        return colors.sectionDeportesBackground;
      case NewsSection.policiaca:
        return colors.sectionPoliciacaBackground;
      case NewsSection.todos:
        return colors.accentGreenLight;
    }
  }

  Color textColor(AppColorsExtension colors) {
    switch (this) {
      case NewsSection.clima:
        return colors.sectionClimaText;
      case NewsSection.politica:
        return colors.sectionPoliticaText;
      case NewsSection.artes:
        return colors.sectionArtesText;
      case NewsSection.deportes:
        return colors.sectionDeportesText;
      case NewsSection.policiaca:
        return colors.sectionPoliciacaText;
      case NewsSection.todos:
        return AppColors.accentGreen;
    }
  }
}

List<ArticleEntity> filterArticles({
  required List<ArticleEntity> articles,
  required NewsSection selectedSection,
  required String searchQuery,
}) {
  return articles.where((article) {
    if (selectedSection != NewsSection.todos &&
        article.section != selectedSection) {
      return false;
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      final titleMatch = (article.title ?? '').toLowerCase().contains(query);
      final descMatch =
          (article.description ?? '').toLowerCase().contains(query);
      if (!titleMatch && !descMatch) return false;
    }
    return true;
  }).toList();
}
