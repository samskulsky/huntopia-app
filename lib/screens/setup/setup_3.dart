import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import 'package:username_generator/username_generator.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/theme_data.dart';
import '../../utils/toastification_helper.dart';
import 'setup_2.dart';
import 'setup_4.dart';
import '../../widgets/gradient_background.dart';

class SetupPage3 extends StatefulWidget {
  const SetupPage3({super.key});

  @override
  State<SetupPage3> createState() => _SetupPage3State();
}

class _SetupPage3State extends State<SetupPage3> {
  TextEditingController usernameController = TextEditingController();

  var generator = UsernameGenerator();

  @override
  void initState() {
    super.initState();
    usernameController.text = generator.generate(
      '${appUser.firstName} ${appUser.lastName}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Choose Username',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Thanks, ${appUser.firstName}!',
                style: baseTextStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 8),
              Text(
                'What do you want your username to be? We\'ve suggested one for you, but you can change it if you want.',
                style: baseTextStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              const SizedBox(height: 32),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: baseTextStyle.copyWith(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade400),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  prefixText: '@',
                  prefixStyle: baseTextStyle.copyWith(color: Colors.white70),
                ),
                style: baseTextStyle.copyWith(color: Colors.white),
                maxLength: 20,
                onChanged: (value) {
                  if (value.isEmpty) return;
                  usernameController.text = usernameController.text
                      .replaceAll(RegExp(r'\s+'), '')
                      .toLowerCase()
                      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                  usernameController.selection = TextSelection.fromPosition(
                      TextPosition(offset: usernameController.text.length));
                },
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (usernameController.text.isEmpty ||
                        usernameController.text.length < 5) {
                      ToastificationHelper.showErrorToast(
                        context,
                        'Username must be at least 5 characters',
                      );
                      return;
                    }
                    appUser.displayName = usernameController.text;
                    Get.to(() => const SetupPage4());
                  },
                  child: Text(
                    'Continue',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
