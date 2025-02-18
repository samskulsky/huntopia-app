import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:scavhuntapp/models/game.dart';
import 'package:scavhuntapp/screens/home_screen.dart';
import 'package:scavhuntapp/utils/game_utils.dart';
import 'package:scavhuntapp/utils/theme_data.dart';

import '../../main.dart';

class GameEndScreen extends StatelessWidget {
  final Game currentGame;
  final Player currentPlayer;

  const GameEndScreen({
    Key? key,
    required this.currentGame,
    required this.currentPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Ended'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Game Over! 🏁',
            style: baseTextStyle.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          )
              .animate()
              .flip(duration: const Duration(seconds: 1))
              .scale(duration: const Duration(seconds: 1)),
          const SizedBox(height: 16),
          Text(
            'The game has ended. Your final score is ${currentPlayer.points + currentPlayer.coinBalance} points. Each extra coin (you had ${currentPlayer.coinBalance}) was converted to a point. \n\nView the game recap at https://scavhuntapp.web.app/#/${currentGame.gameId}.\n\nWe hope you had fun! 😀\n',
            style: baseTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
            ),
          ),
          _buildRecapButton(),
          const SizedBox(height: 16),
          _buildLeaderboardTitle(),
          const SizedBox(height: 16),
          _buildLeaderboardList(),
          const SizedBox(height: 16),
          _buildLeaveButton(),
        ],
      ),
    );
  }

  Widget _buildRecapButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        launchUrl(
          Uri.parse('https://scavhuntapp.web.app/#/${currentGame.gameId}'),
          mode: LaunchMode.externalApplication,
        );
      },
      child: Text(
        'View Game Recap',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLeaderboardTitle() {
    return Text(
      'Leaderboard',
      style: baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ).animate().fadeIn(
        duration: const Duration(seconds: 1),
        delay: const Duration(seconds: 3));
  }

  Widget _buildLeaderboardList() {
    return ListView.separated(
      itemCount: currentGame.players.length,
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildLeaderboardItem(index),
    );
  }

  Widget _buildLeaderboardItem(int index) {
    return Container(
      padding: const EdgeInsets.only(right: 16),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                index == 0
                    ? '🥇 '
                    : index == 1
                        ? '🥈 '
                        : index == 2
                            ? '🥉 '
                            : '',
                style: baseTextStyle.copyWith(
                  fontSize: 40,
                ),
              ),
              Text(
                currentGame.players[index].teamName,
                style: baseTextStyle.copyWith(
                  fontSize: 22,
                ),
              ),
            ],
          ),
          _buildScore(index),
        ],
      ),
    )
        .animate()
        .fadeIn(
            duration: const Duration(seconds: 2),
            delay: Duration(seconds: 4 + index))
        .slideX(
            duration: const Duration(seconds: 1),
            delay: Duration(seconds: 5 + index));
  }

  Widget _buildScore(int index) {
    if (index < 3) {
      return GradientText(
        (currentGame.players[index].points +
                currentGame.players[index].coinBalance)
            .toString(),
        style: baseTextStyle.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w600,
        ),
        colors: _getGradientColors(index),
      );
    }
    return Text(
      currentGame.players[index].points.toString(),
      style: baseTextStyle.copyWith(
        fontSize: 30,
        color: getColor(currentGame.players[index].teamColor),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<Color> _getGradientColors(int index) {
    if (index == 0) {
      return [
        const Color.fromARGB(255, 241, 189, 0),
        const Color.fromARGB(255, 241, 129, 0),
        const Color.fromARGB(255, 241, 145, 0),
      ];
    } else if (index == 1) {
      return [
        const Color.fromARGB(255, 168, 169, 173),
        const Color.fromARGB(255, 192, 192, 195),
        const Color.fromARGB(255, 165, 165, 165),
      ];
    }
    return [
      const Color.fromARGB(255, 128, 74, 0),
      const Color.fromARGB(255, 137, 94, 26),
      const Color.fromARGB(255, 176, 141, 87),
    ];
  }

  Widget _buildLeaveButton() {
    return ElevatedButton(
      onPressed: () {
        prefs.remove('currentGameId');
        FirebaseMessaging.instance
            .unsubscribeFromTopic('game-${currentGame.gameId}');
        Get.off(() => const HomeScreen());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Leave Game',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ).animate().fadeIn(
        duration: const Duration(seconds: 1),
        delay: Duration(seconds: 6 + currentGame.players.length));
  }
}
