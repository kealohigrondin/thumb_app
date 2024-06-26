import 'package:flutter/material.dart';
import 'package:thumb_app/main.dart';

final squareSmallButton = ButtonStyle(
    shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    padding: const MaterialStatePropertyAll(EdgeInsets.all(4)),
    iconSize: const MaterialStatePropertyAll(20),
    textStyle: MaterialStatePropertyAll(theme.textTheme.labelMedium));
