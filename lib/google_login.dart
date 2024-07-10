import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

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
  void Function(bool? signedIn) signedInCallback,
) async {
  try {
    signedInCallback(null);
    GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      throw const HttpException("Unable to sign in google account");
    }
    GoogleSignInAuthentication auth = await account.authentication;
    String? baseUrl = dotenv.env['API_URL'];
    if (baseUrl == null) {
      throw const FormatException("Missing env variable API_URL");
    }
    Uri uri = Uri.parse("$baseUrl/appLogin");
    var res = await http.post(uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(account.toJson(auth.accessToken)));
    if (res.statusCode != 200) {
      throw const HttpException("Unable to create or retrieve user");
    }
    signedInCallback(true);
  } catch (error) {
    if (kDebugMode) {
      print(error);
    }
    signedInCallback(false);
  }
}
