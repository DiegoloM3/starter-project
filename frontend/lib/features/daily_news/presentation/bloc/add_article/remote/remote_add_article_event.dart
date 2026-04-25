abstract class RemoteAddArticleEvent {
  const RemoteAddArticleEvent();
}

class GenerateAIImageEvent extends RemoteAddArticleEvent {
  final String content;
  const GenerateAIImageEvent(this.content);
}
