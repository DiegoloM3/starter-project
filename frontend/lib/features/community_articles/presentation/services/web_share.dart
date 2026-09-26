enum WebShareStatus { shared, dismissed, unsupported }

Future<WebShareStatus> performWebShare({
  required String title,
  required String text,
  required String link,
}) async {
  return WebShareStatus.unsupported;
}
