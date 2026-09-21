import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateParser {
  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String pretty(DateTime? date) {
    if (date == null) return '';
    return DateFormat('d MMM yyyy').format(date);
  }

  static String prettyDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('d MMM yyyy, h:mm a').format(date);
  }
}
