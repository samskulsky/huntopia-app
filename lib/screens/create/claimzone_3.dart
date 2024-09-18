import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: const Text('ClaimRush', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildGlassCard(
            title: '',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Now, let\'s zone in on the details.',
                  style: baseTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Soon, you can start to add zones to your game. Zones are the locations that players will need to visit to claim them.\n\nIn addition to being physically present at the location, players will also need to complete one of the following tasks:',
                  style: baseTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
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
                  subtitle:
                      'Players will need to take a photo to claim the zone.',
                ),
                _buildTaskTile(
                  icon: FontAwesomeIcons.qrcode,
                  title: 'Scan a QR code',
                  subtitle:
                      'Players will need to scan a QR code to claim the zone.',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.to(() => const ClaimZone4());
                    },
                    child: Text(
                      'Got it!',
                      style: baseTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      leading: FaIcon(icon, color: Colors.white),
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: baseTextStyle.copyWith(color: Colors.white70),
      ),
    );
  }
}

Widget _buildGlassCard({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    ),
  );
}
