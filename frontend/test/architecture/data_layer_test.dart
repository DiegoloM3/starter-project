import 'package:flutter_test/flutter_test.dart';

import 'source_code.dart';

/// docs/ARCHITECTURE_VIOLATIONS.md → "1. Data Layer Violations" and docs/APP_ARCHITECTURE.md → "Data Layer".
void main() {
  final dataFiles = libFiles.where((file) => file.layer == Layer.data).toList();
  Iterable<SourceFile> filesIn(String folder) => dataFiles.where((file) => file.layerFolder == folder);

  final entityNames = libFiles
      .where((file) => file.layer == Layer.domain && file.layerFolder == 'entities')
      .expand((file) => file.classes)
      .map((declared) => declared.name)
      .toSet();
  final repositoryInterfaces = libFiles
      .where((file) => file.layer == Layer.domain && file.layerFolder == 'repository')
      .expand((file) => file.classes)
      .where((declared) => declared.isAbstract)
      .map((declared) => declared.name)
      .toSet();

  test('the data layer only imports its own data and domain layers, core and shared (Clean Folder Requirements 2)', () {
    final violations = [
      for (final file in dataFiles)
        for (final import in file.imports.where((import) => import.startsWith('lib/')))
          if (!import.startsWith('lib/core/') &&
              !((cleanFolderOf(import) == file.cleanFolder || import.startsWith('lib/shared/')) &&
                  {Layer.data, Layer.domain}.contains(layerOf(import))))
            file.describeImport(import),
    ];

    expect(violations, isEmpty);
  });

  test('1.1.1 the data layer never imports from a presentation layer', () {
    final violations = [
      for (final file in dataFiles)
        for (final import in file.imports)
          if (layerOf(import) == Layer.presentation || import.startsWith('lib/config/')) file.describeImport(import),
    ];

    expect(violations, isEmpty);
  });

  test('1.1.2 the data layer does not import use_cases', () {
    final violations = [
      for (final file in dataFiles)
        for (final import in file.imports)
          if (layerOf(import) == Layer.domain && layerFolderOf(import) == 'use_cases') file.describeImport(import),
    ];

    expect(violations, isEmpty);
  });

  test('1.2.1 data sources throw exceptions: they never build a DataState or a failure', () {
    final violations = filesIn('data_sources')
        .where((file) =>
            file.imports.contains('lib/core/resources/data_state.dart') || RegExp(r'\bData(Failed|Success|State)\b').hasMatch(file.text))
        .map((file) => file.path);

    expect(violations, isEmpty);
  });

  test('1.2.3 and 1.2.4 the data sources are the only place that imports a provider (Firebase, HTTP, storage...)', () {
    final violations = [
      for (final file in libFiles.where((file) => !file.isCompositionRoot))
        for (final import in file.imports.where(isProvider))
          if (!(file.layer == Layer.data && file.layerFolder == 'data_sources')) file.describeImport(import),
    ];

    expect(violations, isEmpty, reason: 'Only the composition root (${compositionRoot.join(', ')}) also creates the providers.');
  });

  test('1.3.1 every model extends an entity from domain/entities', () {
    final violations = [
      for (final file in filesIn('models'))
        for (final model in file.classes)
          if (!entityNames.contains(model.superclass)) '${file.path}: ${model.name} extends ${model.superclass}',
    ];

    expect(violations, isEmpty);
  });

  test('1.3.2 every model has a toEntity() function', () {
    final violations = [
      for (final file in filesIn('models'))
        for (final model in file.classes)
          if (!RegExp(r'\b\w+\s+toEntity\(\)').hasMatch(file.text)) '${file.path}: ${model.name}',
    ];

    expect(violations, isEmpty);
  });

  test('1.3.3 every model has a fromRawData factory', () {
    final violations = [
      for (final file in filesIn('models'))
        for (final model in file.classes)
          if (!RegExp('factory\\s+${model.name}\\.fromRawData\\(').hasMatch(file.text)) '${file.path}: ${model.name}',
    ];

    expect(violations, isEmpty);
  });

  test('1.4.1 and 1.4.2 repository implementations are named {Interface}Impl and implement a domain repository', () {
    final violations = [
      for (final file in filesIn('repository'))
        for (final implementation in file.classes)
          if (!repositoryInterfaces.contains(implementation.implementedInterface) ||
              implementation.name != '${implementation.implementedInterface}Impl')
            '${file.path}: ${implementation.name} implements ${implementation.implementedInterface}',
    ];

    expect(violations, isEmpty);
  });

  test('1.4.3 a repository always returns a DataState when it requests data', () {
    final request = RegExp(r'^\s*Future<(.+)>\s+([a-z]\w*)\s*\(', multiLine: true);
    final violations = [
      for (final file in filesIn('repository'))
        for (final match in request.allMatches(file.text))
          if (match.group(1) != 'void' && !match.group(1)!.startsWith('DataState<'))
            '${file.path}: Future<${match.group(1)}> ${match.group(2)}',
    ];

    expect(violations, isEmpty, reason: 'A command that returns nothing (Future<void>) is not a request for data.');
  });

  test('1.4.4 the repository implementations are the only place that imports the data sources', () {
    final violations = [
      for (final file in libFiles.where((file) => !file.isCompositionRoot))
        for (final import in file.imports)
          if (layerOf(import) == Layer.data &&
              layerFolderOf(import) == 'data_sources' &&
              !(file.layer == Layer.data && {'repository', 'data_sources'}.contains(file.layerFolder)))
            file.describeImport(import),
    ];

    expect(violations, isEmpty, reason: 'A data source may import the pieces of its own data source (a DAO, its table).');
  });
}
