import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/media/domain/repository/image_picker_repository.dart';
import 'package:news_app_clean_architecture/shared/media/domain/use_cases/pick_image.dart';

import '../../../../helpers/fixtures.dart';

class MockImagePickerRepository extends Mock implements ImagePickerRepository {}

void main() {
  late MockImagePickerRepository repository;
  late PickImageUseCase useCase;

  setUp(() {
    repository = MockImagePickerRepository();
    useCase = PickImageUseCase(repository);
  });

  test('returns a valid picked image', () async {
    when(repository.pickFromGallery).thenAnswer((_) async => DataSuccess(buildImage()));
    final result = await useCase(const NoParams());
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, buildImage());
  });

  test('passes a dismissed picker and repository failures through', () async {
    when(repository.pickFromGallery).thenAnswer((_) async => const DataSuccess(null));
    final dismissed = await useCase(const NoParams());
    expect(dismissed.isSuccess, isTrue);
    expect(dismissed.dataOrNull, isNull);

    when(repository.pickFromGallery).thenAnswer((_) async => const DataFailed(Failure.unknown()));
    expect((await useCase(const NoParams())).failureOrNull, const Failure.unknown());
  });

  test('rejects files the backend would reject, before any upload', () async {
    when(repository.pickFromGallery)
        .thenAnswer((_) async => DataSuccess(buildImage(sizeInBytes: 6 * 1024 * 1024)));

    final result = await useCase(const NoParams());

    expect(result.failureOrNull?.type, FailureType.validation);
    expect(result.failureOrNull?.message, contains('5 MB'));
  });
}
