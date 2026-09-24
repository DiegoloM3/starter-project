import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/relative_time.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

void main() {
  final now = DateTime(2026, 9, 22, 12);

  late AppLocalizations l10n;

  setUpAll(() async {
    // The wording lives in the ARB files now, so formatting needs a locale.
    // The tests read English, which is the app's default.
    l10n = await AppLocalizations.delegate.load(const Locale('en'));

    // Older dates are printed with DateFormat, which needs its per-locale
    // data loaded first. The running app gets this from Flutter's own
    // localisation delegates; a plain unit test has to ask for it.
    await initializeDateFormatting('en');
  });

  String format(String? rawDate) =>
      RelativeTime.formatRaw(l10n, rawDate, now: now);

  test('reports minutes for something published moments ago', () {
    expect(format('2026-09-22T11:35:00'), '25m ago');
  });

  test('reports hours within the day', () {
    expect(format('2026-09-22T09:00:00'), '3h ago');
  });

  test('reports days within the week', () {
    expect(format('2026-09-19T12:00:00'), '3d ago');
  });

  test('falls back to a date once relative time stops meaning anything', () {
    // "312h ago" tells a reader nothing.
    expect(format('2026-09-01T12:00:00'), 'Sep 1, 2026');
  });

  test('says just now rather than 0m ago', () {
    expect(format('2026-09-22T11:59:40'), 'Just now');
  });

  test('shows nothing at all for a date it cannot read', () {
    // The News API hands publishedAt over as a plain string, so a value that
    // is not a date is a real case, not a hypothetical one.
    expect(format('not a date'), isEmpty);
    expect(format(null), isEmpty);
    expect(format(''), isEmpty);
  });
}
