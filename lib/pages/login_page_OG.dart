import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:thumb_app/pages/bottom_nav_pages/account_page.dart';
import 'package:thumb_app/pages/navigation_container_page.dart';

class LoginPageOG extends StatelessWidget {
  const LoginPageOG({super.key});

  void handleAuthResponse(AuthResponse response, BuildContext ctx) {
    Navigator.push(
        ctx, MaterialPageRoute(builder: (context) => const NavigationContainerPage()));
  }

  void handleOAuthResponse(Session session) {
    print(session.accessToken);
  }

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
                  key: 'firstName',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter something';
                    }
                    return null;
                  },
                ),
                MetaDataField(
                  prefixIcon: const Icon(Icons.person),
                  label: 'Last Name',
                  key: 'lastName',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter something';
                    }
                    return null;
                  },
                ),
                MetaDataField(
                  prefixIcon: const Icon(Icons.phone),
                  label: 'Phone Number',
                  key: 'phoneNumber',
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter something';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: SupaSocialsAuth(
              socialProviders: const [OAuthProvider.google],
              colored: true,
              onSuccess: (Session response) => handleOAuthResponse(response),
              onError: (error) {},
            ),
          )
        ],
      ),
    );
  }
}
