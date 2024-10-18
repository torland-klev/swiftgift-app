import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide IconAlignment;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:swiftgift_app/api_client.dart';
import 'package:swiftgift_app/auth/alternative_login.dart';
import 'package:swiftgift_app/auth/apple_login.dart';
import 'package:swiftgift_app/auth/google_login.dart';
import 'package:swiftgift_app/screens/home.dart';
import 'package:swiftgift_app/screens/user/update_user_name.dart';
import 'package:swiftgift_app/util.dart';

import 'auth/email_login.dart';
import 'data/user.dart';
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

logout(BuildContext context) async {
  await _googleSignIn.signOut();
  await apiClient.signOut();
  if (context.mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const GavelisteApp(),
      ),
    );
  }
}

class GavelisteApp extends StatelessWidget {
  const GavelisteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftGift',
      theme: themeData,
      home: const LandingPage(),
    );
  }
}

ApiClient apiClient = ApiClient();

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  final String title = 'SwiftGift';

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Future<User?> _isSignedInFuture = apiClient.isStoredTokenValid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              image: const DecorationImage(
                image: AssetImage('assets/gift-background.png'),
                fit: BoxFit.none,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          Center(
            child: FutureBuilder<User?>(
              future: _isSignedInFuture,
              builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasData && snapshot.data == null) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  if (kDebugMode) {
                    print(snapshot.error);
                  }
                  return Center(
                    child: SizedBox(
                      width: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Text(
                            'Something went wrong. Please try again later.',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  Future.delayed(Duration.zero, () {
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) {
                            if (snapshot.data?.firstName == null ||
                                snapshot.data!.firstName!.isEmpty ||
                                snapshot.data?.lastName == null ||
                                snapshot.data!.lastName!.isEmpty) {
                              return UpdateUserNameScreen(user: snapshot.data!);
                            } else {
                              return const HomeScreen();
                            }
                          },
                        ),
                      );
                    }
                  });

                  return const SizedBox.shrink();
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SignInButton(
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(width: 0.7),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        Buttons.google,
                        onPressed: () {
                          handleGoogleSignIn(_googleSignIn, apiClient,
                              (User? signedIn) {
                            setState(() {
                              _isSignedInFuture = Future.value(signedIn);
                            });
                          });
                        },
                      ),
                      const LogInWithEmailButton(),
                      if (Platform.isIOS &&
                          env("APPLE_LOGIN_ENABLED") == "true")
                        SizedBox(
                          width: 300,
                          child: SignInWithAppleButton(
                            height: 46,
                            iconAlignment: IconAlignment.left,
                            style: SignInWithAppleButtonStyle.whiteOutlined,
                            onPressed: () {
                              handleAppleSignIn(apiClient, (User? signedIn) {
                                setState(() {
                                  _isSignedInFuture = Future.value(signedIn);
                                });
                              });
                            },
                          ),
                        ),
                      if (curEnv == AppEnvironment.local) ...[
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            handleLocalSignIn(apiClient, (User? signedIn) {
                              setState(() {
                                _isSignedInFuture = Future.value(signedIn);
                              });
                            });
                          },
                          child: const Text('Local sign in'),
                        ),
                      ],
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
