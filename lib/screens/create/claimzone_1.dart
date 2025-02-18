import 'dart:ui';

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
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ClaimRush',
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
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Text(
                    'Great choice! ',
                    style: baseTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text('🎉', style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'ClaimRush is a game where players must physically visit locations to claim them.',
                style: baseTextStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Game Name',
                style: baseTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: gameNameController,
                hintText: 'The Great Tokyo Scavenger Hunt',
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 32),
              Text(
                'Game Description',
                style: baseTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: gameDescriptionController,
                hintText:
                    'This game will take you on a journey through the streets of Tokyo, where you will visit famous landmarks and hidden gems.',
                maxLines: 4,
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
                  onPressed: _onNextPressed,
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
        hintStyle: baseTextStyle.copyWith(
          color: Colors.white38,
          fontStyle: FontStyle.italic,
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textCapitalization: capitalization,
      maxLines: maxLines,
      style: baseTextStyle.copyWith(
        color: Colors.white,
        fontSize: 16,
      ),
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
