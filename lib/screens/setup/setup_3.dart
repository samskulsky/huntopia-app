import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import 'package:username_generator/username_generator.dart';

import 'setup_2.dart';
import 'setup_4.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thanks, ${appUser.firstName}!',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'What do you want your username to be? We\'ve suggested one for you, but you can change it if you want.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Get.isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(FontAwesomeIcons.at),
              ),
              maxLength: 20,
              keyboardType: TextInputType.text,
              autocorrect: false,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  return;
                }
                usernameController.text = usernameController.text
                    .replaceAll(RegExp(r'\s+'), '')
                    .toLowerCase();
                // no spaces, all lowercase
                usernameController.text = usernameController.text
                    .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (usernameController.text.isEmpty ||
                    usernameController.text.length < 5) {
                  toastification.show(
                    style: ToastificationStyle.fillColored,
                    applyBlurEffect: true,
                    context: context,
                    type: ToastificationType.error,
                    title: const Text('Username must be at least 5 characters'),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                  return;
                }
                appUser.displayName = usernameController.text;
                Get.to(() => const SetupPage4());
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
