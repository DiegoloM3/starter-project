import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

extension ArticleSectionExtension on ArticleEntity {
  static const int _hashMultiplier = 31;
  static const int _hashBitmask = 0x7FFFFFFF;

  /// Returns the article's section if set, otherwise derives one from a hash
  /// of the URL or title. This ensures API articles (which have no section
  /// stored) still display with a deterministic section assignment.
  NewsSection get effectiveSection {
    if (section != null) return section!;

    final key = url ?? title ?? '';
    var hash = 0;
    for (var i = 0; i < key.length; i++) {
      hash = (hash * _hashMultiplier + key.codeUnitAt(i)) & _hashBitmask;
    }
    final assignable = NewsSectionAssignable.assignable;
    return assignable[hash % assignable.length];
  }
}

extension SectionColors on NewsSection {
  Color backgroundColor(AppColorsExtension colors) {
    switch (this) {
      case NewsSection.weather:
        return colors.weatherSectionBackground;
      case NewsSection.politics:
        return colors.politicsSectionBackground;
      case NewsSection.arts:
        return colors.artsSectionBackground;
      case NewsSection.sports:
        return colors.sportsSectionBackground;
      case NewsSection.crime:
        return colors.crimeSectionBackground;
      case NewsSection.all:
        return colors.accentGreenLight;
    }
  }

  Color textColor(AppColorsExtension colors) {
    switch (this) {
      case NewsSection.weather:
        return colors.weatherSectionText;
      case NewsSection.politics:
        return colors.politicsSectionText;
      case NewsSection.arts:
        return colors.artsSectionText;
      case NewsSection.sports:
        return colors.sportsSectionText;
      case NewsSection.crime:
        return colors.crimeSectionText;
      case NewsSection.all:
        return AppColors.accentGreen;
    }
  }
}

extension NewsSectionAssignable on NewsSection {
  static List<NewsSection> get assignable =>
      NewsSection.values.where((s) => s != NewsSection.all).toList();
}

extension NewsSectionLabel on NewsSection {
  String label(AppLocalizations l10n) {
    switch (this) {
      case NewsSection.all:
        return l10n.sectionAll;
      case NewsSection.politics:
        return l10n.sectionPolitics;
      case NewsSection.weather:
        return l10n.sectionWeather;
      case NewsSection.sports:
        return l10n.sectionSports;
      case NewsSection.arts:
        return l10n.sectionArts;
      case NewsSection.crime:
        return l10n.sectionCrime;
    }
  }
}

List<ArticleEntity> filterArticles({
  required List<ArticleEntity> articles,
  required NewsSection selectedSection,
  required String searchQuery,
}) {
  return articles.where((article) {
    if (selectedSection != NewsSection.all &&
        article.effectiveSection != selectedSection) {
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
