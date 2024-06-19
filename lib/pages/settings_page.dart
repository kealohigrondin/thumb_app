import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/login_page.dart';
import 'package:thumb_app/pages/profile_edit_page.dart';
import 'package:thumb_app/styles/button_styles.dart';

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
          SettingsRowItem(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileEditPage())),
              title: 'Edit Profile'),
          SettingsRowItem(onPressed: () => _signOut(), title: 'Sign out')
        ],
      ),
    );
  }
}

class SettingsRowItem extends StatelessWidget {
  const SettingsRowItem(
      {super.key, required this.onPressed, required this.title});

  final VoidCallback onPressed;
  final String title;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: TextButton(
          style: settingsRowButton,
          onPressed: onPressed,
          child: Align(
              alignment: Alignment.centerLeft,
              child:
                  Text(title, style: Theme.of(context).textTheme.bodyLarge))),
    );
  }
}
