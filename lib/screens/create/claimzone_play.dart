import 'dart:math';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scavhuntapp/main.dart';
import 'package:scavhuntapp/models/game.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/warning.dart';
import 'package:scavhuntapp/screens/create/claimzone_1.dart';
import 'package:scavhuntapp/screens/home_screen.dart';

import '../../utils/theme_data.dart';

class ClaimZonePlay extends StatefulWidget {
  const ClaimZonePlay({super.key});

  @override
  State<ClaimZonePlay> createState() => _ClaimZonePlayState();
}

class _ClaimZonePlayState extends State<ClaimZonePlay> {
  num maxPlayers = 6;
  num gameDuration = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Game', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                Text(
                  'It\'s time to play!',
                  style: baseTextStyle.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Now that your game is all set up, it\'s time to play! Fill out the fields below to host it.',
                  style: baseTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Get.isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white54),
                const SizedBox(height: 16),
                _buildSectionHeader('Max Teams'),
                const SizedBox(height: 8),
                Text(
                  'How many teams will be playing? Each team should only have one device.',
                  style: baseTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Get.isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$maxPlayers team${maxPlayers > 1 ? 's' : ''}',
                  style: baseTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                Slider(
                  value: maxPlayers.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      maxPlayers = value.toInt();
                    });
                  },
                  min: 2,
                  max: 12,
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white54),
                const SizedBox(height: 16),
                _buildSectionHeader('Game Duration'),
                const SizedBox(height: 8),
                Text(
                  'How long will the game last? The game will automatically end after this duration. During the game, you can extend or end the game manually.',
                  style: baseTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Get.isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(gameDuration),
                  style: baseTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                Slider(
                  value: gameDuration.toDouble(),
                  divisions: 114,
                  onChanged: (value) {
                    setState(() {
                      gameDuration = value.toInt();
                    });
                  },
                  min: 30,
                  max: 600,
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white54),
                const SizedBox(height: 16),
                _buildSectionHeader('Start Game'),
                const SizedBox(height: 8),
                Text(
                  'Once you start the game, you will not be able to make any changes to the game template. Are you sure you want to start the game?',
                  style: baseTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Get.isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _startGame();
                    },
                    child: Text(
                      'Start Game',
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
          ),
        ],
      ),
    );
  }

  String _formatDuration(num duration) {
    if (duration % 60 == 0) {
      return '${duration ~/ 60} hour${duration ~/ 60 > 1 ? 's' : ''}';
    } else if (duration < 60) {
      return '$duration minute${duration > 1 ? 's' : ''}';
    } else if (duration < 120) {
      return '${duration ~/ 60} hour ${duration % 60} minute${duration % 60 > 1 ? 's' : ''}';
    } else {
      return '${duration ~/ 60} hours ${duration % 60} minutes';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  void _startGame() {
    if (maxPlayers < 2 ||
        maxPlayers > 12 ||
        gameDuration < 30 ||
        gameDuration > 600) {
      // error
      return;
    }

    String gameId = generateRandomString(6);
    Game game = Game(
      gameId: gameId,
      hostUid: FirebaseAuth.instance.currentUser!.uid,
      hostName: currentUser!.displayName,
      durationMinutes: gameDuration.toInt(),
      maxTeams: maxPlayers.toInt(),
      created: DateTime.now(),
      startTime: DateTime.now().add(const Duration(minutes: 60)),
      endTime: DateTime.now().add(Duration(minutes: 60 + gameDuration.toInt())),
      players: [
        Player(
          playerId: FirebaseAuth.instance.currentUser!.uid,
          teamName: 'Team ${currentUser!.displayName}',
          teamColor: 'blue',
          points: 0,
          coinBalance: 0,
          sabotagedUntil: DateTime.now().subtract(const Duration(seconds: 1)),
          pointBoostUntil: DateTime.now().subtract(const Duration(seconds: 1)),
          sabotagedAt: DateTime.now(),
          pointBoostAt: DateTime.now(),
          pointMultiplier: 1,
          zonesClaimed: [],
          skips: 0,
          fcmToken: currentUser!.fcmToken ?? '',
          location: null,
        )
      ],
      gameType: 'claimthezone',
      gameStatus: 'pending',
      allPlayerPointMultiplier: 1,
      logMessages: [
        LogMessage(
          uid: 'system',
          message: 'Get ready, the game is starting soon!',
          timestamp: DateTime.now(),
          displayName: 'ClaimRush',
        ),
      ],
      game: gameTemplate,
    );
    createGame(game);
    prefs.setString('currentGameId', gameId);
    Get.offAll(() => const WarningPage());
  }

  String generateRandomString(int length) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return List.generate(length, (_) => letters[random.nextInt(letters.length)])
        .join();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
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
