import 'package:flutter/material.dart';
import 'package:thumb_app/data/constants.dart';
import 'package:thumb_app/screens/login_page.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: themeColor,
  ),
);
const SUPABASE_URL='https://dddaaocibmlxbnomadhx.supabase.co';
const SUPABASE_ANON_KEY='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkZGFhb2NpYm1seGJub21hZGh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTExNjA4ODYsImV4cCI6MjAyNjczNjg4Nn0.UePhOVWGDyArRNcFu31tEQe6VfT7qtrctXfu4UovFoU';
void main() async {
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: theme, home: const LoginPage());
  }
}
