import 'dart:io';
import 'package:flutter/foundation.dart';

/// Base URL del API REST del prototipo (FastAPI). Sobrescribe con
/// `--dart-define=API_BASE_URL=http://10.0.2.2:8000/` en emulador Android.
class ApiConfig {
  ApiConfig._();

  static const String backendBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://uncovernews.ddns.net/api/v1/',
  );

  static String get ollamaLocalUrl {
    const fromEnv = String.fromEnvironment('OLLAMA_LOCAL_URL');
    if (fromEnv.isNotEmpty) return fromEnv.endsWith('/') ? fromEnv : '$fromEnv/';

    if (kIsWeb) return 'http://localhost:11434/';
    
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:11434/';
    } catch (_) {}
    
    return 'http://localhost:11434/';
  }

  static String get ollamaRemoteUrl => '$backendBaseUrl/ollama/';
}
