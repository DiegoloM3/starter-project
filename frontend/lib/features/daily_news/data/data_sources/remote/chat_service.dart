import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app_clean_architecture/core/config/api_config.dart';

class ChatService {
  final Dio _dio;

  ChatService(this._dio);

  Future<String> getChatResponse(String prompt) async {
    developer.log('Iniciando pipeline de IA para el prompt: "${prompt.substring(0, prompt.length > 30 ? 30 : prompt.length)}..."', name: 'SymmetryChat');
    
    // 1. Intento: Ollama Local (Máxima velocidad)
    try {
      developer.log('Intentando IA Local (Ollama)...', name: 'SymmetryChat');
      final localResponse = await _getOllamaResponse(ApiConfig.ollamaLocalUrl, prompt, isRemote: false);
      if (localResponse != null) {
        developer.log('IA Local respondió con éxito.', name: 'SymmetryChat');
        return localResponse;
      }
    } catch (e) {
      developer.log('IA local falló: $e', name: 'SymmetryChat');
    }

    // 2. Intento: Ollama Remoto (Cualquier usuario sin Ollama instalado)
    try {
      developer.log('Intentando IA Remota (Nexus Proxy)...', name: 'SymmetryChat');
      final remoteResponse = await _getOllamaResponse(ApiConfig.ollamaRemoteUrl, prompt, isRemote: true);
      if (remoteResponse != null) {
        developer.log('IA Remota respondió con éxito.', name: 'SymmetryChat');
        return remoteResponse;
      }
    } catch (e) {
      developer.log('IA remota falló: $e', name: 'SymmetryChat');
    }

    // 3. Intento: OpenAI (Último recurso)
    developer.log('Recurriendo a OpenAI (Failover final)...', name: 'SymmetryChat');
    return await _getOpenAIResponse(prompt);
  }

  Future<String?> _getOllamaResponse(String baseUrl, String prompt, {required bool isRemote}) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: isRemote ? 10 : 3),
        receiveTimeout: Duration(seconds: isRemote ? 30 : 15),
      ));

      developer.log('Petición a Ollama (${isRemote ? "Remoto" : "Local"}): $baseUrl', name: 'SymmetryChat');

      final response = await dio.post(
        'api/generate',
        data: {
          'model': 'qwen2.5:3b',
          'prompt': prompt,
          'stream': false,
        },
      );

      if (response.statusCode == 200) {
        return response.data['response'];
      }
    } catch (e) {
      developer.log('Error en Ollama ${isRemote ? "Remoto" : "Local"}: $e', name: 'SymmetryChat');
    }
    return null;
  }

  Future<String> _getOpenAIResponse(String prompt) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return "Servidores fuera de línea y sin API Key de respaldo.";
      }

      final openAiDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
      ));
      
      final response = await openAiDio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'Eres el Owl Assistant de Symmetry. Responde de forma técnica y elegante.'},
            {'role': 'user', 'content': prompt}
          ],
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      }
      return "Error en IA de respaldo (Status: ${response.statusCode})";
    } on DioException catch (e) {
      developer.log('Error de OpenAI: ${e.message}', name: 'SymmetryChat');
      if (e.response?.statusCode == 401) {
        return "Error de autenticación en OpenAI. Verifica la API Key.";
      }
      return "Sistemas fuera de línea. Por favor, comprueba tu conexión.";
    } catch (e) {
      return "Error inesperado: $e";
    }
  }
}
