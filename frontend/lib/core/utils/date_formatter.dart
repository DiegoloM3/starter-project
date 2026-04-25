import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }
}
