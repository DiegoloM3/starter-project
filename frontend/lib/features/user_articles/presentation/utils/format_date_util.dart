

  String formatDateUtil(dynamic date) {
    final parsedDate = date is DateTime ? date : DateTime.tryParse(date.toString());
    if (parsedDate == null) return date.toString();

    return '${parsedDate.toUtc().toIso8601String().split('.').first}Z';
  }