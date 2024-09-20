import 'dart:ui';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/maingamescreen.dart';
import 'package:scavhuntapp/screens/home_screen.dart';

import '../../main.dart';
import '../../utils/theme_data.dart';

class WarningPage extends StatefulWidget {
  const WarningPage({super.key});

  @override
  State<WarningPage> createState() => _WarningPageState();
}

class _WarningPageState extends State<WarningPage> {
  Future<void> _agreeAndContinue() async {
    prefs.setBool('safetyWarning', true);

    Get.offAll(() => const MainGameScreen());

    try {
      print('Subscribing to game-${prefs.getString('currentGameId')}');
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging
          .subscribeToTopic('game-${prefs.getString('currentGameId')}');
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  void _cancel() {
    prefs.setString('currentGameId', '');
    Get.offAll(() => const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Safety Notice', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderText(),
          const SizedBox(height: 8),
          _buildBodyText(),
          const SizedBox(height: 16),
          _buildWarningTile(
              'DO NOT play ClaimRush while driving or operating a vehicle.'),
          const SizedBox(height: 8),
          _buildWarningTile(
              'DO NOT play ClaimRush in dangerous or hazardous areas.'),
          const SizedBox(height: 8),
          _buildWarningTile(
              'DO NOT play ClaimRush in areas where it is illegal to do so.'),
          const SizedBox(height: 16),
          _buildFooterText(),
          const SizedBox(height: 16),
          _buildButtonsCard().animate(delay: 1000.ms).flip()
        ],
      ),
    );
  }

  Widget _buildHeaderText() {
    return Text(
      'Safety Notice',
      style: baseTextStyle.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBodyText() {
    return Text(
      'While playing ClaimRush, please be aware of your surroundings and follow all local laws and regulations. Do not trespass or enter private property.\n\nStay safe and have fun! 🎉',
      style: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildWarningTile(String message) {
    return ListTile(
      tileColor: Colors.red,
      leading: const Icon(Icons.warning, color: Colors.white),
      title: Text(
        message,
        style: baseTextStyle.copyWith(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Text(
      'Please note that we are not responsible for any injuries or accidents that may occur while playing ClaimRush. By continuing, you agree to these terms and release us from any liability.',
      style: baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildButtonsCard() {
    return _buildGlassCard(
      title: '',
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _agreeAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Agree & Continue',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 106, 23, 23),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a glassmorphism card with optional title and child widgets.
  Widget _buildGlassCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05)
          ],
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
}
