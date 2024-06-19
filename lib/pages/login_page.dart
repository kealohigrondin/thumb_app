import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:thumb_app/components/shared/snackbars_custom.dart';
import 'package:thumb_app/main.dart';
import 'package:thumb_app/pages/navigation_container_page.dart';
import 'package:thumb_app/utils/utils.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void handleAuthResponse(AuthResponse response, BuildContext ctx) async {
    if (response.user == null) {
      ShowErrorSnackBar(ctx, 'No user in response. Try again later.');
      return;
    }
    try {
      final profileResult = await supabase
          .from('profile')
          .select('auth_id')
          .eq('auth_id', response.user!.id);
      if (profileResult.isEmpty) {
        await supabase.from('profile').upsert({
          'auth_id': response.user!.id,
          'email': response.user?.userMetadata?['email'],
          'first_name': response.user?.userMetadata?['first_name'],
          'last_name': response.user?.userMetadata?['last_name'],
          'phone_number': response.user?.userMetadata?['phone_number'],
        });
      }
      if (ctx.mounted) {
        Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(
                builder: (context) => const NavigationContainerPage()));
      }
    } catch (error) {
      //TODO: add some kind of logging
      if (ctx.mounted) {
        ShowErrorSnackBar(ctx, 'Error saving profile data');
      }
    }
  }

  void handleOAuthResponse(Session session) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: SupaEmailAuth(
              onSignInComplete: (response) =>
                  handleAuthResponse(response, context),
              onSignUpComplete: (response) =>
                  handleAuthResponse(response, context),
              metadataFields: [
                MetaDataField(
                  prefixIcon: const Icon(Icons.person),
                  label: 'First Name',
                  key: 'first_name',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
                MetaDataField(
                  prefixIcon: const Icon(Icons.person),
                  label: 'Last Name',
                  key: 'last_name',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),
                MetaDataField(
                  prefixIcon: const Icon(Icons.phone),
                  label: 'Phone Number',
                  key: 'phone_number',
                  validator: (val) {
                    if (val == null || val.isEmpty || !isPhoneNumber(val)) {
                      return 'Please enter valid phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   child: SupaSocialsAuth(
          //     socialProviders: const [OAuthProvider.google],
          //     colored: true,
          //     onSuccess: (Session response) => handleOAuthResponse(response),
          //     onError: (error) {},
          //   ),
          // )
        ],
      ),
    );
  }
}
