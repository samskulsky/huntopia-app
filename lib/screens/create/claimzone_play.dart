import 'dart:math';

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
        title: const Text('Setup Game'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'It\'s time to play!',
            style: baseTextStyle.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w700,
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
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Max Teams',
            style: baseTextStyle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
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
            '$maxPlayers teams',
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
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Game Duration',
            style: baseTextStyle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
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
            gameDuration % 60 == 0
                ? '${gameDuration ~/ 60} hour${gameDuration ~/ 60 > 1 ? 's' : ''}'
                : gameDuration < 60
                    ? '$gameDuration minutes'
                    : gameDuration < 120
                        ? '${gameDuration ~/ 60} hour ${gameDuration % 60} minutes'
                        : '${gameDuration ~/ 60} hours ${gameDuration % 60} minutes',
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
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Start Game',
            style: baseTextStyle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
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
          FilledButton(
            onPressed: () {
              String gameId = generateRandomString(6);
              Game game = Game(
                gameId: gameId,
                hostUid: FirebaseAuth.instance.currentUser!.uid,
                hostName: currentUser!.displayName,
                durationMinutes: gameDuration.toInt(),
                maxTeams: maxPlayers.toInt(),
                created: DateTime.now(),
                startTime: DateTime.now().add(const Duration(minutes: 60)),
                endTime: DateTime.now()
                    .add(Duration(minutes: 60 + gameDuration.toInt())),
                players: [
                  Player(
                    playerId: FirebaseAuth.instance.currentUser!.uid,
                    teamName: 'Team ${currentUser!.displayName}',
                    teamColor: 'blue',
                    points: 0,
                    coinBalance: 0,
                    sabotagedUntil:
                        DateTime.now().subtract(const Duration(seconds: 1)),
                    pointBoostUntil:
                        DateTime.now().subtract(const Duration(seconds: 1)),
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
            },
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }
}

String generateRandomString(int length) {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final random = Random();
  return List.generate(length, (_) => letters[random.nextInt(letters.length)])
      .join();
}
