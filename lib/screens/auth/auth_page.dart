import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/utils/toastification_helper.dart';

import '../../utils/home_loading.dart';
import '../../utils/theme_data.dart';
import 'create_account_page.dart';
import 'pp.dart';
import 'sign_in_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  void _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Get.offAll(() => const HomeLoading());
    } catch (e) {
      ToastificationHelper.showErrorToast(
        context,
        'An error occurred. Please try again. ($e)',
      );
    }
  }

  void _goToCreateAccount() {
    Get.to(() => const CreateAccountPage());
  }

  void _goToSignIn() {
    Get.to(() => const SignInPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Top and bottom
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message at the top
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Welcome',
                  style: baseTextStyle.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'To the ultimate scavenger hunt experience',
                  style: baseTextStyle.copyWith(
                    fontSize: 22,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            // Options at the bottom
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: baseTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                    children: [
                      TextSpan(
                        text: 'Privacy Policy',
                        style: baseTextStyle.copyWith(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Open Privacy Policy page
                            Navigator.of(context).push(MaterialPageRoute<void>(
                              fullscreenDialog: true,
                              builder: (BuildContext context) {
                                return Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Privacy Policy'),
                                    leading: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  body: SingleChildScrollView(
                                    padding: const EdgeInsets.all(16),
                                    child: MarkdownBody(
                                      data: privacyPolicy,
                                      styleSheet: MarkdownStyleSheet(
                                        p: baseTextStyle.copyWith(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ));
                          },
                      ),
                      const TextSpan(
                        text: ' and ',
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        style: baseTextStyle.copyWith(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Open Terms of Service page
                            Navigator.of(context).push(MaterialPageRoute<void>(
                              fullscreenDialog: true,
                              builder: (BuildContext context) {
                                return Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Terms of Service'),
                                    leading: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  body: SingleChildScrollView(
                                    padding: const EdgeInsets.all(16),
                                    child: MarkdownBody(
                                      data: tos,
                                      styleSheet: MarkdownStyleSheet(
                                        p: baseTextStyle.copyWith(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ));
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // "Create an Account" button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToCreateAccount,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Create an Account',
                      style: baseTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // "Continue as Guest" button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signInAnonymously,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue as Guest',
                      style: baseTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // "Sign In" link
                Center(
                  child: TextButton(
                    onPressed: _goToSignIn,
                    child: Text(
                      'Already have an account? Sign In',
                      style: baseTextStyle.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
