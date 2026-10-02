import 'dart:io';

/// The app's own Dart files, read as text, so the tests in this folder can check the rules of
/// docs/APP_ARCHITECTURE.md and docs/ARCHITECTURE_VIOLATIONS.md against the code. Each test is named after the
/// rule it checks, and a failure lists every file that breaks it.
///
/// These tests check `lib/` as a whole, so `test/architecture/` is the one folder of `test/` that does not
/// mirror a file of `lib/`.

const String _packagePrefix = 'package:news_app_clean_architecture/';

/// The files that wire the layers together: the app's entry point, the service locator and the Firebase setup.
/// The documentation does not cover them, and they are the only files that may import every layer.
const Set<String> compositionRoot = {
  'lib/main.dart',
  'lib/injection_container.dart',
  'lib/firebase_options.dart',
  'lib/firebase_emulators.dart',
};

/// Packages that connect to an external service: Firebase, HTTP, the local database and storage, the gallery
/// (docs/ARCHITECTURE_VIOLATIONS.md, 1.2.3 and 1.2.4).
const List<String> providerPackages = [
  'package:cloud_firestore/',
  'package:firebase_auth/',
  'package:firebase_core/',
  'package:firebase_storage/',
  'package:dio/',
  'package:retrofit/',
  'package:http/',
  'package:floor/',
  'package:sqflite/',
  'package:shared_preferences/',
  'package:image_picker/',
];

enum Layer { data, domain, presentation }

/// A Dart file of `lib/`, with its path relative to the package (`lib/features/auth/domain/entities/user.dart`).
class SourceFile {
  final String path;
  final String text;

  SourceFile(this.path, this.text);

  /// The files and packages it imports or exports, as `lib/...` paths or `package:` / `dart:` URIs.
  late final List<String> imports = RegExp(r"^\s*(?:import|export)\s+'([^']+)'", multiLine: true)
      .allMatches(text)
      .map((match) => resolveImport(path, match.group(1)!))
      .toList();

  late final List<DeclaredClass> classes = RegExp(
    r'^((?:abstract|base|final|interface|sealed)\s+)*class\s+(\w+)([^{]*)\{',
    multiLine: true,
  ).allMatches(text).map((match) => DeclaredClass(match.group(2)!, match.group(3)!, match.group(1) ?? '')).toList();

  /// `features/auth` or `shared/{feature}` for a file of a clean folder.
  String? get cleanFolder => cleanFolderOf(path);

  Layer? get layer => layerOf(path);

  /// The folder inside its layer: `data_sources`, `use_cases`, `bloc`...
  String? get layerFolder => layerFolderOf(path);

  bool get isCompositionRoot => compositionRoot.contains(path);

  /// "lib/x.dart → package:dio/dio.dart", the way a failure lists it.
  String describeImport(String import) => '$path → $import';
}

class DeclaredClass {
  final String name;

  /// What comes between the name and the body: type parameters, `extends`, `with`, `implements`.
  final String header;
  final String modifiers;

  DeclaredClass(this.name, this.header, this.modifiers);

  bool get isAbstract => modifiers.contains('abstract');

  String? get superclass => RegExp(r'extends\s+(\w+)').firstMatch(header)?.group(1);

  String? get implementedInterface => RegExp(r'implements\s+(\w+)').firstMatch(header)?.group(1);
}

/// Every Dart file of `lib/` except the generated ones (`.g.dart`).
final List<SourceFile> libFiles = _readDartFiles('lib').where((file) => !file.path.endsWith('.g.dart')).toList();

/// Every test file of `test/`.
final List<SourceFile> testFiles = _readDartFiles('test').where((file) => file.path.endsWith('_test.dart')).toList();

List<SourceFile> _readDartFiles(String root) {
  final files = Directory(root)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => SourceFile(file.path.replaceAll(r'\', '/'), file.readAsStringSync()))
      .toList();
  return files..sort((a, b) => a.path.compareTo(b.path));
}

String resolveImport(String fromPath, String uri) {
  if (uri.startsWith(_packagePrefix)) return 'lib/${uri.substring(_packagePrefix.length)}';
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return uri;
  final segments = fromPath.split('/')..removeLast();
  for (final segment in uri.split('/')) {
    if (segment == '..') {
      segments.removeLast();
    } else if (segment != '.') {
      segments.add(segment);
    }
  }
  return segments.join('/');
}

String? cleanFolderOf(String path) {
  final segments = path.split('/');
  final isCleanFolder = segments.length > 3 && segments[0] == 'lib' && (segments[1] == 'features' || segments[1] == 'shared');
  return isCleanFolder ? '${segments[1]}/${segments[2]}' : null;
}

Layer? layerOf(String path) {
  if (cleanFolderOf(path) == null) return null;
  final segments = path.split('/');
  return segments.length > 4 ? Layer.values.where((layer) => layer.name == segments[3]).firstOrNull : null;
}

String? layerFolderOf(String path) {
  final segments = path.split('/');
  return layerOf(path) != null && segments.length > 5 ? segments[4] : null;
}

bool isProvider(String import) => providerPackages.any(import.startsWith);

bool isPackage(String import) => import.startsWith('package:');
