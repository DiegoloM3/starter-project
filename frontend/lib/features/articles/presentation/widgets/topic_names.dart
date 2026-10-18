import '../../domain/entities/article_topic.dart';

extension ArticleTopicName on ArticleTopic {
  String get displayName => switch (this) {
    ArticleTopic.technology => 'Tecnología',
    ArticleTopic.sports => 'Deportes',
    ArticleTopic.gaming => 'Videojuegos',
    ArticleTopic.politics => 'Política',
    ArticleTopic.economy => 'Economía',
    ArticleTopic.science => 'Ciencia',
    ArticleTopic.health => 'Salud',
    ArticleTopic.entertainment => 'Entretenimiento',
    ArticleTopic.culture => 'Cultura',
    ArticleTopic.world => 'Mundo',
  };
}
