// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Symmetry News';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonSomethingWentWrong => 'Algo salio mal. Intentalo de nuevo.';

  @override
  String get newsNoArticlesFound => 'No se encontraron articulos';

  @override
  String get authUserNotFound => 'No se encontro una cuenta para ese correo.';

  @override
  String get authWrongPassword => 'La contrasena es incorrecta.';

  @override
  String get authInvalidEmail => 'Ingresa un correo valido.';

  @override
  String get authUserDisabled => 'Esta cuenta ha sido deshabilitada.';

  @override
  String get authEmailAlreadyInUse => 'Este correo ya esta en uso.';

  @override
  String get authWeakPassword => 'La contrasena es demasiado debil.';

  @override
  String get authOperationNotAllowed =>
      'Este metodo de inicio de sesion no esta habilitado.';

  @override
  String get authUserCancelled => 'El inicio de sesion fue cancelado.';

  @override
  String get authTokenExpired => 'Tu sesion expiro. Inicia sesion nuevamente.';

  @override
  String get authInvalidCredentials =>
      'Las credenciales proporcionadas no son validas.';

  @override
  String get authGeneric => 'La autenticacion fallo. Intentalo de nuevo.';

  @override
  String get authEnterDisplayName => 'Ingresa tu nombre.';

  @override
  String get authEnterEmail => 'Ingresa tu correo electronico.';

  @override
  String get authEnterPassword => 'Ingresa tu contrasena.';

  @override
  String get authPasswordsDoNotMatch => 'Las contrasenas no coinciden.';

  @override
  String get authSignIn => 'Iniciar sesion';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authSignInWithGoogle => 'Continuar con Google';

  @override
  String get serverGeneric => 'El servidor no pudo procesar la solicitud.';

  @override
  String get serverNotFound => 'No se encontro el recurso solicitado.';

  @override
  String get serverUnauthorized =>
      'No estas autorizado para realizar esta accion.';

  @override
  String get serverForbidden =>
      'No tienes permiso para acceder a este recurso.';

  @override
  String get serverBadRequest => 'La solicitud no es valida.';

  @override
  String get serverTooManyRequests =>
      'Demasiadas solicitudes. Intentalo mas tarde.';

  @override
  String get serverInternalError => 'Ocurrio un error interno del servidor.';

  @override
  String get serverBadGateway => 'El servicio ascendente no esta disponible.';

  @override
  String get serverServiceUnavailable =>
      'El servicio no esta disponible temporalmente.';

  @override
  String get serverProfileCreationFailed =>
      'No pudimos completar la creacion de tu perfil.';

  @override
  String get networkNoConnection =>
      'Sin conexion a internet. Revisa tu red e intentalo de nuevo.';

  @override
  String get networkTimeout =>
      'La solicitud tardo demasiado. Intentalo de nuevo.';

  @override
  String get networkGeneric => 'Ocurrio un error de red. Intentalo de nuevo.';
}
