import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

void main() {
  test('reads the id, name and email of an account', () {
    final model = UserModel.fromRawData({'id': 'janeDoeUid', 'name': 'Jane Doe', 'email': 'jane@example.com'});

    expect(model.id, 'janeDoeUid');
    expect(model.name, 'Jane Doe');
    expect(model.email, 'jane@example.com');
  });

  test('uses empty texts for an account without a name or an email', () {
    final model = UserModel.fromRawData({'id': 'janeDoeUid', 'name': null, 'email': null});

    expect(model.name, '');
    expect(model.email, '');
  });

  test('converts to an entity with the same fields', () {
    final entity = UserModel.fromRawData({'id': 'janeDoeUid', 'name': 'Jane Doe', 'email': 'jane@example.com'})
        .toEntity();

    expect(entity, isNot(isA<UserModel>()));
    expect(entity, const UserEntity(id: 'janeDoeUid', name: 'Jane Doe', email: 'jane@example.com'));
  });
}
