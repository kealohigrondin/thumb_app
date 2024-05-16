import 'package:intl/intl.dart';

String getTimeFromRide(DateTime datetime) {
  final today = DateTime.now();
  final difference = today.difference(datetime);

  if (difference < const Duration(minutes: 0)) {
    return datetime.toIso8601String();
  } else if (difference < const Duration(days: 1)) {
    return '${difference.inHours}h';
  } else if (difference < const Duration(days: 5)) {
    return '${difference.inDays}d';
  } else {
    return DateFormat.Md(datetime).toString();
  }
}
