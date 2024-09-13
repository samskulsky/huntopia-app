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
        title: const Text('Create Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderText('Game Wizard 🧙‍♂️'),
            const SizedBox(height: 8),
            _buildDescriptionText(
              'Welcome to the game creation wizard! Let\'s get started by choosing the type of game you want to create.',
            ),
            const SizedBox(height: 16),
            const Divider(),
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
              child: FilledButton(
                onPressed: () => _navigateToNextScreen(),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: baseTextStyle.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDescriptionText(String text) {
    return Text(
      text,
      style: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Get.isDarkMode ? Colors.white54 : Colors.black54,
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
      contentPadding: const EdgeInsets.all(0),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: baseTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
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
