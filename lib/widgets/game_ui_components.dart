import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:scavhuntapp/models/game.dart';
import 'package:scavhuntapp/utils/theme_data.dart';

class GameCodeChip extends StatelessWidget {
  final Game currentGame;

  const GameCodeChip({Key? key, required this.currentGame}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(top: 4),
      child: Chip(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            bottomLeft: Radius.circular(6),
          ),
          side: BorderSide(
            color: Color.fromARGB(255, 19, 20, 47),
            width: 2,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Game Code',
                style: baseTextStyle.copyWith(
                    fontSize: 12, color: Colors.white54)),
            Text(currentGame.gameId,
                style: baseTextStyle.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class PlayerScoreChip extends StatelessWidget {
  final Game currentGame;
  final Player currentPlayer;

  const PlayerScoreChip(
      {Key? key, required this.currentGame, required this.currentPlayer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(top: 50),
      child: Chip(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            bottomLeft: Radius.circular(6),
          ),
          side: BorderSide(
            color: Color.fromARGB(255, 19, 20, 47),
            width: 2,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        label: SizedBox(
          height: 24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.trophy, size: 16),
              const SizedBox(width: 4),
              Text(currentPlayer.points.toString(),
                  style: baseTextStyle.copyWith(
                      fontSize: 16, color: Colors.white)),
              const SizedBox(width: 16),
              const VerticalDivider(),
              const SizedBox(width: 16),
              const FaIcon(FontAwesomeIcons.coins, size: 16),
              const SizedBox(width: 4),
              Text(currentPlayer.coinBalance.toString(),
                  style: baseTextStyle.copyWith(
                      fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerStatusChip extends StatelessWidget {
  final Player currentPlayer;

  const PlayerStatusChip({Key? key, required this.currentPlayer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.only(bottom: 100),
      child: Chip(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            bottomLeft: Radius.circular(6),
          ),
          side: BorderSide(
            color: Color.fromARGB(255, 19, 20, 47),
            width: 2,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        label: SizedBox(
          height:
              currentPlayer.sabotagedUntil.isAfter(DateTime.now()) ? 100 : 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMultiplierRow(),
              if (currentPlayer.sabotagedUntil.isAfter(DateTime.now())) ...[
                const SizedBox(height: 8),
                _buildSabotageRow(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiplierRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green,
          ),
          child: Column(
            children: [
              Text(
                _getMultiplierText(),
                style: baseTextStyle.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.gem,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (currentPlayer.pointBoostUntil.isAfter(DateTime.now()))
          SlideCountdown(
            duration: currentPlayer.pointBoostUntil.difference(DateTime.now()),
            slideDirection: SlideDirection.down,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            style: baseTextStyle.copyWith(
              fontSize: 24,
              color: Colors.green,
              fontWeight: FontWeight.w700,
            ),
            separatorStyle: baseTextStyle.copyWith(
              fontSize: 24,
              color: Colors.green,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _buildSabotageRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red,
          ),
          child: const FaIcon(
            FontAwesomeIcons.ban,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
        SlideCountdown(
          duration: currentPlayer.sabotagedUntil.difference(DateTime.now()),
          slideDirection: SlideDirection.down,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          style: baseTextStyle.copyWith(
            fontSize: 24,
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
          separatorStyle: baseTextStyle.copyWith(
            fontSize: 24,
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _getMultiplierText() {
    if (currentPlayer.pointBoostUntil.isBefore(DateTime.now())) return '1x';
    if (currentPlayer.pointMultiplier == 2 ||
        currentPlayer.pointMultiplier == 3) {
      return '${currentPlayer.pointMultiplier.toStringAsFixed(0)}x';
    }
    return '${currentPlayer.pointMultiplier.toStringAsFixed(1)}x';
  }
}
