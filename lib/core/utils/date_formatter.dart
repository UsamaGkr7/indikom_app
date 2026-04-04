import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static DateFormat _timeFormat = DateFormat('HH:mm');
  static DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy • HH:mm');
  static DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    return hours > 0 ? '$hours:$minutes' : '0:$minutes';
  }
}
