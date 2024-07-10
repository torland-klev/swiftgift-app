import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_client.dart';

extension Jsonify on GoogleSignInAccount {
  Map<String, dynamic> toJson(String? accessToken) {
    return {
      "displayName": displayName,
      "email": email,
      "id": id,
      "photoUrl": photoUrl,
      "serverAuthCode": serverAuthCode,
      "accessToken": accessToken
    };
  }
}

const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/userinfo.email',
  'https://www.googleapis.com/auth/userinfo.profile',
];

Future<void> handleSignIn(
  GoogleSignIn googleSignIn,
  ApiClient client,
  void Function(bool? signedIn) signedInCallback,
) async {
  try {
    signedInCallback(null);
    GoogleSignInAccount? account = await googleSignIn.signIn();
    await client.login(account);
    signedInCallback(true);
  } catch (error) {
    if (kDebugMode) {
      print(error);
    }
    signedInCallback(false);
  }
}
