import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/screens/home_screen.dart';

import '../../utils/theme_data.dart';
import 'setup_2.dart';

class SetupPage5 extends StatefulWidget {
  const SetupPage5({super.key});

  @override
  State<SetupPage5> createState() => _SetupPage5State();
}

class _SetupPage5State extends State<SetupPage5> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finish'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'That\'s it! 🎉',
              style: baseTextStyle.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all set up and ready to go! Tap the button below to start using the app!',
              style: baseTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
              ),
            ),
            _buildInfoTile(
              icon: FontAwesomeIcons.phone,
              title: 'Phone',
              subtitle: appUser.phoneNumber,
            ),
            _buildInfoTile(
              icon: FontAwesomeIcons.solidUser,
              title: 'Username',
              subtitle: appUser.displayName,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                Get.offAll(() => const HomeScreen());
              },
              child: const Text('Let\'s go!'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      title: Text(title, style: baseTextStyle.copyWith(fontSize: 18)),
      subtitle: Text(subtitle),
      leading: FaIcon(icon),
    );
  }
}
