import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/models/game_template.dart';
import 'package:uuid/uuid.dart';

import '../../utils/theme_data.dart';
import '../home_screen.dart';
import 'claimzone_loc_picker.dart';

class ClaimZone1 extends StatefulWidget {
  const ClaimZone1({super.key});

  @override
  State<ClaimZone1> createState() => _ClaimZone1State();
}

GameTemplate gameTemplate = GameTemplate(
  gameType: 'claimthezone',
  templateId: const Uuid().v4(),
  creatorUid: FirebaseAuth.instance.currentUser!.uid,
  creatorName: currentUser?.displayName ?? '',
  gameName: '',
  gameDescription: '',
  createdAt: DateTime.now(),
  lastUpdated: DateTime.now(),
);

class _ClaimZone1State extends State<ClaimZone1> {
  final TextEditingController gameNameController = TextEditingController();
  final TextEditingController gameDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    gameTemplate = GameTemplate(
      gameType: 'claimthezone',
      templateId: const Uuid().v4(),
      creatorUid: currentUser!.uid,
      creatorName: currentUser!.displayName,
      gameName: '',
      gameDescription: '',
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

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
        child: ListView(
          children: [
            _buildHeaderText('Great choice! 🎉'),
            const SizedBox(height: 8),
            _buildDescriptionText(
              'ClaimRush is a game where players must physically visit a location to claim it.',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildHeaderText('Game Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: gameNameController,
              hintText: 'The Great Tokyo Scavenger Hunt',
              capitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            _buildHeaderText('Game Description'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: gameDescriptionController,
              hintText:
                  'This game will take you on a journey through the streets of Tokyo, where you will visit famous landmarks and hidden gems.',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _onNextPressed,
              child: const Text('Next'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextCapitalization capitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
      ),
      textCapitalization: capitalization,
      maxLines: maxLines,
    );
  }

  void _onNextPressed() {
    if (gameNameController.text.isEmpty ||
        gameDescriptionController.text.isEmpty) {
      return;
    }
    gameTemplate
      ..gameName = gameNameController.text
      ..gameDescription = gameDescriptionController.text;
    Get.to(() => const ClaimZoneLocPicker());
  }
}
