import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'source_code.dart';

/// docs/APP_ARCHITECTURE.md → "Folder Structure of the App" and "Clean Folder Requirements".
void main() {
  const layerFolders = {
    'data': {'data_sources', 'models', 'repository'},
    'domain': {'entities', 'repository', 'use_cases'},
    'presentation': {'bloc', 'screens', 'widgets'},
  };

  final cleanFolders = ['lib/features', 'lib/shared']
      .map(Directory.new)
      .where((root) => root.existsSync())
      .expand((root) => root.listSync().whereType<Directory>())
      .toList();

  String nameOf(FileSystemEntity entity) => entity.uri.pathSegments.lastWhere((segment) => segment.isNotEmpty);

  test('lib/ holds config, core, shared and features, plus the files of the composition root', () {
    final unexpected = Directory('lib').listSync().where((entity) {
      if (entity is Directory) return !{'config', 'core', 'shared', 'features'}.contains(nameOf(entity));
      return !compositionRoot.contains('lib/${nameOf(entity)}');
    }).map(nameOf);

    expect(unexpected, isEmpty);
  });

  test('a clean folder is always divided into data, domain and presentation (requirement 1, no exceptions)', () {
    final incomplete = cleanFolders
        .where((folder) => folder.listSync().whereType<Directory>().map(nameOf).toSet().containsAll(layerFolders.keys) == false)
        .map((folder) => folder.path);

    expect(incomplete, isEmpty);
  });

  test('a clean folder holds only its three layers', () {
    final unexpected = cleanFolders
        .expand((folder) => folder.listSync())
        .where((entity) => !layerFolders.containsKey(nameOf(entity)))
        .map((entity) => entity.path);

    expect(unexpected, isEmpty);
  });

  test('each layer only has the folders the documentation names', () {
    final unexpected = <String>[];
    for (final folder in cleanFolders) {
      for (final MapEntry(key: layer, value: allowed) in layerFolders.entries) {
        final layerFolder = Directory('${folder.path}/$layer');
        if (!layerFolder.existsSync()) continue;
        unexpected.addAll(layerFolder.listSync().where((entity) => !allowed.contains(nameOf(entity))).map((entity) => entity.path));
      }
    }

    expect(unexpected, isEmpty, reason: 'data: data_sources, models, repository · domain: entities, repository, use_cases · '
        'presentation: bloc, screens, widgets');
  });

  test('the test folder mirrors lib: each test is named after the file of lib it tests', () {
    final orphans = testFiles
        .where((file) => !file.path.startsWith('test/architecture/'))
        .where((file) => !File('lib/${file.path.substring('test/'.length).replaceFirst(RegExp(r'_test\.dart$'), '.dart')}').existsSync())
        .map((file) => file.path);

    expect(orphans, isEmpty);
  });
}
