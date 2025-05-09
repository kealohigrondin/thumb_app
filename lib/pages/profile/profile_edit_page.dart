// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:thumb_app/components/shared/center_progress_indicator.dart';
import 'package:thumb_app/components/shared/profile_photo.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/data/types/profile.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/services/supabase_service.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late Future<Profile> _profile;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  /// Called once a user id is received within `onAuthenticated()`

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    try {
      await SupabaseService.updateProfile(
          _firstNameController.text,
          _lastNameController.text,
          _emailController.text,
          _phoneNumberController.text,
          _bioController.text);
      ShowSuccessSnackBar(context, 'Profile saved! (Pull to refresh)');
      Navigator.of(context).pop();
    } catch (err) {
      if (context.mounted) {
        ShowErrorSnackBar(context, 'Unexpected error occurred.',
            'profilePage.updateProfile(): ${err.toString()}');
      }
    } finally {
      //close keyboard and unfocus all text fields
      if (FocusManager.instance.primaryFocus != null) {
        FocusManager.instance.primaryFocus!.unfocus();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _profile = SupabaseService.getProfile(supabase.auth.currentUser!.id);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: FutureBuilder(
          future: _profile,
          builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else if (snapshot.hasData) {
              _firstNameController.text = snapshot.data!.firstName;
              _lastNameController.text = snapshot.data!.lastName;
              _emailController.text = snapshot.data!.email;
              _phoneNumberController.text = snapshot.data!.phoneNumber;
              _bioController.text = snapshot.data!.bio;

              return ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                children: [
                  GestureDetector(
                    onTap: () => debugPrint('edit profile photo tapped'),
                    child: ProfilePhoto(
                        initials:
                            '${snapshot.data!.firstName[0]}${snapshot.data!.lastName[0]}',
                        authId: snapshot.data!.authId),
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
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _bioController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    minLines: 3,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Update'),
                  )
                ],
              );
            } else {
              return const CenterProgressIndicator();
            }
          }),
    );
  }
}
