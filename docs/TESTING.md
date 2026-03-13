# Testing Guide

This document outlines the testing strategy, structure, and instructions for running tests in this project.

## Test Summary

| Layer | Tests | Description |
|-------|-------|-------------|
| **Domain** | 71 | Use cases, entity validation |
| **Data** | 64 | Repository implementations, data sources |
| **Presentation** | 75 | BLoCs, Cubits, state management |
| **Total** | **210** | All passing ✅ |

## Running Tests

### Run All Tests

```bash
cd frontend
flutter test
```

### Run with Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
```

### Run Specific Test Files

```bash
# Auth feature tests
flutter test test/features/auth/

# User articles feature tests
flutter test test/features/user_articles/

# Single test file
flutter test test/features/auth/domain/usecases/sign_in_test.dart
```

### Run with Verbose Output

```bash
flutter test --reporter=expanded
```

## Test Structure

```
test/
├── fixtures/
│   └── test_fixtures.dart       # Shared test data
├── mocks/
│   ├── mock_repositories.dart   # Repository mocks
│   ├── mock_data_sources.dart   # Data source mocks
│   ├── mock_use_cases.dart      # Use case mocks
│   └── mocks.dart               # Barrel file (exports all)
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/     # Remote data source tests
    │   │   └── repositories/    # Repository impl tests
    │   ├── domain/
    │   │   └── usecases/        # Use case tests
    │   └── presentation/
    │       └── bloc/            # AuthBloc tests
    └── user_articles/
        ├── data/
        │   └── repositories/
        ├── domain/
        │   └── usecases/
        └── presentation/
            └── bloc/            # BLoC & Cubit tests
```

## Mock Generation

This project uses [mockito](https://pub.dev/packages/mockito) for mocking. Mocks are generated using build_runner.

### Regenerate Mocks

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Mock Files Structure

| File | Purpose |
|------|---------|
| `mock_repositories.dart` | Mocks for `AuthRepository`, `UserArticleRepository` |
| `mock_data_sources.dart` | Mocks for `AuthRemoteDataSource`, `ArticleRemoteDataSource` |
| `mock_use_cases.dart` | Mocks for all use cases + `FlutterTts` |

## Testing Philosophy

### Clean Architecture Testing Principle

> **Mock only the layer directly above the one being tested.**

- **Domain tests**: Mock repositories (data layer)
- **Data tests**: Mock data sources (external services)  
- **Presentation tests**: Mock use cases (domain layer)

### Test Categories

#### 1. Domain Layer Tests
- **Focus**: Business logic validation
- **What to test**: Use case execution, parameter validation, error handling
- **Example**: `SignInUseCase` correctly calls repository and returns result

#### 2. Data Layer Tests
- **Focus**: Data transformation and API integration
- **What to test**: Repository implementations, model mapping, error conversion
- **Example**: `AuthRepositoryImpl` converts Firebase exceptions to domain failures

#### 3. Presentation Layer Tests
- **Focus**: State management and UI logic
- **What to test**: BLoC events/states, Cubit methods, error state handling
- **Example**: `AuthBloc` emits `AuthLoading` then `Authenticated` on successful sign-in

## Writing New Tests

### 1. Add Mock Dependencies

Edit the appropriate mock file in `test/mocks/`:

```dart
// In mock_repositories.dart
@GenerateMocks([
  NewRepository,  // Add your new repository
])
```

### 2. Regenerate Mocks

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Create Test File

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks/mocks.dart';  // Import all mocks

void main() {
  late MockNewRepository mockRepository;

  setUp(() {
    mockRepository = MockNewRepository();
  });

  group('NewFeature', () {
    test('should do something', () {
      // Arrange
      when(mockRepository.someMethod()).thenReturn(expectedValue);
      
      // Act
      final result = // ... call what you're testing
      
      // Assert
      expect(result, expectedValue);
      verify(mockRepository.someMethod()).called(1);
    });
  });
}
```

### 4. BLoC Tests with bloc_test

```dart
import 'package:bloc_test/bloc_test.dart';

blocTest<MyBloc, MyState>(
  'emits [Loading, Loaded] when event is added',
  build: () {
    when(mockUseCase.call(params: any)).thenAnswer(
      (_) async => DataSuccess(expectedData),
    );
    return MyBloc(useCase: mockUseCase);
  },
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [
    isA<Loading>(),
    isA<Loaded>(),
  ],
);
```

## Continuous Integration

Tests should be run as part of CI/CD pipeline:

```yaml
# Example GitHub Actions
- name: Run Tests
  run: |
    cd frontend
    flutter test --coverage
    
- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    file: frontend/coverage/lcov.info
```

## Troubleshooting

### "Cannot find mock" errors

Regenerate mocks:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Tests hanging or timing out

Add timeout to async tests:
```dart
test('async test', () async {
  // test code
}, timeout: Timeout(Duration(seconds: 10)));
```

### BLoC tests with async initialization

Use `wait` parameter in blocTest:
```dart
blocTest<MyCubit, MyState>(
  'description',
  build: () => MyCubit(),
  wait: const Duration(milliseconds: 50),  // Wait for async init
  act: (cubit) => cubit.someMethod(),
  expect: () => [...],
);
```
