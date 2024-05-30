// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
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

  var _loading = true;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    try {
      final profileResult = await supabase.from('profile').select().eq('auth_id', user.id).single();
      _firstNameController.text = (profileResult['first_name'] ?? '') as String;
      _lastNameController.text = (profileResult['last_name'] ?? '') as String;
      _emailController.text = (profileResult['email'] ?? '') as String;
      _phoneNumberController.text = (profileResult['phone_number'] ?? '') as String;
    } catch (error) {
      ShowErrorSnackBar(context, 'Unexpected error occurred.');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });

    final updates = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone_number': _phoneNumberController.text.trim(),
    };

    try {
      await supabase.auth.updateUser(UserAttributes(
        data: updates,
      ));
      await supabase.from('profile').upsert(updates);
      ShowSuccessSnackBar(context, 'Profile saved!');
    } catch (error) {
      ShowErrorSnackBar(context, 'Unexpected error occurred.');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      ShowErrorSnackBar(context, 'Unexpected error occurred.');
    } finally {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPageSupabase()));
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
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    width: 100,
                    height: 100,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
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
                  onPressed: _loading ? null : _updateProfile,
                  child: Text(_loading ? 'Saving...' : 'Update'),
                ),
                const SizedBox(height: 18),
                TextButton(onPressed: _signOut, child: const Text('Sign Out')),
              ],
            ),
    );
  }
}
