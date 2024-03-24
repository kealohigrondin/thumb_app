import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void handleAuthResponse(AuthResponse response) {
    print(response.user?.id);
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
            onSignInComplete: (response) => handleAuthResponse(response),
            onSignUpComplete: (response) => handleAuthResponse(response),
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
                key: 'LastName',
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
    ));
  }
}
