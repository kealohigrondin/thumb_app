// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

void ShowErrorSnackBar(BuildContext context, String text) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorSnackBar(text),
    );
  }
}

void ShowSuccessSnackBar(BuildContext context, String text) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SuccessSnackBar(text),
    );
  }
}

SnackBar ErrorSnackBar(String text) {
  return SnackBar(
    content: Text(text),
    backgroundColor: Colors.red,
  );
}

SnackBar SuccessSnackBar(String text) {
  return SnackBar(
    content: Text(text),
    backgroundColor: Colors.green,
  );
}
