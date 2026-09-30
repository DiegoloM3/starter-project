// The demo video of the app (docs/media/demo.mp4): every feature, step by step, with captions.
//
// It drives the real app against the Firebase Emulator Suite, like publish_article_journey_test.
// Only the system photo sheet is replaced: the demo photo (a real photo with its camera and GPS
// metadata) goes through the app's own gallery data source, metadata removal included.
//
// Skipped unless --dart-define=RECORD_DEMO=true. Record it with tool/record_demo_video.sh, which
// runs this test on an iOS simulator and records the screen between DEMO_START and DEMO_END.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/gallery_image_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/thumbnail_picker_repository_impl.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_thumbnail_from_gallery.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bool _recordingDemo = bool.fromEnvironment('RECORD_DEMO');
const bool _useFirebaseEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
const String _demoPhotoPath = String.fromEnvironment('DEMO_PHOTO');
const String _contentHint = 'Add article here… Use the toolbar for **bold** text and ## subtitles.';

/// The system photo sheet, which the test cannot tap, returning a copy of the demo photo.
class _DemoPhotoSheet extends ImagePicker {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    final copy = await File(_demoPhotoPath).copy('${Directory.systemTemp.path}/IMG_0001.JPG');
    return XFile(copy.path);
  }
}

class _Caption {
  final String title;
  final String body;

  /// A full-screen title card instead of the band under the app.
  final bool isTitleCard;

  const _Caption(this.title, this.body, {this.isTitleCard = false});
}

/// The app with a caption band under it, like a subtitled screen recording.
class _DemoFrame extends StatelessWidget {
  final ValueListenable<_Caption> caption;
  final Widget app;

  const _DemoFrame({required this.caption, required this.app});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery.fromView(
        view: View.of(context),
        child: Builder(builder: (context) {
          final media = MediaQuery.of(context);
          return ColoredBox(
            color: const Color(0xFF15131A),
            child: Column(children: [
              Expanded(
                child: Stack(children: [
                  MediaQuery(
                    data: media.copyWith(
                      padding: media.padding.copyWith(bottom: 0),
                      viewPadding: media.viewPadding.copyWith(bottom: 0),
                    ),
                    child: app,
                  ),
                  ValueListenableBuilder<_Caption>(
                    valueListenable: caption,
                    builder: (_, current, __) => current.isTitleCard ? _TitleCard(current) : const SizedBox(),
                  ),
                ]),
              ),
              ValueListenableBuilder<_Caption>(
                valueListenable: caption,
                builder: (_, current, __) => _CaptionBand(current, bottomInset: media.padding.bottom),
              ),
            ]),
          );
        }),
      ),
    );
  }
}

const _noScaling = TextScaler.noScaling;

class _CaptionBand extends StatelessWidget {
  final _Caption caption;
  final double bottomInset;

  const _CaptionBand(this.caption, {required this.bottomInset});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136 + bottomInset,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, 14, 18, 10 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF15131A),
        border: Border(top: BorderSide(color: Color(0xFF7C5CD6), width: 3)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Column(
          key: ValueKey(caption.title + caption.body),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caption.isTitleCard ? '' : caption.title,
              textScaler: _noScaling,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              caption.isTitleCard ? '' : caption.body,
              textScaler: _noScaling,
              maxLines: 4,
              style: const TextStyle(color: Color(0xFFD9D4E7), fontSize: 14, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  final _Caption caption;

  const _TitleCard(this.caption);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xFF15131A),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 56, height: 5, color: const Color(0xFF7C5CD6)),
              const SizedBox(height: 22),
              Text(
                caption.title,
                textScaler: _noScaling,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.2),
              ),
              const SizedBox(height: 18),
              Text(
                caption.body,
                textScaler: _noScaling,
                style: const TextStyle(color: Color(0xFFD9D4E7), fontSize: 17, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Steps of the demo, at a pace people can follow.
class _Demo {
  final WidgetTester tester;
  final ValueNotifier<_Caption> caption = ValueNotifier(const _Caption('', ''));

  _Demo(this.tester);

  Future<void> say(String title, String body) async {
    caption.value = _Caption(title, body);
    await wait(0.8);
  }

  Future<void> showTitleCard(String title, String body, {double seconds = 4.5}) async {
    caption.value = _Caption(title, body, isTitleCard: true);
    await wait(seconds);
  }

  /// Lets real time pass while the app keeps drawing (animations, voice, network).
  Future<void> wait(double seconds) async {
    final end = DateTime.now().add(Duration(milliseconds: (seconds * 1000).round()));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> waitFor(Finder finder) async {
    final deadline = DateTime.now().add(const Duration(seconds: 45));
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(deadline)) fail('Timed out waiting for $finder');
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> tap(Finder finder, {double thenWait = 1.2}) async {
    await waitFor(finder);
    await tester.tap(finder.first, warnIfMissed: false);
    await wait(thenWait);
  }

  /// Types [text] into [field] a few characters at a time, like a person would.
  Future<void> type(Finder field, String text, {String before = ''}) async {
    final characters = text.characters.toList();
    for (var end = 1; end <= characters.length; end += 2) {
      await tester.enterText(field, before + characters.take(end).join());
      await tester.pump(const Duration(milliseconds: 45));
    }
    await tester.enterText(field, before + text);
    await wait(0.6);
  }

  TextEditingController controllerOf(Finder field) => tester.widget<TextField>(field).controller!;

  /// Selects [target] inside [field], as a long press and drag would.
  Future<void> select(Finder field, String target) async {
    final controller = controllerOf(field);
    final start = controller.text.indexOf(target);
    controller.selection = TextSelection(baseOffset: start, extentOffset: start + target.length);
    await wait(0.7);
  }

  Future<void> scrollTo(Finder finder) async {
    await tester.scrollUntilVisible(finder, 250, scrollable: find.byType(Scrollable).first);
    await wait(0.6);
  }

  Future<void> drag(Finder finder, Offset offset) async {
    await tester.timedDrag(finder.first, offset, const Duration(milliseconds: 700));
    await wait(1);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!_recordingDemo) return;
    if (!_useFirebaseEmulators) fail('The demo publishes articles: run it against the Firebase emulators only.');
    await initializeDependencies();
    // A first visit: no signature or draft left by earlier runs on this device.
    await (await SharedPreferences.getInstance()).clear();
    sl.allowReassignment = true;
    sl.registerSingleton<PickThumbnailFromGalleryUseCase>(
      PickThumbnailFromGalleryUseCase(ThumbnailPickerRepositoryImpl(GalleryImageDataSource(_DemoPhotoSheet()))),
    );
  });

  testWidgets('demo of the whole app', (tester) async {
    final demo = _Demo(tester);
    final dispatcher = tester.platformDispatcher;
    dispatcher.localesTestValue = const [Locale('en', 'US')];
    dispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(dispatcher.clearAllTestValues);

    Widget framedApp() => _DemoFrame(caption: demo.caption, app: const MyApp());
    await tester.pumpWidget(framedApp());
    await demo.showTitleCard(
      'Daily News:\npublica tus artículos',
      'Prueba técnica de Symmetry.\n\nLa app completa en un iPhone (simulador), contra Firebase Emulator Suite '
          'con las mismas reglas de seguridad que producción.',
      seconds: 1,
    );
    debugPrint('DEMO_START');
    await demo.wait(4.5);

    // 1. The original tab and the new one.
    await demo.say('1 · Noticias del día', 'La pestaña original de la app, con las noticias de NewsAPI.');
    await demo.waitFor(find.text('Community'));
    await demo.wait(2);
    await demo.drag(find.byType(ListView).first, const Offset(0, -500));
    await demo.drag(find.byType(ListView).first, const Offset(0, 500));

    await demo.say('2 · Artículos de la comunidad',
        'Lo que publican los periodistas desde la app, el más reciente primero. Desliza hacia abajo para actualizar.');
    await demo.tap(find.text('Community'), thenWait: 2.5);
    await demo.drag(find.byType(RefreshIndicator), const Offset(0, 300));
    await demo.wait(1.5);

    // 2. Publishing, with field errors.
    await demo.say('3 · Publicar un artículo', 'El botón + abre el formulario. Si falta algo, cada campo explica qué hacer.');
    await demo.tap(find.byTooltip('Publish an article'), thenWait: 1.5);
    await demo.tap(find.text('Publish Article').last, thenWait: 3.5);

    await demo.say('Título y firma',
        'El contador cuenta igual que las reglas del backend: el emoji suma 2 caracteres, no 1.');
    await demo.type(find.widgetWithText(TextField, 'Title'), 'Las dunas de la playa vuelven a florecer 🌼');
    await demo.wait(1.2);
    await demo.type(find.widgetWithText(TextField, 'Written by'), 'Laura Gómez');

    // 3. The photo: gallery only, metadata removed.
    await demo.say('4 · La foto, solo de la galería',
        'Foto real de una NIKON D90, con su ubicación GPS. Como la miniatura es pública, la app le quita esos '
            'datos antes de subirla. (Aquí se simula la hoja de fotos del sistema.)');
    await demo.tap(find.text('Attach Image'), thenWait: 2);
    final thumbnailFile = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<FileImage>()
        .first
        .file;
    final original = latin1.decode(await File(_demoPhotoPath).readAsBytes(), allowInvalid: true);
    final uploaded = latin1.decode(await thumbnailFile.readAsBytes(), allowInvalid: true);
    expect(original, allOf(contains('Exif'), contains('NIKON')));
    expect(uploaded, isNot(anyOf(contains('Exif'), contains('NIKON'))));
    await demo.say('Metadatos quitados ✓',
        'Comprobado en este momento: la foto original tiene EXIF con cámara y GPS; la que se subirá, ninguno.');
    await demo.wait(3);

    // 4. The Markdown editor.
    final content = find.widgetWithText(TextField, _contentHint);
    await demo.scrollTo(content);
    await demo.say('5 · Editor Markdown',
        'Barra para subtítulos, negrita y listas, y debajo las palabras y el tiempo de lectura, en vivo.');
    await demo.type(content, 'Una playa que se recupera');
    await demo.tap(find.byTooltip('Subtitle'), thenWait: 1);
    var text = demo.controllerOf(content).text;
    await demo.type(content, '\n\nTras dos años de protección, las dunas del litoral vuelven a llenarse de flores. '
        'Los vecinos plantaron más de mil ejemplares.', before: text);
    await demo.select(content, 'las dunas del litoral');
    await demo.tap(find.byTooltip('Bold'), thenWait: 1.2);
    text = demo.controllerOf(content).text;
    await demo.type(content, '\n\nCamina solo por las pasarelas.\nNo arranques las plantas.', before: text);
    await demo.select(content, 'Camina solo por las pasarelas.\nNo arranques las plantas.');
    await demo.tap(find.byTooltip('Bulleted list'), thenWait: 2);

    await demo.say('Vista previa', 'Así se verá el artículo publicado.');
    await demo.tap(find.text('Preview'), thenWait: 3.5);
    await demo.tap(find.text('Write'), thenWait: 1);

    // 5. Publishing for real.
    await demo.say('6 · Publicar',
        'Sube la foto a Cloud Storage y escribe el artículo en Firestore. El botón muestra el progreso y no publica dos veces.');
    await demo.tap(find.text('Publish Article').last, thenWait: 0.5);
    await demo.waitFor(find.text('Your article has been published.'));
    await demo.say('Publicado ✓', 'De vuelta en Comunidad, con un aviso y el artículo en primer lugar.');
    await demo.wait(3.5);

    // 6. The article and reading it aloud.
    await demo.say('7 · El artículo', 'Markdown con formato, autor, fecha y tiempo de lectura.');
    await demo.tap(find.text('Las dunas de la playa vuelven a florecer 🌼'), thenWait: 3.5);
    await demo.say('8 · Escuchar el artículo',
        'Lo lee la voz del dispositivo, sin conexión ni coste. La frase que suena se resalta y la pantalla la sigue. '
            '(El simulador no graba el audio.)');
    await demo.tap(find.text('Listen to this article'), thenWait: 16);
    await demo.say('Detener', 'Al parar, vuelve el texto con todo su formato.');
    await demo.tap(find.text('Stop reading'), thenWait: 2.5);
    await demo.tap(find.byTooltip('Back'), thenWait: 1.5);

    // 7. Signature and draft.
    await demo.say('9 · La firma se recuerda', 'El siguiente artículo ya viene firmado.');
    await demo.tap(find.byTooltip('Publish an article'), thenWait: 3);
    await demo.say('10 · El borrador se guarda solo', 'Mientras escribes, en el dispositivo, un segundo después de cada pausa.');
    await demo.type(find.widgetWithText(TextField, 'Title'), 'Nueva ruta de bicicletas por el centro');
    await demo.tap(find.text('Attach Image'), thenWait: 1.5);
    await demo.wait(1.5);
    await demo.say('Al salir con algo escrito', 'La app pregunta: seguir escribiendo, descartar o guardar el borrador.');
    await demo.tap(find.byTooltip('Back'), thenWait: 3);
    await demo.tap(find.text('Save draft'), thenWait: 1.5);

    await demo.showTitleCard('Cerramos la app…', 'y la volvemos a abrir.', seconds: 1.2);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(framedApp());
    await demo.wait(1.3);
    await demo.say('El borrador sigue ahí',
        'Título, firma y foto, con la opción de empezar de nuevo (Start over). Lo terminamos y lo publicamos…');
    await demo.waitFor(find.text('Community'));
    await demo.tap(find.byTooltip('Publish an article'), thenWait: 4);
    final content2 = find.widgetWithText(TextField, _contentHint);
    await demo.scrollTo(content2);
    await demo.type(content2, 'Los carriles bici unirán la estación con el parque en menos de un año.');

    // Offline: the recording script pauses the Firebase emulators, so the server stops answering.
    debugPrint('DEMO_OFFLINE');
    await demo.wait(1.5);
    await demo.say('… sin conexión', 'El servidor deja de responder. La app no se queda colgada ni publica a medias.');
    await demo.tap(find.text('Publish Article').last, thenWait: 0.5);
    final failure = find.textContaining('could not be published');
    for (var second = 1; failure.evaluate().isEmpty && second <= 45; second++) {
      demo.caption.value = _Caption('… sin conexión', 'Esperando al servidor… $second s de un máximo de 30 s.');
      await demo.wait(1);
    }
    await demo.say('Aviso con Reintentar', 'El borrador sigue guardado. Vuelve la conexión y reintentamos.');
    debugPrint('DEMO_ONLINE');
    await demo.wait(3);
    await demo.tap(find.text('Retry'), thenWait: 0.5);
    await demo.waitFor(find.text('Your article has been published.'));
    await demo.say('Publicado al reintentar ✓', 'Y el borrador se borra: el formulario vuelve a empezar vacío, con la firma.');
    await demo.wait(2.5);
    await demo.tap(find.byTooltip('Publish an article'), thenWait: 3);
    await demo.tap(find.byTooltip('Back'), thenWait: 1.5);

    // 8. Dark mode, live.
    await demo.say('11 · Modo oscuro', 'Sigue el ajuste del teléfono y cambia al instante.');
    await demo.tap(find.text('Community'), thenWait: 1.5);
    dispatcher.platformBrightnessTestValue = Brightness.dark;
    await demo.wait(3);
    await demo.tap(find.text('Las dunas de la playa vuelven a florecer 🌼'), thenWait: 2);
    await demo.say('El resaltado se lee en los dos modos', 'Texto oscuro sobre el amarillo, también de noche.');
    await demo.tap(find.text('Listen to this article'), thenWait: 7);
    await demo.tap(find.text('Stop reading'), thenWait: 1);

    // 9. Spanish, live.
    await demo.say('12 · En español o inglés', 'Según el idioma del teléfono: textos, fechas, números y menús.');
    dispatcher.localesTestValue = const [Locale('es', 'ES')];
    await demo.wait(4);
    await demo.say('Texto seleccionable', 'Para copiar una cita, con el menú del sistema en tu idioma.');
    await tester.longPress(find.textContaining('Tras dos años', findRichText: true));
    await demo.wait(3.5);
    await tester.tapAt(const Offset(200, 120));
    await demo.wait(0.8);
    await demo.tap(find.byTooltip('Atrás'), thenWait: 1.5);
    dispatcher.platformBrightnessTestValue = Brightness.light;
    await demo.say('Los errores, también traducidos', 'Y con el tema claro de nuevo, al instante.');
    await demo.tap(find.byTooltip('Publicar un artículo'), thenWait: 1.2);
    await demo.tap(find.text('Publicar artículo').last, thenWait: 3.5);
    await demo.tap(find.byTooltip('Atrás'), thenWait: 1.5);

    // 10. Large text.
    await demo.say('13 · Letra grande', 'Con el tamaño de letra de accesibilidad todo se adapta, sin cortarse.');
    dispatcher.textScaleFactorTestValue = 1.8;
    await demo.wait(3);
    await demo.drag(find.descendant(of: find.byType(RefreshIndicator), matching: find.byType(ListView)), const Offset(0, -600));
    await demo.wait(1.5);
    dispatcher.clearTextScaleFactorTestValue();
    await demo.wait(1.5);

    await demo.showTitleCard(
      'Hecho con Flutter, Firebase y BLoC',
      'Arquitectura limpia · 355 tests unitarios y de widgets (44 de accesibilidad) · 66 tests de reglas de '
          'seguridad · test de integración · CI en verde · Android e iOS.',
      seconds: 6,
    );
    debugPrint('DEMO_END');
    await demo.wait(1);
  }, skip: !_recordingDemo, timeout: const Timeout(Duration(minutes: 10)));
}
