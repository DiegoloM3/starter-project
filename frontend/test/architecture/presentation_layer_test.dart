import 'package:flutter_test/flutter_test.dart';

import 'source_code.dart';

/// docs/ARCHITECTURE_VIOLATIONS.md → "3. Presentation Layer Violations" and docs/APP_ARCHITECTURE.md →
/// "Presentation Layer".
void main() {
  final presentationFiles = libFiles.where((file) => file.layer == Layer.presentation).toList();
  final configFiles = libFiles.where((file) => file.path.startsWith('lib/config/')).toList();

  test('the presentation layer only imports its own presentation and domain, core, shared and the app theme '
      '(Clean Folder Requirements 2)', () {
    final violations = [
      for (final file in presentationFiles)
        for (final import in file.imports.where((import) => import.startsWith('lib/')))
          if (!import.startsWith('lib/core/') &&
              !import.startsWith('lib/config/theme/') &&
              !((cleanFolderOf(import) == file.cleanFolder || import.startsWith('lib/shared/')) &&
                  {Layer.presentation, Layer.domain}.contains(layerOf(import))))
            file.describeImport(import),
    ];

    expect(violations, isEmpty,
        reason: 'Screens that join several features, and the blocs they get from the service locator, are built in '
            'lib/config (navigation, routes).');
  });

  test('3.1.1 the presentation layer never accesses the data layer or a provider', () {
    final violations = [
      for (final file in presentationFiles)
        for (final import in file.imports)
          if (layerOf(import) == Layer.data || isProvider(import)) file.describeImport(import),
    ];

    expect(violations, isEmpty);
  });

  test('3.2.2 the blocs are the only place that uses the use cases', () {
    final violations = [
      for (final file in [...presentationFiles, ...configFiles])
        for (final import in file.imports)
          if (layerOf(import) == Layer.domain && layerFolderOf(import) == 'use_cases' && file.layerFolder != 'bloc')
            file.describeImport(import),
    ];

    expect(violations, isEmpty);
  });

  test('3.2.3 the blocs only interact with use cases, never with repositories or the data layer', () {
    final violations = [
      for (final file in presentationFiles.where((file) => file.layerFolder == 'bloc'))
        for (final import in file.imports)
          if (layerOf(import) == Layer.data || (layerOf(import) == Layer.domain && layerFolderOf(import) == 'repository'))
            file.describeImport(import),
    ];

    expect(violations, isEmpty);
  });

  test('3.3.2 screens and widgets do not depend on models, only on entities', () {
    final violations = presentationFiles
        .where((file) => file.layerFolder != 'bloc' && RegExp(r'\b\w+Model\b').hasMatch(file.text))
        .map((file) => file.path);

    expect(violations, isEmpty);
  });

  test('lib/config, which builds the screens and their navigation, never imports a data layer', () {
    final violations = [
      for (final file in configFiles)
        for (final import in file.imports)
          if (layerOf(import) == Layer.data || isProvider(import)) file.describeImport(import),
    ];

    expect(violations, isEmpty);
  });
}
