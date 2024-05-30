// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thumb_app/components/shared/center_progress_indicator.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/login_page_supabase.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();

  /// Called once a user id is received within `onAuthenticated()`
  Future<Profile> _getProfile() async {
    final user = supabase.auth.currentUser;
    try {
      final result = await supabase
          .from('profile')
          .select()
          .eq('auth_id', user!.id)
          .single();
      return Profile.fromJson(result);
    } catch (error) {
      ShowErrorSnackBar(
          context, 'Unexpected error occurred.', error.toString());
      return Profile();
    }
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    try {
      final authId = supabase.auth.currentUser!.id;
      final updates = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
      };
      await supabase.auth.updateUser(UserAttributes(
        data: updates,
      ));
      final profileUpdates = {'auth_id': authId, ...updates};
      await supabase
          .from('profile')
          .upsert(profileUpdates).eq('auth_id', authId);
      ShowSuccessSnackBar(context, 'Profile saved!');
    } catch (error) {
      ShowErrorSnackBar(
          context, 'Unexpected error occurred.', error.toString());
    }
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      ShowErrorSnackBar(
          context, 'Unexpected error occurred.', error.toString());
    } finally {
      if (mounted) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPageSupabase()));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getProfile(),
        builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            _firstNameController.text = snapshot.data!.firstName;
            _lastNameController.text = snapshot.data!.lastName;
            _emailController.text = snapshot.data!.email;
            _phoneNumberController.text = snapshot.data!.phoneNumber;

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    width: 100,
                    height: 100,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset('assets/images/user.png'),
                  ),
                ),
                TextFormField(
                  controller: _firstNameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _lastNameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  // TODO: Add form validation
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Update'),
                ),
                const SizedBox(height: 18),
                TextButton(onPressed: _signOut, child: const Text('Sign Out')),
              ],
            );
          } else {
            return const CenterProgressIndicator();
          }
        });
  }
}
