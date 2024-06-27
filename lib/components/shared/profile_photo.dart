import 'package:flutter/material.dart';

class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto(
      {super.key,
      required this.initials,
      required this.authId,
      this.radius = 45});

  final String initials;
  final String authId;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: radius,
        child: Text(initials, style: TextStyle(fontSize: radius * 0.8)));
  }
}
