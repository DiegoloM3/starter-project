import 'dart:math';

class AssistantBrain {
  static const Map<String, List<String>> _messages = {
    'general': [
      'Hola, soy tu asistente Owl. ¡Qué gusto verte!',
      '¿Sabías que puedes publicar tus propias noticias desde el feed?',
      'Estoy analizando las tendencias del mercado por ti.',
      'Si tienes dudas sobre una noticia, toca mi burbuja para chatear.',
    ],
    'economy': [
      'Los mercados están volátiles hoy. ¿Quieres que analice el impacto energético?',
      'He detectado nuevas oportunidades en el sector empresarial.',
      'Economía en movimiento: las cadenas de suministro se están estabilizando.',
    ],
    'technology': [
      'La IA está transformando el periodismo. ¡Mira estos últimos avances!',
      'Nuevas pruebas de transporte autónomo detectadas. El futuro está cerca.',
      '¿Te interesa la tecnología? Tengo análisis profundos sobre hardware.',
    ],
    'society': [
      'Hay noticias importantes sobre el desarrollo urbano hoy.',
      'La aceptación ciudadana del transporte autónomo está creciendo.',
    ],
  };

  static String getRandomMessage([String? category]) {
    final seed = Random().nextInt(100);
    // 30% chance to ignore category for variety
    final effectiveCategory = (category != null && seed > 30) ? category.toLowerCase() : 'general';
    
    final list = _messages[effectiveCategory] ?? _messages['general']!;
    return list[Random().nextInt(list.length)];
  }
}
