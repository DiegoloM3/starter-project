import 'package:flutter_test/flutter_test.dart';

import 'source_code.dart';

/// docs/ARCHITECTURE_VIOLATIONS.md → "2. Business Layer Violations" and docs/APP_ARCHITECTURE.md → "Business Layer".
void main() {
  final domainFiles = libFiles.where((file) => file.layer == Layer.domain).toList();
  Iterable<SourceFile> filesIn(String folder) => domainFiles.where((file) => file.layerFolder == folder);

  test('2.1.1 the domain layer is pure Dart: it only imports dart libraries, its own domain, core and shared domains', () {
    final violations = [
      for (final file in domainFiles)
        for (final import in file.imports)
          if (!import.startsWith('dart:') &&
              !import.startsWith('lib/core/') &&
              !(layerOf(import) == Layer.domain && (cleanFolderOf(import) == file.cleanFolder || import.startsWith('lib/shared/'))))
            file.describeImport(import),
    ];

    expect(violations, isEmpty, reason: 'No packages (not even pure Dart ones like equatable), no other feature, no data.');
  });

  test('core, which every layer may import, is pure Dart too, so the domain stays pure through it', () {
    final violations = [
      for (final file in libFiles.where((file) => file.path.startsWith('lib/core/')))
        for (final import in file.imports)
          if (!import.startsWith('dart:') && !import.startsWith('lib/core/')) file.describeImport(import),
    ];

    expect(violations, isEmpty);
  });

  test('2.3.1 each use case is a single operation: one use case class per file', () {
    final violations = filesIn('use_cases')
        .where((file) => file.classes.where((declared) => declared.name.endsWith('UseCase')).length != 1)
        .map((file) => '${file.path}: ${file.classes.map((declared) => declared.name).join(', ')}');

    expect(violations, isEmpty, reason: 'Its params and exceptions may live next to it.');
  });

  test('every use case implements an abstract class with a call method', () {
    final violations = [
      for (final file in filesIn('use_cases'))
        for (final useCase in file.classes.where((declared) => declared.name.endsWith('UseCase')))
          if (!{'UseCase', 'StreamUseCase'}.contains(useCase.implementedInterface) ||
              !RegExp(r'\bcall\s*\(').hasMatch(file.text))
            '${file.path}: ${useCase.name}',
    ];

    expect(violations, isEmpty);
  });

  test('2.3.2 use cases work through the repository interfaces, never the data layer', () {
    final violations = [
      for (final file in filesIn('use_cases'))
        for (final import in file.imports)
          if (layerOf(import) == Layer.data) file.describeImport(import),
    ];

    expect(violations, isEmpty);
  });

  test('2.4.1 domain repositories are only abstract definitions', () {
    final violations = [
      for (final file in filesIn('repository'))
        for (final declared in file.classes)
          if (!declared.isAbstract) '${file.path}: ${declared.name} is not abstract',
      for (final file in filesIn('repository'))
        if (RegExp(r'=>|\)\s*(async\s*)?\{').hasMatch(file.text)) '${file.path}: a method has a body',
    ];

    expect(violations, isEmpty);
  });

  test('2.4.2 domain repositories never return models, only entities', () {
    final violations = filesIn('repository')
        .where((file) => RegExp(r'\b\w+Model\b').hasMatch(file.text))
        .map((file) => file.path);

    expect(violations, isEmpty);
  });
}
