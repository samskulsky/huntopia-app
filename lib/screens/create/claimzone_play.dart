import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/main.dart';
import 'package:scavhuntapp/models/game.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/warning.dart';
import 'package:scavhuntapp/screens/create/claimzone_1.dart';
import 'package:scavhuntapp/screens/home_screen.dart';
import 'package:scavhuntapp/widgets/gradient_background.dart';

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
        title: Text(
          'Setup Game',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'It\'s time to play!',
                style: baseTextStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Now that your game is all set up, it\'s time to play! Fill out the fields below to host it.',
                style: baseTextStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Max Teams',
                      style: baseTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How many teams will be playing? Each team should only have one device.',
                      style: baseTextStyle.copyWith(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Teams',
                          style: baseTextStyle.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '$maxPlayers team${maxPlayers > 1 ? 's' : ''}',
                          style: baseTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.green,
                        inactiveTrackColor: Colors.white.withOpacity(0.1),
                        thumbColor: Colors.green,
                        overlayColor: Colors.green.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: maxPlayers.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            maxPlayers = value.toInt();
                          });
                        },
                        min: 2,
                        max: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Game Duration',
                      style: baseTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How long will the game last? The game will automatically end after this duration. During the game, you can extend or end the game manually.',
                      style: baseTextStyle.copyWith(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration',
                          style: baseTextStyle.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          _formatDuration(gameDuration),
                          style: baseTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.green,
                        inactiveTrackColor: Colors.white.withOpacity(0.1),
                        thumbColor: Colors.green,
                        overlayColor: Colors.green.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: gameDuration.toDouble(),
                        divisions: 114,
                        onChanged: (value) {
                          setState(() {
                            gameDuration = value.toInt();
                          });
                        },
                        min: 30,
                        max: 600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
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
                onPressed: _startGame,
                child: Text(
                  'Start Game',
                  style: baseTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
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
