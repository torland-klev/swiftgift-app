import 'package:flutter/material.dart';

class LoginWithEmailScreen extends StatefulWidget {
  const LoginWithEmailScreen({super.key});
  @override
  State<LoginWithEmailScreen> createState() => _LoginWithEmailScreenState();
}

class _LoginWithEmailScreenState extends State<LoginWithEmailScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();

  final _emailFocusNode = FocusNode();

  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _pageController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _goToPage(int pageIndex) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPageIndex = pageIndex;
      });
    }
  }

  void _submitForm() async {}

  void _nextPage() {
    if (_currentPageIndex >= 4) {
      _submitForm();
    } else {
      if (_emailFormKey.currentState?.validate() != false) {
        FocusScope.of(context).unfocus();
        _goToPage(_currentPageIndex + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPageIndex = page;
                });
              },
              children: [
                _buildEmailPage(),
                _buildOtpPage(),
              ],
            ),
          ),
        ],
      ),
    );
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
              maxLength: 50,
              controller: _emailController,
              focusNode: _emailFocusNode,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                _nextPage();
              },
              onChanged: (value) {
                if (_emailFormKey.currentState?.validate() == false) {
                  setState(() {});
                }
              },
              decoration: const InputDecoration(
                errorStyle: TextStyle(height: 0),
                helperText: ' ',
              ),
              style: const TextStyle(fontSize: 30),
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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 16),
      child: Form(
        key: _otpFormKey,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('What is your email?',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 40),
            TextFormField(
              maxLength: 50,
              controller: _otpController,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                _nextPage();
              },
              onChanged: (value) {
                if (_otpFormKey.currentState?.validate() == false) {
                  setState(() {});
                }
              },
              decoration: const InputDecoration(
                errorStyle: TextStyle(height: 0),
                helperText: ' ',
              ),
              style: const TextStyle(fontSize: 30),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter OTP';
                }
                return null;
              },
            )
          ]),
        ),
      ),
    );
  }
}
