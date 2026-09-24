@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `docs/ARCHITECTURE_VIOLATIONS.md`, as tests.
///
/// The rules in that document are checked by a reviewer reading a diff, which
/// is exactly the kind of check that passes on a tired Friday. Every rule that
/// can be decided by looking at imports and file names is decided here
/// instead, so breaking one fails the build and names the file.
///
/// Rules about intent — "no business logic in blocs", "widgets should be
/// reusable" — are deliberately not here. A test that claimed to check those
/// would be checking a proxy for them, and would be worse than honest prose.
void main() {
  final dartFiles = _dartFilesUnder('lib');

  setUpAll(() {
    // A silent zero would make every test below vacuously pass.
    expect(dartFiles, isNotEmpty, reason: 'No Dart files found under lib/');
  });

  group('1. Data layer', () {
    test('1.1.1 never imports from a presentation layer', () {
      expect(
        _violations(
          dartFiles.where(_isDataLayer),
          (target) => target.contains('/presentation/'),
        ),
        isEmpty,
      );
    });

    test('1.1.2 never imports use cases', () {
      expect(
        _violations(
          dartFiles.where(_isDataLayer),
          (target) => target.contains('/use_cases/'),
        ),
        isEmpty,
      );
    });

    test('1.2.4 only data_sources import provider SDKs', () {
      final offenders = _violations(
        dartFiles.where((file) => !_isDataSource(file)),
        _isProviderPackage,
      ).where((violation) => !_providerExceptions.any(violation.startsWith));

      expect(
        offenders,
        isEmpty,
        reason: 'A provider SDK may only be imported from data/data_sources. '
            'Known exceptions are listed in _providerExceptions.',
      );
    });

    test('1.3.1 every model extends an entity', () {
      for (final model in dartFiles.where(_isModel)) {
        expect(
          model.readAsStringSync(),
          matches(RegExp(r'class \w+ extends \w+Entity')),
          reason: '${model.path} must extend an entity from domain/entities',
        );
      }
    });

    test('1.3.2 every model converts itself to an entity', () {
      for (final model in dartFiles.where(_isModel)) {
        expect(
          model.readAsStringSync(),
          contains('toEntity()'),
          reason: '${model.path} must offer toEntity()',
        );
      }
    });

    test('1.3.3 every model is built by a fromRawData factory', () {
      for (final model in dartFiles.where(_isModel)) {
        expect(
          model.readAsStringSync(),
          contains('fromRawData'),
          reason: '${model.path} must offer a fromRawData factory',
        );
      }
    });

    test('1.4.1 repository implementations are named {Interface}Impl', () {
      for (final file in dartFiles.where(_isRepositoryImplementation)) {
        final classNames = RegExp(r'^class (\w+)', multiLine: true)
            .allMatches(file.readAsStringSync())
            .map((match) => match.group(1)!);

        for (final className in classNames) {
          expect(
            className,
            endsWith('Impl'),
            reason: '${file.path} declares $className',
          );
        }
      }
    });

    test('1.4.3 repositories always answer with a DataState', () {
      for (final file in dartFiles.where(_isRepositoryImplementation)) {
        final overridden = RegExp(
          r'@override\s+(?:Future|Stream)<([^\n]+?)>\s+\w+\(',
        ).allMatches(file.readAsStringSync());

        for (final method in overridden) {
          expect(
            method.group(1),
            startsWith('DataState'),
            reason: '${file.path} returns ${method.group(1)}',
          );
        }
      }
    });
  });

  group('2. Business layer', () {
    /// 2.1.1, read strictly: the domain is pure Dart. It is allowed the two
    /// `core` contracts the architecture document's own "Exceptions" clause
    /// permits — and which rule 1.4.3 in fact forces it to use, since a
    /// repository interface has to name `DataState` to declare it.
    test('2.1.1 the domain imports nothing but Dart and its own layer', () {
      final offenders = <String>[];

      for (final file in dartFiles.where(_isDomainLayer)) {
        for (final import in _importsOf(file)) {
          final isAllowed = import.startsWith('dart:') ||
              _allowedDomainPackages.contains(import) ||
              _allowedDomainCoreFiles.any(import.endsWith) ||
              _resolve(file, import).contains('/domain/');

          if (!isAllowed) {
            offenders.add('${file.path} -> $import');
          }
        }
      }

      expect(offenders, isEmpty);
    });

    test('2.1.1 the domain never imports Flutter', () {
      expect(
        _violations(
          dartFiles.where(_isDomainLayer),
          (target) => target.startsWith('package:flutter'),
        ),
        isEmpty,
      );
    });

    test('2.4.2 repository interfaces never mention a model', () {
      for (final file in dartFiles.where(_isRepositoryInterface)) {
        expect(
          file.readAsStringSync(),
          isNot(contains('Model')),
          reason: '${file.path} must speak in entities, not models',
        );
      }
    });
  });

  group('3. Presentation layer', () {
    test('3.1.1 never reaches the data layer', () {
      expect(
        _violations(
          dartFiles.where(_isPresentationLayer),
          (target) => target.contains('/data/'),
        ),
        isEmpty,
      );
    });

    test('3.1.1 never imports a provider SDK', () {
      expect(
        _violations(dartFiles.where(_isPresentationLayer), _isProviderPackage),
        isEmpty,
      );
    });

    test('3.2.2 only blocs interact with use cases', () {
      final offenders = _violations(
        dartFiles.where(
          (file) => _isPresentationLayer(file) && !_isBloc(file),
        ),
        (target) => target.contains('/use_cases/'),
      );

      expect(offenders, isEmpty);
    });

    test('3.1.1 screens and widgets never reach the injection container', () {
      expect(
        _violations(
          dartFiles.where(_isPresentationLayer),
          (target) => target.endsWith('injection_container.dart'),
        ),
        isEmpty,
      );
    });
  });

  group('Folder structure', () {
    test('every feature keeps the three layers apart', () {
      final features = Directory('lib/features')
          .listSync()
          .whereType<Directory>()
          .map((directory) => directory.path);

      expect(features, isNotEmpty);

      for (final feature in features) {
        for (final layer in ['data', 'domain', 'presentation']) {
          expect(
            Directory('$feature/$layer').existsSync(),
            isTrue,
            reason: '$feature is missing its $layer layer',
          );
        }
      }
    });

    test('the folders are the ones the architecture document names', () {
      final wrongNames = _dartFilesUnder('lib').map((file) => file.path).where(
            (path) =>
                path.contains('/domain/usecases/') ||
                path.contains('/presentation/pages/'),
          );

      expect(
        wrongNames,
        isEmpty,
        reason: 'APP_ARCHITECTURE.md names these use_cases/ and screens/',
      );
    });

    test('test/ mirrors lib/ for every file that holds logic', () {
      final missing = <String>[];

      for (final file in dartFiles) {
        final path = file.path;

        if (_untestedByDesign.any(path.contains)) {
          continue;
        }

        final mirrored = path
            .replaceFirst('lib/', 'test/')
            .replaceFirst(RegExp(r'\.dart$'), '_test.dart');

        if (!File(mirrored).existsSync()) {
          missing.add(path);
        }
      }

      // Recorded rather than asserted to zero: the remaining gaps are listed
      // in docs/DECISIONS.md, and this guards against the list growing.
      expect(
        missing.length,
        lessThanOrEqualTo(_knownMissingTestCount),
        reason: 'Files without a mirrored test:\n${missing.join('\n')}',
      );
    });
  });
}

/// Provider SDKs: the packages that reach a network, a disk or the hardware.
const _providerPackages = [
  'package:cloud_firestore/',
  'package:firebase_auth/',
  'package:firebase_storage/',
  'package:firebase_core/',
  'package:dio/',
  'package:floor/',
  'package:sqflite/',
  'package:image_picker/',
  'package:retrofit/',
  'package:flutter_image_compress/',
];

bool _isProviderPackage(String target) =>
    _providerPackages.any(target.startsWith);

/// Where a provider SDK is imported outside `data/data_sources`, on purpose.
///
/// Each of these is argued in `docs/DECISIONS.md`. The list is deliberately
/// exact rather than a pattern, so a new one cannot slip in unnoticed.
const _providerExceptions = [
  // The composition root has to build the SDK instances it injects.
  'lib/injection_container.dart',
  // Bootstrap, before any layer exists.
  'lib/main.dart',
  'lib/firebase_options.dart',
  // Floor's @Entity must sit on the class its generated DAO names, and
  // build_runner cannot run in this project (decisions #19 and #63).
  'lib/features/daily_news/data/models/article.dart',
];

/// The domain is pure Dart, with two admitted exceptions.
///
/// Equatable is a pure Dart value-equality package with no Flutter and no I/O;
/// it is what the architecture's own reference implementation uses on
/// entities.
const _allowedDomainPackages = ['package:equatable/equatable.dart'];

/// `DataState` is required of repositories by rule 1.4.3, so their interfaces
/// must be able to name it; `UseCase` is the contract use cases implement.
const _allowedDomainCoreFiles = [
  'core/resources/data_state.dart',
  'core/usecase/usecase.dart',
];

/// Files with no logic of their own to test: generated code, bootstrap,
/// dependency wiring, constants, and pure widget-tree declarations that the
/// screen tests already exercise.
const _untestedByDesign = [
  '.g.dart',
  // Thin wrappers over a provider SDK. A unit test of one could only assert
  // that it calls the SDK the way the test was written to expect; what they
  // actually promise is verified against the Firebase emulator, which is
  // pending item #2 in docs/DECISIONS.md.
  '/data/data_sources/',
  'lib/l10n/',
  'lib/main.dart',
  'lib/firebase_options.dart',
  'lib/injection_container.dart',
  'lib/core/constants/',
  'lib/config/theme/design_tokens.dart',
  '/domain/repository/',
  '/domain/params/',
  '_state.dart',
  '_event.dart',
];

/// How many files may still lack a mirrored test. Lower it, never raise it.
const _knownMissingTestCount = 28;

bool _isDataLayer(File file) => file.path.contains('/data/');

bool _isDomainLayer(File file) => file.path.contains('/domain/');

bool _isPresentationLayer(File file) => file.path.contains('/presentation/');

bool _isDataSource(File file) => file.path.contains('/data/data_sources/');

bool _isModel(File file) => file.path.contains('/data/models/');

bool _isBloc(File file) => file.path.contains('/presentation/bloc/');

bool _isRepositoryInterface(File file) =>
    file.path.contains('/domain/repository/');

/// The real repository implementations. The in-memory doubles are excluded:
/// they are stand-ins kept for development, argued in `docs/DECISIONS.md`.
bool _isRepositoryImplementation(File file) =>
    file.path.contains('/data/repository/') &&
    !file.path.contains('_in_memory_');

List<File> _dartFilesUnder(String directory) {
  return Directory(directory)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

final _importPattern = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

Iterable<String> _importsOf(File file) => _importPattern
    .allMatches(file.readAsStringSync())
    .map((match) => match.group(1)!);

/// Turns an import into a path that can be matched against `lib/...`, so that
/// package imports and relative ones are judged the same way.
String _resolve(File file, String import) {
  if (import.startsWith('package:news_app_clean_architecture/')) {
    return 'lib/${import.split('/').skip(1).join('/')}';
  }

  if (import.startsWith('dart:') || import.startsWith('package:')) {
    return import;
  }

  final directory = File(file.path).parent.path;

  return _normalise('$directory/$import');
}

String _normalise(String path) {
  final segments = <String>[];

  for (final segment in path.split('/')) {
    if (segment == '.' || segment.isEmpty) continue;
    if (segment == '..') {
      if (segments.isNotEmpty) segments.removeLast();
      continue;
    }
    segments.add(segment);
  }

  return segments.join('/');
}

/// Every `file -> import` pair where the resolved import [isForbidden].
List<String> _violations(
  Iterable<File> files,
  bool Function(String target) isForbidden,
) {
  final found = <String>[];

  for (final file in files) {
    for (final import in _importsOf(file)) {
      if (isForbidden(_resolve(file, import))) {
        found.add('${file.path} -> $import');
      }
    }
  }

  return found;
}
