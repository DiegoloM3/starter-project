extension DateTimeExtension on DateTime {
  String toIso8601Short() {
    String iso = toIso8601String();
    if (iso.contains('.')) {
      return iso.split('.').first + "Z";
    }
    if (!iso.endsWith('Z') && isUtc) {
      return iso + "Z";
    }

    return iso;
  }
}
