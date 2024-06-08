import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/center_progress_indicator.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/login_page_supabase.dart';

import 'navigation_container_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

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
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const NavigationContainerPage()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginPageSupabase()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CenterProgressIndicator();
  }
}
