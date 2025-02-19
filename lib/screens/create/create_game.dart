import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../utils/theme_data.dart';
import 'claimzone_1.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  String gameType = 'claimthezone';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Game',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.green.shade900.withOpacity(0.3),
              Colors.black,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Text(
                  'Game Wizard ',
                  style: baseTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text('🧙‍♂️', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to the game creation wizard! Let\'s get started by choosing the type of game you want to create.',
              style: baseTextStyle.copyWith(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Game Type',
              style: baseTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  _buildGameTypeOption(
                    value: 'claimthezone',
                    title: 'ClaimRush',
                    players: '2-12 teams',
                    duration: '1-10 hours',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _navigateToNextScreen,
                child: Text(
                  'Continue',
                  style: baseTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTypeOption({
    required String value,
    required String title,
    required String players,
    required String duration,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gameType == value ? Colors.green.shade400 : Colors.transparent,
          width: 2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gameType == value
              ? [Colors.green.shade900.withOpacity(0.3), Colors.transparent]
              : [Colors.transparent, Colors.transparent],
        ),
      ),
      child: RadioListTile(
        value: value,
        groupValue: gameType,
        onChanged: (value) {
          setState(() {
            gameType = value.toString();
          });
        },
        activeColor: Colors.green.shade400,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: baseTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.users,
                        color: Colors.green.shade200,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        players,
                        style: baseTextStyle.copyWith(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.clock,
                        color: Colors.green.shade200,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        duration,
                        style: baseTextStyle.copyWith(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNextScreen() {
    if (gameType == 'claimthezone') {
      Get.to(() => const ClaimZone1());
    }
  }
}
