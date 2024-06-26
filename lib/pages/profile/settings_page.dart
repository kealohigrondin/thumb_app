import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/login_page.dart';
import 'package:thumb_app/pages/profile/profile_edit_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      if (mounted) {
        ShowErrorSnackBar(
            context, 'Unexpected error occurred.', error.toString());
      }
    } finally {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileEditPage())),
              title: const Text('Edit Profile')),
          ListTile(onTap: () => _signOut(), title: const Text('Sign out')),
          ListTile(
              onTap: () => debugPrint('toggle dark mode'),
              title: const Text('Toggle Dark Mode'))
        ],
      ),
    );
  }
}
