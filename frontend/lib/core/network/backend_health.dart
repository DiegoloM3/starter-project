import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/core/config/api_config.dart';

/// En depuración, comprueba la salud de los backends.
Future<void> probeBackendHealth(GetIt locator) async {
  if (!kDebugMode) return;
  
  // 1. Probe FastAPI Backend
  try {
    final dio = locator<Dio>(instanceName: 'backend');
    final response = await dio.get<Map<String, dynamic>>('/health');
    developer.log('Symmetry API OK: ${response.data}', name: 'SymmetryHealth');
  } catch (e) {
    developer.log('Symmetry API DOWN: $e', name: 'SymmetryHealth');
  }

  // 2. Probe Ollama Local
  try {
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 2)));
    final response = await dio.get(ApiConfig.ollamaLocalUrl);
    if (response.statusCode == 200) {
      developer.log('Ollama Local OK', name: 'SymmetryHealth');
    }
  } catch (e) {
    developer.log('Ollama Local no detectado (esto es normal si no tienes Ollama instalado)', name: 'SymmetryHealth');
  }

  // 3. Probe Ollama Remoto
  try {
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));
    final response = await dio.get('${ApiConfig.ollamaRemoteUrl}/api/tags');
    if (response.statusCode == 200) {
      developer.log('Ollama Remoto OK (vía proxy)', name: 'SymmetryHealth');
    }
  } catch (e) {
    developer.log('Ollama Remoto DOWN (proxy en dominio ddns falló)', name: 'SymmetryHealth');
  }
}
