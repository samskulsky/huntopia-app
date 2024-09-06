import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    try {
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

    Get.offAll(() => const MainGameScreen());
  }

  void _cancel() {
    prefs.setString('currentGameId', '');
    Get.offAll(() => const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Notice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            _buildAgreeButton(),
            const SizedBox(height: 8),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Text(
      'Safety Notice',
      style: baseTextStyle.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildBodyText() {
    return Text(
      'While playing ClaimRush, please be aware of your surroundings and follow all local laws and regulations. Do not trespass or enter private property.\n\nStay safe and have fun! 🎉',
      style: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildWarningTile(String message) {
    return ListTile(
      tileColor: Colors.red,
      leading: const Icon(Icons.warning),
      title: Text(message),
    );
  }

  Widget _buildFooterText() {
    return Text(
      'Please note that we are not responsible for any injuries or accidents that may occur while playing ClaimRush. By continuing, you agree to these terms and release us from any liability.',
      style: baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Get.isDarkMode ? Colors.white54 : Colors.black54,
      ),
    );
  }

  Widget _buildAgreeButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _agreeAndContinue,
        child: const Text('Agree & Continue'),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _cancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 106, 23, 23),
        ),
        child: const Text('Cancel'),
      ),
    );
  }
}
