import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/models/app_user.dart';

import '../../utils/theme_data.dart';
import '../../utils/toastification_helper.dart';
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
  email: '',
  photoURL: '',
  apnsToken: '',
  fcmToken: '',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  friends: [],
  friendRequests: [],
  sentFriendRequests: [],
  role: 'user',
  tokens: 1,
);

class _SetupPage2State extends State<SetupPage2> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'First, what\'s your name?',
              style: baseTextStyle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            _buildTextField(
              controller: firstNameController,
              labelText: 'First Name',
              onChanged: (value) => _capitalizeAndTrimText(firstNameController),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: lastNameController,
              labelText: 'Last Name',
              onChanged: (value) => _capitalizeAndTrimText(lastNameController),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (firstNameController.text.isEmpty ||
                    lastNameController.text.isEmpty) {
                  ToastificationHelper.showErrorToast(
                    context,
                    'Please enter your first and last name',
                  );
                  return;
                }
                appUser.firstName = firstNameController.text;
                appUser.lastName = lastNameController.text;
                Get.to(() => const SetupPage3());
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: TextInputType.text,
      autocorrect: false,
      style: baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
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
