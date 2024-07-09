import 'package:flutter/material.dart';
import 'package:thumb_app/pages/profile/profile_page.dart';

class VisitingProfilePage extends StatelessWidget {
  const VisitingProfilePage({super.key, this.authId});

  final String? authId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: ProfilePage(visiting: true, authId: authId));
  }
}
