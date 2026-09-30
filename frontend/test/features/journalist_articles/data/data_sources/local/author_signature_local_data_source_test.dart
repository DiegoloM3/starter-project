import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/author_signature_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<AuthorSignatureLocalDataSource> dataSourceWith(Map<String, Object> storedValues) async {
    SharedPreferences.setMockInitialValues(storedValues);
    return AuthorSignatureLocalDataSource(await SharedPreferences.getInstance());
  }

  test('has no signature until one is written', () async {
    final dataSource = await dataSourceWith({});

    expect(dataSource.readAuthorName(), isNull);
  });

  test('reads back the written signature', () async {
    final dataSource = await dataSourceWith({});

    await dataSource.writeAuthorName('Daily News Staff');

    expect(dataSource.readAuthorName(), 'Daily News Staff');
  });

  test('keeps the signature between app launches', () async {
    await (await dataSourceWith({})).writeAuthorName('Daily News Staff');

    final relaunched = AuthorSignatureLocalDataSource(await SharedPreferences.getInstance());

    expect(relaunched.readAuthorName(), 'Daily News Staff');
  });
}
