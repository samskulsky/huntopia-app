import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:scavhuntapp/models/game.dart';
import 'package:scavhuntapp/screens/home_screen.dart';
import 'package:scavhuntapp/utils/game_utils.dart';
import 'package:scavhuntapp/utils/theme_data.dart';

import '../../main.dart';

class GameEndScreen extends StatefulWidget {
  final Game currentGame;
  final Player currentPlayer;

  const GameEndScreen({
    super.key,
    required this.currentGame,
    required this.currentPlayer,
  });

  @override
  State<GameEndScreen> createState() => _GameEndScreenState();
}

class _GameEndScreenState extends State<GameEndScreen>
    with SingleTickerProviderStateMixin {
  bool showContent = false;
  int countdown = 10;
  String calculationText = '';
  late final AnimationController _controller;
  final List<_EmojiData> _emojis = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    final random = Random(42);
    for (int i = 0; i < 12; i++) {
      _emojis.add(_EmojiData(
        emoji: ['🏆', '🏁', '📍', '🗺️', '🎲', '🫣'][i % 6],
        startX: random.nextDouble(),
        startDelay: i / 12,
      ));
    }
    _playDrumrollAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playDrumrollAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => showContent = false);

    for (int i = 10; i >= 0; i--) {
      if (!mounted) return;
      setState(() {
        countdown = i;
        if (i == 9) calculationText = 'Converting coins to points...';
        if (i == 7) calculationText = 'Tallying zone captures...';
        if (i == 5) calculationText = 'Calculating final bonuses...';
        if (i == 3) calculationText = 'Determining rankings...';
        if (i == 1) calculationText = 'Preparing results...';
      });
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(seconds: 1));
    }

    if (mounted) setState(() => showContent = true);
  }

  Widget _buildMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        calculationText,
        style: baseTextStyle.copyWith(
          fontSize: 18,
          color: Colors.white.withOpacity(0.9),
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildFloatingEmojis() {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: _emojis.map((emojiData) {
        return Positioned(
          left: emojiData.startX * size.width,
          bottom: 0,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = (_controller.value + emojiData.startDelay) % 1.0;
              return Opacity(
                opacity: 0.7 - (progress * 0.3),
                child: Transform.translate(
                  offset: Offset(
                    sin(progress * 2 * pi) * 20,
                    -progress * size.height,
                  ),
                  child: Text(
                    emojiData.emoji,
                    style: const TextStyle(fontSize: 45),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!showContent) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: _buildFloatingEmojis(),
            ),
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Game Over',
                        style: baseTextStyle.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 400)),
                      const SizedBox(height: 48),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rotating ring
                              Transform.rotate(
                                angle: _controller.value * 2 * pi,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              // Number
                              Text(
                                countdown.toString(),
                                style: baseTextStyle.copyWith(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -2,
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                      duration:
                                          const Duration(milliseconds: 200))
                                  .scale(
                                    begin: const Offset(0.9, 0.9),
                                    end: const Offset(1, 1),
                                    curve: Curves.easeOutBack,
                                    duration: const Duration(milliseconds: 200),
                                  ),
                            ],
                          );
                        },
                      ),
                      if (calculationText.isNotEmpty) _buildMessage(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Game Ended',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Game Over! 🏁',
            style: baseTextStyle.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .scale(duration: const Duration(milliseconds: 600)),
          const SizedBox(height: 12),
          Text(
            'The game has ended. Your final score is ${widget.currentPlayer.points + widget.currentPlayer.coinBalance} points. Each extra coin (you had ${widget.currentPlayer.coinBalance}) was converted to a point.',
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Final Leaderboard',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                ListView.separated(
                  itemCount: widget.currentGame.players.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.white.withOpacity(0.1),
                    height: 1,
                  ),
                  itemBuilder: (context, index) => _buildLeaderboardItem(index),
                ),
              ],
            ),
          ).animate().fadeIn(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
              ),
          const SizedBox(height: 32),
          Text(
            'Want to see the full game recap?',
            style: baseTextStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'View detailed statistics, achievements, and more on our website.',
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.2),
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                launchUrl(
                  Uri.parse(
                      'https://scavhuntapp.web.app/#/${widget.currentGame.gameId}'),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Text(
                'View Game Recap',
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                prefs.remove('currentGameId');
                FirebaseMessaging.instance
                    .unsubscribeFromTopic('game-${widget.currentGame.gameId}');
                Get.off(() => const HomeScreen());
              },
              child: Text(
                'Leave Game',
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate().fadeIn(
                duration: const Duration(milliseconds: 600),
                delay: Duration(
                    milliseconds:
                        300 + (widget.currentGame.players.length * 100)),
              ),
          const SizedBox(height: 32),
        ],
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 800),
        );
  }

  Widget _buildLeaderboardItem(int index) {
    final player = widget.currentGame.players[index];
    final totalScore = player.points + player.coinBalance;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: getColor(player.teamColor).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            index == 0
                ? '🥇'
                : index == 1
                    ? '🥈'
                    : index == 2
                        ? '🥉'
                        : '${index + 1}',
            style: baseTextStyle.copyWith(fontSize: 28),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          player.teamName,
          style: baseTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      subtitle: Text(
        '${player.points} points + ${player.coinBalance} coins',
        style: baseTextStyle.copyWith(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      trailing: GradientText(
        totalScore.toString(),
        style: baseTextStyle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        colors: index < 3
            ? _getGradientColors(index)
            : [getColor(player.teamColor)],
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: 300 + (index * 100)),
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
}

class _EmojiData {
  final String emoji;
  final double startX;
  final double startDelay;

  _EmojiData({
    required this.emoji,
    required this.startX,
    required this.startDelay,
  });
}
