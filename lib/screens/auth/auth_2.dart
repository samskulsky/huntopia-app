import 'dart:developer';

import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:scavhuntapp/utils/home_loading.dart';
import 'package:scavhuntapp/utils/toastification_helper.dart';

import '../../utils/theme_data.dart';

class AuthPage2 extends StatefulWidget {
  const AuthPage2({super.key});

  @override
  State<AuthPage2> createState() => _AuthPage2State();
}

String phoneNumber = '';

class _AuthPage2State extends State<AuthPage2> {
  @override
  Widget build(BuildContext context) {
    return FirebasePhoneAuthHandler(
      phoneNumber: phoneNumber,
      onCodeSent: () => log('Code sent'),
      onLoginSuccess: (userCredential, autoVerified) {
        final message = autoVerified
            ? 'OTP was fetched automatically!'
            : 'OTP was verified manually!';

        ToastificationHelper.showSuccessToast(
          context,
          'Phone number verified!',
        );

        log('Login success UID: ${userCredential.user!.uid}');
        log(message);

        Get.offAll(() => const HomeLoading());
      },
      onLoginFailed: (authException, _) {
        log(authException.message ?? 'Login failed');

        switch (authException.code) {
          case 'invalid-phone-number':
            ToastificationHelper.showErrorToast(
              context,
              'Invalid phone number, please try again',
            );
            break;
          case 'invalid-verification-code':
            ToastificationHelper.showErrorToast(
              context,
              'The code you entered is invalid',
            );
            break;
          default:
            ToastificationHelper.showErrorToast(
              context,
              'An error occurred, please try again',
            );
        }
      },
      onError: (_, stackTrace) {
        log(stackTrace.toString());
        ToastificationHelper.showErrorToast(
          context,
          'An error occurred, please try again',
        );
      },
      builder: (context, controller) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeft),
              onPressed: () => Get.back(),
            ),
            actions: [
              if (controller.codeSent)
                TextButton(
                  onPressed: controller.isOtpExpired
                      ? () async {
                          log('Resend OTP');
                          await controller.sendOTP();
                        }
                      : null,
                  child: Text(
                    controller.isOtpExpired
                        ? 'Resend'
                        : '${controller.otpExpirationTimeLeft.inSeconds}s',
                    style: baseTextStyle.copyWith(
                        color: Colors.blue, fontSize: 18),
                  ),
                ),
              const SizedBox(width: 5),
            ],
            title: const Text('Verify Phone Number'),
          ),
          body: controller.isSendingCode
              ? Center(
                  child: Text(
                    'Sending Verification Code...',
                    style: baseTextStyle.copyWith(fontSize: 25),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const FaIcon(FontAwesomeIcons.phone),
                      title: Text(
                        "We've sent a text with a verification code to $phoneNumber",
                        style: baseTextStyle.copyWith(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter Code',
                      style: baseTextStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Pinput(
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      showCursor: true,
                      length: 6,
                      defaultPinTheme: PinTheme(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).dividerTheme.color!),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        textStyle: baseTextStyle.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onCompleted: (pin) async {
                        await controller.verifyOtp(pin);
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}
