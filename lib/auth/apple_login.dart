import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../api_client.dart';
import '../data/user.dart';

Future<void> handleAppleSignIn(
  ApiClient client,
  void Function(User? signedIn) signedInCallback,
) async {
  try {
    signedInCallback(null);
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    signedInCallback(await client.loginApple(credential));
  } catch (error) {
    if (kDebugMode) {
      print(error);
    }
    signedInCallback(null);
  }
}
