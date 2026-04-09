import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  bool get isValidEmail => RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(this);

  bool get isStrongPassword =>
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
          .hasMatch(this);

  String toFormattedDate({required BuildContext context}) {
    try {
      final currentLocale = Localizations.localeOf(context).toString();
      final dateTime = DateTime.parse(this);

      return DateFormat.yMd(currentLocale.toString()).format(dateTime);
    } catch (e) {
      return this; // Return the original string if parsing fails
    }
  }
}
