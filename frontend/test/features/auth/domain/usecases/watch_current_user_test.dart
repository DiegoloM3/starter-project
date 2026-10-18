import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/watch_current_user.dart';

void main() {
  test('starts with nobody signed in', () async {
    final currentUser = await WatchCurrentUserUseCase().call(const NoParams()).first;

    expect(currentUser, isNull);
  });
}
