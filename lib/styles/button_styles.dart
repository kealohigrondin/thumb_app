import 'package:flutter/material.dart';
import 'package:thumb_app/main.dart';

final squareSmallButton = ButtonStyle(
    shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    padding: const MaterialStatePropertyAll(EdgeInsets.all(0)),
    iconSize: const MaterialStatePropertyAll(20),
    textStyle: MaterialStatePropertyAll(theme.textTheme.labelSmall));
