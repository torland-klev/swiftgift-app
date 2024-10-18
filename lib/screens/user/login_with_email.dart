import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:swiftgift_app/main.dart';

class LoginWithEmailScreen extends StatefulWidget {
  const LoginWithEmailScreen({super.key});
  @override
  State<LoginWithEmailScreen> createState() => _LoginWithEmailScreenState();
}

class _LoginWithEmailScreenState extends State<LoginWithEmailScreen> {
  final _emailFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _emailFocusNode = FocusNode();

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailPage();
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pageController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _loader() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _emailPage() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _otpPage() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleEmailSubmitted(String email) {
    if (email.isNotEmpty) {
      _loader();
      apiClient.loginEmail(email).then((statusCode) {
        if (statusCode == 200) {
          _otpPage();
        } else {
          _emailPage();
        }
      });
    }
  }

  void _handleOtpEntered(String otp) {
    _loader();
    apiClient.loginOtp(_emailController.text, otp).then((statusCode) {
      if (statusCode == 200 && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LandingPage(),
          ),
        );
      } else {
        _otpPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildLoaderPage(),
                _buildEmailPage(),
                _buildOtpPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaderPage() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmailPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 16),
      child: Form(
        key: _emailFormKey,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('What is your email?',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 40),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: _handleEmailSubmitted,
              onChanged: (value) {
                if (_emailFormKey.currentState?.validate() == false) {
                  setState(() {});
                }
              },
              decoration: const InputDecoration(
                errorStyle: TextStyle(height: 0),
                helperText: ' ',
              ),
              style: const TextStyle(fontSize: 22),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                return null;
              },
            )
          ]),
        ),
      ),
    );
  }

  Widget _buildOtpPage() {
    return Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 16),
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Enter one-time code sent to your email',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 40),
          OtpTextField(
              numberOfFields: 6,
              borderColor: const Color(0xFF512DA8),
              showFieldAsBox: true,
              onSubmit: _handleOtpEntered),
        ])));
  }
}
