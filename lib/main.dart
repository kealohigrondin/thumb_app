// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thumb_app/data/constants.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:thumb_app/pages/splash_page.dart';
import 'package:thumb_app/secrets.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: themeColor,
  ),
);


void main() async {
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: MaterialApp(theme: theme, home: const SplashPage()));
  }
}
