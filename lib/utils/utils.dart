import 'package:flutter/material.dart';
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
    return DateFormat.Md().format(datetime);
  }
}

String formatDoubleToCurrency(double value) {
  return '\$${NumberFormat("#,##0.00", "en_US").format(value)}';
}

bool isPhoneNumber(String? phoneNo) {
  if (phoneNo == null) return false;
  final regExp = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
  return regExp.hasMatch(phoneNo);
}

/// Set of extension methods to easily display a snackbar
extension ShowSnackBar on BuildContext {
  /// Displays a basic snackbar
  void showSnackBar({
    required String message,
    required String functionName,
    Color backgroundColor = Colors.white,
  }) {
    debugPrint('$functionName -> $message');
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  /// Displays a red snackbar indicating error
  void showErrorSnackBar({required String message, required String functionName}) {
    showSnackBar(message: message, functionName: functionName, backgroundColor: Colors.red);
  }
}