import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';

void main() {
  test('signs out', () async {
    final result = await SignOutUseCase().call(const NoParams());

    expect(result, isA<DataSuccess>());
  });
}
