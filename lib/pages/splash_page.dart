import 'package:flutter/material.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/account_page.dart';
import 'package:thumb_app/pages/login_page.dart';
import 'package:thumb_app/pages/login_page_OG.dart';

import 'navigation_container_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  //_SplashPageState createState() => _SplashPageState();
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    final session = supabase.auth.currentSession;
    if (session != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const AccountPage()));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoginPageOG()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
