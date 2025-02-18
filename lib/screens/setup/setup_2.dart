import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/models/app_user.dart';

import '../../utils/theme_data.dart';
import '../../utils/toastification_helper.dart';
import '../../widgets/gradient_background.dart';
import 'setup_3.dart';

class SetupPage2 extends StatefulWidget {
  const SetupPage2({super.key});

  @override
  State<SetupPage2> createState() => _SetupPage2State();
}

AppUser appUser = AppUser(
  uid: FirebaseAuth.instance.currentUser!.uid,
  phoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber ?? '',
  firstName: '',
  lastName: '',
  displayName: '',
  email: FirebaseAuth.instance.currentUser!.email ?? '',
  photoURL: '',
  apnsToken: '',
  fcmToken: '',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  friends: [],
  friendRequests: [],
  sentFriendRequests: [],
  role: 'user',
  tokens: 3,
);

class _SetupPage2State extends State<SetupPage2> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    appUser = AppUser(
      uid: FirebaseAuth.instance.currentUser!.uid,
      phoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber ?? '',
      firstName: '',
      lastName: '',
      displayName: '',
      email: FirebaseAuth.instance.currentUser!.email ?? '',
      photoURL: '',
      apnsToken: '',
      fcmToken: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      friends: [],
      friendRequests: [],
      sentFriendRequests: [],
      role: 'user',
      tokens: 3,
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
          'Personal Info',
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
                'What\'s your name?',
                style: baseTextStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 8),
              Text(
                'Please enter your first and last name.',
                style: baseTextStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              const SizedBox(height: 32),
              _buildTextField(
                controller: firstNameController,
                labelText: 'First Name',
                onChanged: (value) {
                  _capitalizeAndTrimText(firstNameController);
                  appUser.firstName = value;
                },
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              const SizedBox(height: 16),
              _buildTextField(
                controller: lastNameController,
                labelText: 'Last Name',
                onChanged: (value) {
                  _capitalizeAndTrimText(lastNameController);
                  appUser.lastName = value;
                },
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
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
                    if (firstNameController.text.isEmpty ||
                        lastNameController.text.isEmpty) {
                      ToastificationHelper.showErrorToast(
                        context,
                        'Please fill in all fields',
                      );
                      return;
                    }
                    Get.to(() => const SetupPage3());
                  },
                  child: Text(
                    'Continue',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: baseTextStyle.copyWith(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade400),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: baseTextStyle.copyWith(color: Colors.white),
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      onChanged: onChanged,
    );
  }

  void _capitalizeAndTrimText(TextEditingController controller) {
    if (controller.text.isNotEmpty) {
      controller.text = controller.text[0].toUpperCase() +
          controller.text.substring(1).toLowerCase();
      controller.text = controller.text.replaceAll(RegExp(r'\s+'), ' ');
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }
}
