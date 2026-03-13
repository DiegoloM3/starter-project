import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the app.
/// Values are loaded from .env file using flutter_dotenv.
///
/// Usage:
/// 1. Copy .env.example to .env
/// 2. Fill in your values in .env
/// 3. The .env file is automatically loaded in main.dart
class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  // ============================================
  // ENVIRONMENT
  // ============================================

  /// Current environment (development, staging, production)
  static String get environment => dotenv.env['ENV'] ?? 'development';

  /// Whether the app is running in development mode
  static bool get isDevelopment => environment == 'development';

  /// Whether the app is running in production mode
  static bool get isProduction => environment == 'production';

  // ============================================
  // NEWS API CONFIGURATION
  // ============================================

  /// NewsAPI.org API key for fetching news articles.
  /// Get this from https://newsapi.org/register
  static String get newsApiKey => dotenv.env['NEWS_API_KEY'] ?? '';

  // ============================================
  // CLOUDINARY CONFIGURATION
  // ============================================

  /// Cloudinary cloud name for image uploads.
  /// Get this from your Cloudinary Dashboard.
  static String get cloudinaryCloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  /// Cloudinary upload preset for unsigned uploads.
  /// Create this in Cloudinary Settings → Upload → Upload Presets.
  static String get cloudinaryUploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  // ============================================
  // FIREBASE CONFIGURATION (Optional overrides)
  // ============================================
  // Note: Firebase configuration is primarily handled by firebase_options.dart
  // generated via `flutterfire configure`. These are optional overrides.

  /// Firebase API Key (optional override)
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  /// Firebase Project ID (optional override)
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  /// Firebase Auth Domain (optional override)
  static String get firebaseAuthDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';

  /// Firebase Messaging Sender ID (optional override)
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  /// Firebase App ID (optional override)
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  // ============================================
  // VALIDATION
  // ============================================

  /// Validates that all required environment variables are set.
  /// Call this at app startup to catch configuration errors early.
  ///
  /// Throws [Exception] if required variables are missing.
  static void validate() {
    final missingVars = <String>[];

    if (newsApiKey.isEmpty) {
      missingVars.add('NEWS_API_KEY');
    }

    if (cloudinaryCloudName.isEmpty) {
      missingVars.add('CLOUDINARY_CLOUD_NAME');
    }

    if (missingVars.isNotEmpty) {
      throw Exception(
        'Missing required environment variables: ${missingVars.join(', ')}\n'
        'Make sure you have a .env file with all required values.\n'
        'See .env.example for reference.',
      );
    }
  }

  /// Returns a map of all environment variables for debugging.
  /// Only use in development mode.
  static Map<String, String> toDebugMap() {
    if (!isDevelopment) {
      return {'error': 'Debug map only available in development mode'};
    }

    return {
      'ENV': environment,
      'NEWS_API_KEY': newsApiKey.isNotEmpty
          ? '${newsApiKey.substring(0, 3)}***'
          : 'NOT SET',
      'CLOUDINARY_CLOUD_NAME': cloudinaryCloudName.isNotEmpty
          ? '${cloudinaryCloudName.substring(0, 3)}***'
          : 'NOT SET',
      'CLOUDINARY_UPLOAD_PRESET': cloudinaryUploadPreset,
      'FIREBASE_PROJECT_ID': firebaseProjectId.isNotEmpty
          ? '${firebaseProjectId.substring(0, 3)}***'
          : 'NOT SET (using firebase_options.dart)',
    };
  }
}
