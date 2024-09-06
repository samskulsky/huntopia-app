import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../utils/theme_data.dart';
import 'claimzone_4.dart';

class ClaimZone3 extends StatefulWidget {
  const ClaimZone3({super.key});

  @override
  State<ClaimZone3> createState() => _ClaimZone3State();
}

class _ClaimZone3State extends State<ClaimZone3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClaimRush'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Now, let\'s zone in on the details.',
              style: baseTextStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Soon, you can start to add zones to your game. Zones are the locations that players will need to visit to claim them.\n\nIn addition to being physically present at the location, players will also need to complete one of the following tasks:',
              style: baseTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Get.isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            _buildTaskTile(
              icon: FontAwesomeIcons.question,
              title: 'Answer a question',
              subtitle:
                  'Players will need to answer a question correctly to claim the zone.',
            ),
            _buildTaskTile(
              icon: FontAwesomeIcons.camera,
              title: 'Take a selfie',
              subtitle: 'Players will need to take a photo to claim the zone.',
            ),
            _buildTaskTile(
              icon: FontAwesomeIcons.qrcode,
              title: 'Scan a QR code',
              subtitle:
                  'Players will need to scan a QR code to claim the zone.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Get.to(() => const ClaimZone4());
              },
              child: const Text('Got it!'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: FaIcon(icon),
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle),
    );
  }
}
