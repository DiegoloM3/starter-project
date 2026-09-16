// Floor marks type converters as experimental although they have been stable since 1.0.
// ignore_for_file: experimental_member_use

import 'package:floor/floor.dart';

/// Stores [DateTime] as UTC milliseconds since the epoch.
class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue, isUtc: true);
  }

  @override
  int encode(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}
