import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @landingTagline.
  ///
  /// In es, this message translates to:
  /// **'BIENESTAR · CONOCIMIENTO · COMUNIDAD'**
  String get landingTagline;

  /// No description provided for @landingHeroLine1.
  ///
  /// In es, this message translates to:
  /// **'Un tip al día.'**
  String get landingHeroLine1;

  /// No description provided for @landingHeroLine2.
  ///
  /// In es, this message translates to:
  /// **'Una vida mejor.'**
  String get landingHeroLine2;

  /// No description provided for @landingTermsPrefix.
  ///
  /// In es, this message translates to:
  /// **'Si continuas, aceptas los '**
  String get landingTermsPrefix;

  /// No description provided for @landingTermsOfService.
  ///
  /// In es, this message translates to:
  /// **'Terminos del servicio'**
  String get landingTermsOfService;

  /// No description provided for @landingTermsMiddle.
  ///
  /// In es, this message translates to:
  /// **' de TortuTip y confirmas que has leido nuestra '**
  String get landingTermsMiddle;

  /// No description provided for @landingPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Politica de privacidad'**
  String get landingPrivacyPolicy;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a TortuTip'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Protegemos tu privacidad. Solo Google.'**
  String get loginSubtitle;

  /// No description provided for @onboardingCategoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Personaliza tu feed'**
  String get onboardingCategoriesTitle;

  /// No description provided for @onboardingCategoriesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona los temas que más te interesan para adaptar tu experiencia un 1% cada día.'**
  String get onboardingCategoriesSubtitle;

  /// No description provided for @onboardingNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente →'**
  String get onboardingNext;

  /// No description provided for @onboardingRoleWriter.
  ///
  /// In es, this message translates to:
  /// **'Compartir tips'**
  String get onboardingRoleWriter;

  /// No description provided for @onboardingRoleReader.
  ///
  /// In es, this message translates to:
  /// **'Leer tips'**
  String get onboardingRoleReader;

  /// No description provided for @onboardingDetailsTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos un poco más'**
  String get onboardingDetailsTitle;

  /// No description provided for @onboardingDetailsGender.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get onboardingDetailsGender;

  /// No description provided for @onboardingDetailsAgeRange.
  ///
  /// In es, this message translates to:
  /// **'Rango de edad'**
  String get onboardingDetailsAgeRange;

  /// No description provided for @onboardingGenderFemale.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get onboardingGenderFemale;

  /// No description provided for @onboardingGenderMale.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get onboardingGenderMale;

  /// No description provided for @onboardingGenderOther.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get onboardingGenderOther;

  /// No description provided for @onboardingGenderPreferNotToSay.
  ///
  /// In es, this message translates to:
  /// **'Prefiero no decirlo'**
  String get onboardingGenderPreferNotToSay;

  /// No description provided for @onboardingFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar →'**
  String get onboardingFinish;

  /// No description provided for @feedTitle.
  ///
  /// In es, this message translates to:
  /// **'TortuTip'**
  String get feedTitle;

  /// No description provided for @feedNoArticles.
  ///
  /// In es, this message translates to:
  /// **'No hay artículos disponibles'**
  String get feedNoArticles;

  /// No description provided for @feedStartOver.
  ///
  /// In es, this message translates to:
  /// **'Iniciar de nuevo'**
  String get feedStartOver;

  /// No description provided for @feedReadAll.
  ///
  /// In es, this message translates to:
  /// **'¡Has leído todo!'**
  String get feedReadAll;

  /// No description provided for @feedReadAllSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Empieza de nuevo con un orden aleatorio'**
  String get feedReadAllSubtitle;

  /// No description provided for @articleDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get articleDetailTitle;

  /// No description provided for @articleDetailRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get articleDetailRetry;

  /// No description provided for @createArticleDiscardTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Descartar artículo?'**
  String get createArticleDiscardTitle;

  /// No description provided for @createArticleDiscardContent.
  ///
  /// In es, this message translates to:
  /// **'Tu artículo se perderá si sales ahora.'**
  String get createArticleDiscardContent;

  /// No description provided for @createArticleKeepEditing.
  ///
  /// In es, this message translates to:
  /// **'Seguir editando'**
  String get createArticleKeepEditing;

  /// No description provided for @createArticleDiscard.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get createArticleDiscard;

  /// No description provided for @createArticleCameraOption.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get createArticleCameraOption;

  /// No description provided for @createArticleLibraryOption.
  ///
  /// In es, this message translates to:
  /// **'Biblioteca de fotos'**
  String get createArticleLibraryOption;

  /// No description provided for @createArticleNotAuthError.
  ///
  /// In es, this message translates to:
  /// **'Error: usuario no autenticado'**
  String get createArticleNotAuthError;

  /// No description provided for @createArticlePreview.
  ///
  /// In es, this message translates to:
  /// **'Vista previa'**
  String get createArticlePreview;

  /// No description provided for @createArticlePublish.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get createArticlePublish;

  /// No description provided for @createArticleUpdate.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get createArticleUpdate;

  /// No description provided for @createArticleChooseCategory.
  ///
  /// In es, this message translates to:
  /// **'Elegir Categoría'**
  String get createArticleChooseCategory;

  /// No description provided for @createArticleTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu título...'**
  String get createArticleTitleHint;

  /// No description provided for @createArticleBodyHint.
  ///
  /// In es, this message translates to:
  /// **'Empieza tu camino aquí... comparte tu sabiduría con el mundo.'**
  String get createArticleBodyHint;

  /// No description provided for @categoryListTitle.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get categoryListTitle;

  /// No description provided for @categoryListEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin artículos'**
  String get categoryListEmpty;

  /// No description provided for @categoryListEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay artículos publicados en esta categoría.'**
  String get categoryListEmptySubtitle;

  /// No description provided for @categoryListLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get categoryListLoadMore;

  /// No description provided for @bookmarksTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Marcadores'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes marcadores'**
  String get bookmarksEmpty;

  /// No description provided for @bookmarksEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Guarda artículos que te interesen para leerlos después.'**
  String get bookmarksEmptySubtitle;

  /// No description provided for @bookmarksLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get bookmarksLoadMore;

  /// No description provided for @bookmarksRemoved.
  ///
  /// In es, this message translates to:
  /// **'Eliminado de marcadores'**
  String get bookmarksRemoved;

  /// No description provided for @bookmarksUndo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get bookmarksUndo;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get profileTitle;

  /// No description provided for @profileUpdated.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado'**
  String get profileUpdated;

  /// No description provided for @profileMyTips.
  ///
  /// In es, this message translates to:
  /// **'Mis Tips'**
  String get profileMyTips;

  /// No description provided for @editProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Perfil'**
  String get editProfileTitle;

  /// No description provided for @editProfileCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get editProfileCamera;

  /// No description provided for @editProfileGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get editProfileGallery;

  /// No description provided for @editProfileSignOutTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get editProfileSignOutTitle;

  /// No description provided for @editProfileSignOutContent.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get editProfileSignOutContent;

  /// No description provided for @editProfileSignOutConfirm.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get editProfileSignOutConfirm;

  /// No description provided for @editProfileDeleteAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get editProfileDeleteAccountTitle;

  /// No description provided for @editProfileDeleteAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get editProfileDeleteAccountConfirm;

  /// No description provided for @editProfileCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get editProfileCancel;

  /// No description provided for @editProfileNameHint.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get editProfileNameHint;

  /// No description provided for @editProfileBioHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos sobre ti'**
  String get editProfileBioHint;

  /// No description provided for @editProfileSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get editProfileSaveChanges;

  /// No description provided for @articleMenuView.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get articleMenuView;

  /// No description provided for @articleMenuEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get articleMenuEdit;

  /// No description provided for @articleMenuDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get articleMenuDelete;

  /// No description provided for @articleDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar artículo'**
  String get articleDeleteTitle;

  /// No description provided for @articleDeleteContent.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar este artículo? Esta acción no se puede deshacer.'**
  String get articleDeleteContent;

  /// No description provided for @articleDeleteCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get articleDeleteCancel;

  /// No description provided for @searchRecentSearches.
  ///
  /// In es, this message translates to:
  /// **'Búsquedas recientes'**
  String get searchRecentSearches;

  /// No description provided for @searchStartSearching.
  ///
  /// In es, this message translates to:
  /// **'Empieza a buscar...'**
  String get searchStartSearching;

  /// No description provided for @searchNoArticles.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron artículos'**
  String get searchNoArticles;

  /// No description provided for @searchNoCategories.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron categorías'**
  String get searchNoCategories;

  /// No description provided for @searchCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get searchCancel;

  /// No description provided for @searchBarHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar artículos, categorías...'**
  String get searchBarHint;

  /// No description provided for @feedCardUnknownAuthor.
  ///
  /// In es, this message translates to:
  /// **'Autor desconocido'**
  String get feedCardUnknownAuthor;

  /// No description provided for @feedCardReadTime.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min de lectura'**
  String feedCardReadTime(int minutes);

  /// No description provided for @feedCardReadMore.
  ///
  /// In es, this message translates to:
  /// **'Saber más →'**
  String get feedCardReadMore;

  /// No description provided for @feedForYou.
  ///
  /// In es, this message translates to:
  /// **'Para ti'**
  String get feedForYou;

  /// No description provided for @articleSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardado'**
  String get articleSaved;

  /// No description provided for @articleSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get articleSave;

  /// No description provided for @coverVerticalLabel.
  ///
  /// In es, this message translates to:
  /// **'PORTADA VERTICAL\n(FEED)'**
  String get coverVerticalLabel;

  /// No description provided for @coverHorizontalLabel.
  ///
  /// In es, this message translates to:
  /// **'PORTADA HORIZONTAL\n(ARTÍCULO)'**
  String get coverHorizontalLabel;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Inténtalo de nuevo'**
  String get errorGeneric;

  /// No description provided for @errorNoConnection.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Inténtalo de nuevo'**
  String get errorNoConnection;

  /// No description provided for @discard.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get discard;

  /// No description provided for @bookmarksExploreAction.
  ///
  /// In es, this message translates to:
  /// **'Explorar artículos'**
  String get bookmarksExploreAction;

  /// No description provided for @bookmarksSectionLabel.
  ///
  /// In es, this message translates to:
  /// **'— GUARDADOS'**
  String get bookmarksSectionLabel;

  /// No description provided for @bookmarksSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Marcadores'**
  String get bookmarksSectionTitle;

  /// No description provided for @bookmarksSectionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Los artículos que has guardado para leer más tarde.'**
  String get bookmarksSectionSubtitle;

  /// No description provided for @bookmarksRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get bookmarksRetry;

  /// No description provided for @feedRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get feedRetry;

  /// No description provided for @exploreKaiaTitle.
  ///
  /// In es, this message translates to:
  /// **'Kaia, tu tortuga 🐢'**
  String get exploreKaiaTitle;

  /// No description provided for @exploreCategoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get exploreCategoriesTitle;

  /// No description provided for @exploreSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar artículos...'**
  String get exploreSearchHint;

  /// No description provided for @exploreStreakDays.
  ///
  /// In es, this message translates to:
  /// **'Día {days} de racha'**
  String exploreStreakDays(int days);

  /// No description provided for @exploreStreakMotivation.
  ///
  /// In es, this message translates to:
  /// **'🔥 ¡Sigue así!'**
  String get exploreStreakMotivation;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron resultados'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otras palabras clave o explora una categoría'**
  String get searchEmptySubtitle;

  /// No description provided for @searchEmptyExploreLabel.
  ///
  /// In es, this message translates to:
  /// **'Explorar categorías'**
  String get searchEmptyExploreLabel;

  /// No description provided for @articleDetailRelated.
  ///
  /// In es, this message translates to:
  /// **'Más como esto'**
  String get articleDetailRelated;

  /// No description provided for @categoryListSectionLabel.
  ///
  /// In es, this message translates to:
  /// **'— CATEGORÍA'**
  String get categoryListSectionLabel;

  /// No description provided for @searchTabArticles.
  ///
  /// In es, this message translates to:
  /// **'Artículos ({count})'**
  String searchTabArticles(int count);

  /// No description provided for @searchTabCategories.
  ///
  /// In es, this message translates to:
  /// **'Categorías ({count})'**
  String searchTabCategories(int count);

  /// No description provided for @searchFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get searchFilterAll;

  /// No description provided for @tortuFeedTitle.
  ///
  /// In es, this message translates to:
  /// **'Darle de comer a Tortu'**
  String get tortuFeedTitle;

  /// No description provided for @tortuFeedComeBackTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Vuelve mañana para seguir alimentando a Tortu 🐢'**
  String get tortuFeedComeBackTomorrow;

  /// No description provided for @tortuFeedSlideHint.
  ///
  /// In es, this message translates to:
  /// **'Desliza →'**
  String get tortuFeedSlideHint;

  /// No description provided for @tortuFeedCompleted.
  ///
  /// In es, this message translates to:
  /// **'¡Tip aprendido!'**
  String get tortuFeedCompleted;

  /// No description provided for @tortuFeedHappy.
  ///
  /// In es, this message translates to:
  /// **'Tortu está feliz +1%'**
  String get tortuFeedHappy;

  /// No description provided for @createArticlePublishedSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Artículo publicado con éxito!'**
  String get createArticlePublishedSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
