import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

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
        article.section != null &&
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
