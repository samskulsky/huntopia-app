import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/utils/toastification_helper.dart';

import '../../utils/home_loading.dart';
import '../../utils/theme_data.dart';
import 'create_account_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      ToastificationHelper.showSuccessToast(context, 'Signed in successfully!');
      Get.offAll(() => const HomeLoading());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ToastificationHelper.showErrorToast(
          context,
          'No user found with this email. Please create an account.',
        );
      } else if (e.code == 'wrong-password') {
        ToastificationHelper.showErrorToast(
          context,
          'Incorrect password. Please try again.',
        );
      } else {
        ToastificationHelper.showErrorToast(
          context,
          'An error occurred. Please try again. ($e)',
        );
      }
    } catch (e) {
      ToastificationHelper.showErrorToast(
        context,
        'An error occurred. Please try again. ($e)',
      );
    }
  }

  void _goToCreateAccount() {
    Get.off(() => const CreateAccountPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            // Email TextField
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: baseTextStyle.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Password TextField
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
              style: baseTextStyle.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 32),
            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: baseTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // "Create Account" link
            TextButton(
              onPressed: _goToCreateAccount,
              child: Text(
                'Don\'t have an account? Create one',
                style: baseTextStyle.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
