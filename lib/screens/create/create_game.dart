import 'dart:ui';

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
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Create Game', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGlassCard(
            title: '',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText('Game Wizard 🧙‍♂️'),
                const SizedBox(height: 8),
                _buildDescriptionText(
                  'Welcome to the game creation wizard! Let\'s get started by choosing the type of game you want to create.',
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white54),
                const SizedBox(height: 16),
                _buildHeaderText('Game Type'),
                const SizedBox(height: 8),
                _buildGameTypeOption(
                  value: 'claimthezone',
                  title: 'ClaimRush',
                  players: '2-12 teams',
                  duration: '1hour - 4hours',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _navigateToNextScreen(),
                    child: Text(
                      'Continue',
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
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: baseTextStyle.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDescriptionText(String text) {
    return Text(
      text,
      style: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildGameTypeOption({
    required String value,
    required String title,
    required String players,
    required String duration,
  }) {
    return RadioListTile(
      value: value,
      groupValue: gameType,
      onChanged: (value) {
        setState(() {
          gameType = value.toString();
        });
      },
      activeColor: Colors.green,
      contentPadding: const EdgeInsets.all(0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: baseTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.users,
                color: Colors.grey,
                size: 14,
              ),
              const SizedBox(width: 4),
              _buildIconText(players),
              const SizedBox(width: 16),
              const FaIcon(
                FontAwesomeIcons.clock,
                color: Colors.grey,
                size: 14,
              ),
              const SizedBox(width: 4),
              _buildIconText(duration),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(String text) {
    return Text(
      text,
      style: baseTextStyle.copyWith(
        fontSize: 14,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _navigateToNextScreen() {
    if (gameType == 'claimthezone') {
      Get.to(() => const ClaimZone1());
    }
  }
}

Widget _buildGlassCard({required String title, required Widget child}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: baseTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              if (title.isNotEmpty) const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}
