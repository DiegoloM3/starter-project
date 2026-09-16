import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_model.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

void main() {
  test('blank strings from the provider count as absent, others are trimmed', () {
    final model = UserModel.fromRawData(id: 'u1', email: '  ', displayName: '  Ada ', photoUrl: '');

    expect(model.email, isNull);
    expect(model.displayName, 'Ada');
    expect(model.photoUrl, isNull);
  });

  test('toEntity carries every field', () {
    const model = UserModel(id: 'u1', email: 'ada@example.com', displayName: 'Ada', photoUrl: 'https://p/a.png');

    expect(
      model.toEntity(),
      const UserEntity(id: 'u1', email: 'ada@example.com', displayName: 'Ada', photoUrl: 'https://p/a.png'),
    );
  });
}
