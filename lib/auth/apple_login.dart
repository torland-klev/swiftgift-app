import 'package:flutter/foundation.dart';
import 'package:gaveliste_app/util.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../api_client.dart';

Future<void> handleAppleSignIn(
  ApiClient client,
  void Function(bool? signedIn) signedInCallback,
) async {
  try {
    signedInCallback(null);
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: env("APPLE_CLIENT_ID"),
        redirectUri: Uri.parse(
          env("DEEP_LINK_URL"),
        ),
      ),
    );
    await client.loginApple(credential);
    signedInCallback(true);
  } catch (error) {
    if (kDebugMode) {
      print(error);
    }
    signedInCallback(false);
  }
}
