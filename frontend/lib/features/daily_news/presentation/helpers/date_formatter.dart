import 'package:intl/intl.dart';

String formatArticleDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty) return '';
  try {
    final date = DateTime.parse(rawDate);
    return DateFormat.yMMMd().format(date);
  } on FormatException {
    return rawDate;
  }
}
