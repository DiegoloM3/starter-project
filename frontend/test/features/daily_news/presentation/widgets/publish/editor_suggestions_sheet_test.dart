import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publish/editor_suggestions_sheet.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/skeleton/skeleton_box.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows bones while loading and the reason when the editor fails', (tester) async {
    await pumpApp(
      tester,
      EditorSuggestionsSheet(
        suggestions: null,
        isLoading: true,
        errorMessage: null,
        onUseHeadline: (_) {},
        onUseSummary: (_) {},
      ),
    );
    expect(find.byType(SkeletonArea), findsOneWidget);
    expect(find.text('Use this'), findsNothing);

    await pumpApp(
      tester,
      EditorSuggestionsSheet(
        suggestions: null,
        isLoading: false,
        errorMessage: 'The editor is away.',
        onUseHeadline: (_) {},
        onUseSummary: (_) {},
      ),
    );
    expect(find.byType(SkeletonArea), findsNothing);
    expect(find.text('The editor is away.'), findsOneWidget);
  });

  testWidgets('every proposal has its own Use this and hands back its text', (tester) async {
    String? headline;
    String? summary;
    await pumpApp(
      tester,
      EditorSuggestionsSheet(
        suggestions: const EditorSuggestions(headlines: ['One', 'Two'], summary: 'A summary.'),
        isLoading: false,
        errorMessage: null,
        onUseHeadline: (value) => headline = value,
        onUseSummary: (value) => summary = value,
      ),
    );

    expect(find.text('Use this'), findsNWidgets(3));
    await tester.tap(find.text('Use this').at(1));
    expect(headline, 'Two');
    await tester.tap(find.text('Use this').last);
    expect(summary, 'A summary.');
  });
}
