import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_button/sign_in_button.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GavelisteApp());
}

const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/userinfo.email',
  'https://www.googleapis.com/auth/userinfo.profile',
];

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: scopes);

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

Future<void> _handleSignIn(
    void Function(bool? signedIn) signedInCallback) async {
  try {
    signedInCallback(null);
    GoogleSignInAccount? account = await _googleSignIn.signIn();
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
    print(error);
    signedInCallback(false);
  }
}

class GavelisteApp extends StatelessWidget {
  const GavelisteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaveliste',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gaveliste'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool? _signedIn = false;

  @override
  initState() {
    super.initState();

    _googleSignIn.signOut().then((GoogleSignInAccount? account) {
      setState(() {
        _signedIn = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              _signedIn == null
                  ? const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    )
                  : (_signedIn == true
                      ? const Text('Welcome!')
                      : SignInButton(
                          Buttons.google,
                          onPressed: () {
                            _handleSignIn((bool? signedIn) {
                              setState(() {
                                _signedIn = signedIn;
                              });
                            });
                          },
                        ))
            ])));
  }
}
