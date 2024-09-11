import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:scavhuntapp/screens/auth/auth_2.dart';
import 'package:scavhuntapp/screens/auth/pp.dart';
import 'package:toastification/toastification.dart';

import '../../utils/theme_data.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

bool valid = false;

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    // Do not show keyboard on page load
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Welcome',
                  style: baseTextStyle.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'To continue, please enter your phone number.',
                  style: baseTextStyle.copyWith(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 16),
                IntlPhoneField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(FontAwesomeIcons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  style: baseTextStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                  pickerDialogStyle: PickerDialogStyle(
                    searchFieldPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    backgroundColor: const Color.fromARGB(255, 15, 20, 15),
                    searchFieldInputDecoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      hintText: 'Search...',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      hintStyle: baseTextStyle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    listTileDivider: const SizedBox(height: 0),
                    countryNameStyle: baseTextStyle.copyWith(
                      fontSize: 16,
                    ),
                    countryCodeStyle: GoogleFonts.spaceMono(
                      fontSize: 18,
                    ),
                  ),
                  onChanged: (phone) {
                    valid = phone.number.length >= 10 && phone.isValidNumber();
                    phoneNumber = phone.completeNumber;
                  },
                ),
                // Rich text for privacy policy and terms of service
                const SizedBox(height: 8),
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
                Container(
                  padding: const EdgeInsets.only(bottom: 32),
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (!valid) {
                        toastification.show(
                          style: ToastificationStyle.fillColored,
                          applyBlurEffect: true,
                          context: context,
                          type: ToastificationType.error,
                          title:
                              const Text('Please enter a valid phone number'),
                          autoCloseDuration: const Duration(seconds: 5),
                        );
                        return;
                      }
                      FocusScope.of(context).requestFocus(FocusNode());
                      Get.to(() => const AuthPage2());
                    },
                    child: const Text('Continue'),
                  ),
                ),
              ].animate(interval: 800.ms).fade(duration: 500.ms),
            ),
          ],
        ),
      ),
    );
  }
}
