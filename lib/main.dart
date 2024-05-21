// ignore_for_file: constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

Future<void> getLostData() async {
  final ImagePicker picker = ImagePicker();
  final LostDataResponse response = await picker.retrieveLostData();
  if (response.isEmpty) {
    return;
  }
  final List<XFile>? files = response.files;
  if (files != null) {
    _handleLostFiles(files);
  } else {
    print(response.exception?.message);
  }
}
void _handleLostFiles(List<XFile> files) {
  print('lost files recovered here');
}

void main() async {
  //getLostData(); //for image picker, sometimes it crashes the android app if it runs out of memory? Idk see readme
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
