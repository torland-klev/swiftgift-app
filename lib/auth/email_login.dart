import 'package:flutter/material.dart';

import '../screens/user/login_with_email.dart';

class LogInWithEmailButton extends StatelessWidget {
  const LogInWithEmailButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginWithEmailScreen()),
        );
      },
      icon: const Icon(
        Icons.email,
        color: Colors.black,
      ),
      label: const Padding(
          padding: EdgeInsets.only(left: 12, right: 44),
          child: Text(
            'Sign in with Email',
            style: TextStyle(
              color: Colors.black,
            ),
          )),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
