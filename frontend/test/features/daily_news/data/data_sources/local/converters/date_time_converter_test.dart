import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/converters/date_time_converter.dart';

void main() {
  final converter = DateTimeConverter();

  test('encodes as UTC milliseconds and decodes back to UTC', () {
    final local = DateTime(2026, 9, 15, 12, 30);

    final encoded = converter.encode(local);
    final decoded = converter.decode(encoded);

    expect(encoded, local.toUtc().millisecondsSinceEpoch);
    expect(decoded.isUtc, isTrue);
    expect(decoded, local.toUtc());
  });
}
