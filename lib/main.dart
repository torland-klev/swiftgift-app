import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gaveliste_app/api_client.dart';
import 'package:gaveliste_app/auth/alternative_login.dart';
import 'package:gaveliste_app/auth/google_login.dart';
import 'package:gaveliste_app/screens/home.dart';
import 'package:gaveliste_app/util.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'firebase_options.dart';

AppEnvironment curEnv = AppEnvironment.production;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeEnv();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GavelisteApp());
}

Future<void> initializeEnv() async {
  await dotenv.load(fileName: ".env");
  curEnv = appEnv();
}

GoogleSignIn _initialGoogleSignIn() {
  if (kIsWeb) {
    return GoogleSignIn(
        scopes: scopes, clientId: dotenv.env['SERVER_CLIENT_ID']);
  } else {
    return GoogleSignIn(scopes: scopes);
  }
}

GoogleSignIn _googleSignIn = _initialGoogleSignIn();

ThemeData themeData = ThemeData(
  cardColor: const Color.fromRGBO(120, 170, 255, 100),
  colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      surface: const Color.fromRGBO(74, 122, 247, 100)),
  useMaterial3: true,
);

class GavelisteApp extends StatelessWidget {
  const GavelisteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftGift',
      theme: themeData,
      home: const LandingPage(title: 'SwiftGift'),
    );
  }
}

ApiClient apiClient = ApiClient();

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.title});
  final String title;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool? _signedIn = false;

  @override
  void dispose() {
    if (kDebugMode) {
      _googleSignIn.signOut();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_signedIn == true) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      });
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              image: const DecorationImage(
                image: AssetImage('assets/gift-background.png'),
                fit: BoxFit.none,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _signedIn == false
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                              scale: 1.35,
                              child: SignInButton(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 15, 0, 15),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                Buttons.google,
                                onPressed: () {
                                  handleSignIn(_googleSignIn, apiClient,
                                      (bool? signedIn) {
                                    setState(() {
                                      _signedIn = signedIn;
                                    });
                                  });
                                },
                              )),
                          if (curEnv == AppEnvironment.local) ...[
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                handleLocalSignIn(apiClient, (bool? signedIn) {
                                  setState(() {
                                    _signedIn = signedIn;
                                  });
                                });
                              },
                              child: const Text('Local sign in'),
                            ),
                          ],
                        ],
                      )
                    : const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
