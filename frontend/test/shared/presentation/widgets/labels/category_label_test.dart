import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/category_label.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('upper-cases the category in deep red', (tester) async {
    await pumpApp(tester, const CategoryLabel(category: NewsCategory.technology));

    final text = tester.widget<Text>(find.text('TECHNOLOGY'));
    expect(text.style?.color, AppPalette.light.primaryDeep);
  });

  testWidgets('accepts a colour override for dark surfaces', (tester) async {
    await pumpApp(tester, const CategoryLabel(category: NewsCategory.health, color: Colors.white));

    expect(tester.widget<Text>(find.text('HEALTH')).style?.color, Colors.white);
  });
}
