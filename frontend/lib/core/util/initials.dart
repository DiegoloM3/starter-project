/// Up to two upper-case letters for an avatar: "Jane Doe" → "JD", "Jane" → "J",
/// "María José García López" → "ML". Empty when [name] has no letters to take.
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  if (words.isEmpty) return '';
  final firstWords = words.length == 1 ? words : [words.first, words.last];
  return firstWords.map((word) => word[0].toUpperCase()).join();
}
