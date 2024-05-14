import 'package:intl/intl.dart';

String getTimeFromRide(DateTime datetime) {
  final today = DateTime.now();

  if(datetime.difference(today) < const Duration(days: 1)) {
    return '${datetime.difference(today).inHours}h';
  } else if(datetime.difference(today) < const Duration(days: 5)) {
    return '${datetime.difference(today).inDays}d';
  } else {
    return DateFormat.Md(datetime).toString();
  }
}