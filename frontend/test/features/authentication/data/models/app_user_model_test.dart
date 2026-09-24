import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/authentication/data/models/app_user_model.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/app_user.dart';

void main() {
  test('reads the three fields the app uses off an account', () {
    final model = AppUserModel.fromRawData(const {
      'uid': 'user-7',
      'email': 'alex@example.com',
      'displayName': 'Alex Rivera',
    });

    expect(model.id, 'user-7');
    expect(model.email, 'alex@example.com');
    expect(model.displayName, 'Alex Rivera');
  });

  /// Firebase leaves both of these null on an account created some other way.
  /// The entity promises strings, so the model is where the nulls stop.
  test('an account with no email or name becomes empty strings, not null', () {
    final model = AppUserModel.fromRawData(const {'uid': 'user-7'});

    expect(model.email, '');
    expect(model.displayName, '');
  });

  test('converts to a plain entity the domain can hold', () {
    final entity = AppUserModel.fromRawData(const {'uid': 'user-1'}).toEntity();

    expect(entity, isA<AppUserEntity>());
    expect(entity.runtimeType, AppUserEntity);
    expect(entity.id, 'user-1');
  });
}
