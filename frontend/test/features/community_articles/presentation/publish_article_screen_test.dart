import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/article_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_articles.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/pick_article_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/publish_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/screens/publish_article_screen.dart';

class ScreenRepository implements CommunityArticleRepository {
  DataState<ArticleImageEntity?> imageResult = const DataSuccess(null);
  DataState<CommunityArticleEntity> publishResult =
      const DataFailed(AppFailure('unused'));
  Completer<void>? publishGate;

  @override
  Future<DataState<List<CommunityArticleEntity>>>
      getPublishedArticles() async => const DataSuccess([]);
  @override
  Future<DataState<ArticleImageEntity?>> pickImage() async => imageResult;
  @override
  Future<DataState<CommunityArticleEntity>> publishArticle(
      PublishArticleParams params) async {
    await publishGate?.future;
    return publishResult;
  }
}

final testImage = ArticleImageEntity(
  bytes: base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  ),
  fileName: 'story.png',
  mimeType: 'image/png',
);

const cropFixture =
    'iVBORw0KGgoAAAANSUhEUgAAALYAAABkCAIAAACkZF13AAABJ0lEQVR42u3aMQ0AIAxFwSqpOnRWCSKQgIGmMwmXsN7y87YSWXt4Z+Xw2B9smIyVCCsRViKsRFiJsBJhJWIyiZiMbRMxCjtbibASYSXCSoSVCCsRViKsREwmEZOxfSJGYd1oWImwEmElwkqElQgrEZNJxGSsRFh/V1k3GlYirERYibASMbdETMZKhJUIKxHW31XWjYaVCCsRViImYyXCSoSVCCsRViKsv6usGw0rEZNJxGSsRFiJsBJhJcJKhJUI6++qQd1oTMZKhJUIKxFWIqxEWImwEmElYjLW31XWjYaVCCsRViKsRFiJsBIxmURMxkqE9XeVdaNhJcJKhJUIKxFzS8RkrERYibASYf1dZd1oWImwEjG3REzGSoSVCCsRViKsRNin7QXZQX+JdznrOgAAAABJRU5ErkJggg==';

const portraitCropFixture =
    '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';

CommunityArticleEntity publishedArticle() => const CommunityArticleEntity(
      id: 'article',
      author: 'Reporter',
      title: 'A valid title',
      description: 'This body is long enough to publish safely.',
      url: '',
      urlToImage: '',
      publishedAt: '',
      content: 'This body is long enough to publish safely.',
      thumbnailPath: 'media/articles/reporter/article/story.png',
      payloadHash: 'hash',
      ownerUid: 'owner',
    );

class EmptyFeedCubit extends CommunityFeedCubit {
  EmptyFeedCubit() : super(GetCommunityArticlesUseCase(ScreenRepository()));
}

void main() {
  testWidgets('renders the publish placeholders and action', (tester) async {
    final repository = ScreenRepository();
    await tester.pumpWidget(MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => PublishArticleCubit(
                  PublishArticleUseCase(repository),
                  PickArticleImageUseCase(repository))),
          BlocProvider<CommunityFeedCubit>(create: (_) => EmptyFeedCubit()),
        ],
        child: const PublishArticleScreen(),
      ),
    ));
    expect(find.text('Write your title here...'), findsOneWidget);
    expect(find.text('Add article here, .....'), findsOneWidget);
    expect(find.text('Attach Image'), findsOneWidget);
    expect(find.text('Publish Article'), findsOneWidget);
    expect(
      tester.getSize(find.byType(TextField).first).height,
      closeTo(133, 2),
    );

    await tester.tap(find.text('Publish Article'));
    await tester.pump();
    expect(find.text('Use 5–120 characters.'), findsOneWidget);
    expect(
      tester.getSize(find.byType(TextField).first).height,
      greaterThan(133),
    );
  });

  testWidgets('keeps the publish route open while submission is pending',
      (tester) async {
    final repository = ScreenRepository()
      ..imageResult = DataSuccess(testImage)
      ..publishGate = Completer<void>()
      ..publishResult = DataSuccess(publishedArticle());
    final publishCubit = PublishArticleCubit(
      PublishArticleUseCase(repository),
      PickArticleImageUseCase(repository),
    );
    await publishCubit.selectImage();
    final cropState = publishCubit.state as PublishArticleCropRequired;
    publishCubit.confirmImageCrop(cropState.sourceImage);
    final feedCubit = EmptyFeedCubit();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: publishCubit),
                      BlocProvider<CommunityFeedCubit>.value(value: feedCubit),
                    ],
                    child: const PublishArticleScreen(),
                  ),
                ),
              ),
              child: const Text('Open publisher'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open publisher'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'A valid title');
    await tester.enterText(
        fields.at(1), 'This body is long enough to publish safely.');
    await tester.tap(find.text('Publish Article'));
    await tester.pump();

    expect(find.text('Publishing...'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    expect(find.text('Publishing...'), findsOneWidget);

    repository.publishGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Open publisher'), findsOneWidget);
  });

  testWidgets('matches the compact phone editor without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = ScreenRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => PublishArticleCubit(
                PublishArticleUseCase(repository),
                PickArticleImageUseCase(repository),
              ),
            ),
            BlocProvider<CommunityFeedCubit>(create: (_) => EmptyFeedCubit()),
          ],
          child: const PublishArticleScreen(),
        ),
      ),
    );

    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.text('Publish article'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the editor usable in a short keyboard viewport',
      (tester) async {
    tester.view.physicalSize = const Size(390, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = ScreenRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => PublishArticleCubit(
                PublishArticleUseCase(repository),
                PickArticleImageUseCase(repository),
              ),
            ),
            BlocProvider<CommunityFeedCubit>(create: (_) => EmptyFeedCubit()),
          ],
          child: const PublishArticleScreen(),
        ),
      ),
    );

    await tester.showKeyboard(find.byType(TextFormField).at(1));
    await tester.pump();
    expect(find.text('Add article here, .....'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the full selected image and clear image actions',
      (tester) async {
    final repository = ScreenRepository()..imageResult = DataSuccess(testImage);
    final publishCubit = PublishArticleCubit(
      PublishArticleUseCase(repository),
      PickArticleImageUseCase(repository),
    );
    await publishCubit.selectImage();
    final cropState = publishCubit.state as PublishArticleCropRequired;
    publishCubit.confirmImageCrop(cropState.sourceImage);
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: publishCubit),
            BlocProvider<CommunityFeedCubit>(create: (_) => EmptyFeedCubit()),
          ],
          child: const PublishArticleScreen(),
        ),
      ),
    );

    final selectedImage = find.bySemanticsLabel(
      'Selected article image. Confirmed crop ratio is 1.82 to 1.',
    );
    expect(selectedImage, findsOneWidget);
    expect(find.text('Replace image'), findsOneWidget);
    expect(find.text('Adjust crop'), findsOneWidget);
    expect(find.text('Remove image'), findsOneWidget);
    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.cover);
    expect(
      tester.getSize(find.byKey(const ValueKey('replace-image'))).height,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('remove-image'))).height,
      greaterThanOrEqualTo(44),
    );

    await tester.ensureVisible(find.text('Remove image'));
    await tester.tap(find.text('Remove image'));
    await tester.pump();
    expect(find.text('Attach Image'), findsOneWidget);
    expect(selectedImage, findsNothing);
  });

  testWidgets('confirms a real crop with the required output ratio',
      (tester) async {
    final source = ArticleImageEntity(
      bytes: base64Decode(cropFixture),
      fileName: 'landscape.png',
      mimeType: 'image/png',
    );
    late Future<ArticleImageEntity?> cropResult;
    ArticleImageEntity? cropped;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                cropResult = Navigator.of(context).push<ArticleImageEntity>(
                  MaterialPageRoute(
                    builder: (_) => ArticleImageCropDialog(sourceImage: source),
                  ),
                );
                cropResult.then((value) => cropped = value);
              },
              child: const Text('Open crop editor'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open crop editor'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('confirm-image-crop')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('confirm-image-crop')));
    await tester.pump();
    for (var attempt = 0; attempt < 20; attempt++) {
      if (cropped != null) break;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pump();
    }

    expect(cropped, isNotNull);
    final confirmed = cropped!;
    expect(confirmed.isSupportedRaster, isTrue);
    final ratio = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(confirmed.bytes),
      );
      final frame = await codec.getNextFrame();
      final result = frame.image.width / frame.image.height;
      frame.image.dispose();
      codec.dispose();
      return result;
    });
    expect(ratio, closeTo(1.82, 0.03));
  });

  testWidgets('keeps the crop editor usable in a short landscape viewport',
      (tester) async {
    tester.view.physicalSize = const Size(390, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleImageCropDialog(
          sourceImage: ArticleImageEntity(
            bytes: base64Decode(cropFixture),
            fileName: 'landscape.png',
            mimeType: 'image/png',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Adjust image crop'), findsOneWidget);
    expect(find.text('Use this crop'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('starts an extreme portrait crop with a wide visible frame',
      (tester) async {
    final source = ArticleImageEntity(
      bytes: base64Decode(portraitCropFixture),
      fileName: 'portrait.png',
      mimeType: 'image/png',
    );
    late Future<ArticleImageEntity?> cropResult;
    ArticleImageEntity? cropped;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                cropResult = Navigator.of(context).push<ArticleImageEntity>(
                  MaterialPageRoute(
                    builder: (_) => ArticleImageCropDialog(sourceImage: source),
                  ),
                );
                cropResult.then((value) => cropped = value);
              },
              child: const Text('Open portrait crop editor'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open portrait crop editor'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pump();

    final frame = find.byKey(const ValueKey('image-crop-frame'));
    final viewport = find.byKey(const ValueKey('image-crop-viewport'));
    expect(frame, findsOneWidget);
    expect(
      tester.getSize(frame).width,
      greaterThan(tester.getSize(viewport).width * .9),
    );
    expect(
      tester.getSize(frame).width / tester.getSize(frame).height,
      closeTo(1.82, .03),
    );

    await tester.tap(find.byKey(const ValueKey('confirm-image-crop')));
    await tester.pump();
    for (var attempt = 0; attempt < 20; attempt++) {
      if (cropped != null) break;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pump();
    }

    expect(cropped, isNotNull);
    final confirmed = cropped!;
    final ratio = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(confirmed.bytes),
      );
      final frame = await codec.getNextFrame();
      final result = frame.image.width / frame.image.height;
      frame.image.dispose();
      codec.dispose();
      return result;
    });
    expect(ratio, closeTo(1.82, .03));
  });

  testWidgets('scrolls crop controls above the keyboard inset', (tester) async {
    const media = MediaQueryData(
      size: Size(390, 480),
      devicePixelRatio: 1,
      viewInsets: EdgeInsets.only(bottom: 220),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: media,
          child: ArticleImageCropDialog(
            sourceImage: ArticleImageEntity(
              bytes: base64Decode(cropFixture),
              fileName: 'landscape.png',
              mimeType: 'image/png',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Use this crop'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
