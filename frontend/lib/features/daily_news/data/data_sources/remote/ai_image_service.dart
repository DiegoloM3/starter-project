class AIImageService {
  Future<String?> generateImageFromContent(String content) async {
    await Future.delayed(const Duration(seconds: 2));

    final String cleanContent = content.trim().toLowerCase();
    final int seed = cleanContent.hashCode;

    return "https://picsum.photos/seed/$seed/800/600";
  }
}
