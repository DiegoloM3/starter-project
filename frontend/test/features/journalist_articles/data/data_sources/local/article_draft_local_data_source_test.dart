import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/article_draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory temporary;
  late Directory draftFolder;
  late ArticleDraftLocalDataSource dataSource;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('article_draft');
    draftFolder = Directory('${temporary.path}/draft');
    SharedPreferences.setMockInitialValues({});
    dataSource = ArticleDraftLocalDataSource(await SharedPreferences.getInstance(), draftFolder);
  });

  tearDown(() => temporary.delete(recursive: true));

  Future<ArticleThumbnailEntity> pickedImage(String name) async {
    final file = await File('${temporary.path}/$name').writeAsBytes([1, 2, 3]);
    return ArticleThumbnailEntity(localPath: file.path, sizeInBytes: 3);
  }

  test('has no draft until one is written', () {
    expect(dataSource.readDraft(), isNull);
  });

  test('reads back the written texts, also after relaunching the app', () async {
    await dataSource.writeDraft(const ArticleDraftEntity(title: 'Half written', content: 'Body', author: 'Me'));

    final relaunched = ArticleDraftLocalDataSource(await SharedPreferences.getInstance(), draftFolder);

    expect(relaunched.readDraft()!.toEntity(), const ArticleDraftEntity(title: 'Half written', content: 'Body', author: 'Me'));
  });

  test('keeps its own copy of the thumbnail, which survives the picked file being deleted', () async {
    final picked = await pickedImage('picked.jpg');
    await dataSource.writeDraft(ArticleDraftEntity(title: 'T', thumbnail: picked));

    await File(picked.localPath).delete();

    final thumbnail = dataSource.readDraft()!.thumbnail!;
    expect(thumbnail.localPath, startsWith(draftFolder.path));
    expect(thumbnail.extension, 'jpg');
    expect(await File(thumbnail.localPath).readAsBytes(), [1, 2, 3]);
  });

  test('copies the same picked image only once', () async {
    final picked = await pickedImage('picked.png');

    await dataSource.writeDraft(ArticleDraftEntity(title: 'T', thumbnail: picked));
    await dataSource.writeDraft(ArticleDraftEntity(title: 'Ti', thumbnail: picked));

    expect(draftFolder.listSync(), hasLength(1));
  });

  test('replaces the copy when another image is picked', () async {
    await dataSource.writeDraft(ArticleDraftEntity(title: 'T', thumbnail: await pickedImage('first.jpg')));

    await dataSource.writeDraft(ArticleDraftEntity(title: 'T', thumbnail: await pickedImage('second.webp')));

    expect(draftFolder.listSync().single.path, endsWith('.webp'));
    expect(dataSource.readDraft()!.thumbnail!.extension, 'webp');
  });

  test('finds the thumbnail after an app update moves the app folder, as iOS does', () async {
    await dataSource.writeDraft(ArticleDraftEntity(title: 'T', thumbnail: await pickedImage('picked.jpg')));
    final movedFolder = await draftFolder.rename('${temporary.path}/moved');

    final updated = ArticleDraftLocalDataSource(await SharedPreferences.getInstance(), movedFolder);

    final thumbnail = updated.readDraft()!.thumbnail!;
    expect(thumbnail.localPath, startsWith(movedFolder.path));
    expect(File(thumbnail.localPath).existsSync(), isTrue);
  });

  test('keeps the texts when the copy of the thumbnail is gone', () async {
    await dataSource.writeDraft(ArticleDraftEntity(title: 'T', thumbnail: await pickedImage('picked.jpg')));

    await draftFolder.delete(recursive: true);

    expect(dataSource.readDraft()!.toEntity(), const ArticleDraftEntity(title: 'T'));
  });

  test('deleting removes the texts and the copy of the thumbnail', () async {
    await dataSource.writeDraft(ArticleDraftEntity(title: 'T', thumbnail: await pickedImage('picked.jpg')));

    await dataSource.deleteDraft();

    expect(dataSource.readDraft(), isNull);
    expect(draftFolder.existsSync(), isFalse);
  });

  test('fails to read a corrupted draft', () async {
    SharedPreferences.setMockInitialValues({'journalist_articles.draft': '[1, 2]'});
    final corrupted = ArticleDraftLocalDataSource(await SharedPreferences.getInstance(), draftFolder);

    expect(corrupted.readDraft, throwsFormatException);
  });
}
