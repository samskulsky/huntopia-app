import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/game.dart';
import '../../utils/theme_data.dart';
import 'purchase_screen.dart';

class EditTeamScreen extends StatefulWidget {
  const EditTeamScreen({super.key});

  @override
  State<EditTeamScreen> createState() => _EditTeamScreenState();
}

String currentPlayerId = '';

class _EditTeamScreenState extends State<EditTeamScreen> {
  late Player currentPlayer;
  late TextEditingController teamNameController;
  int pointDifference = 0;
  int coinDifference = 0;

  @override
  void initState() {
    super.initState();
    currentPlayer = cGame!.players.firstWhere(
      (element) => element.playerId == currentPlayerId,
    );
    teamNameController = TextEditingController(text: currentPlayer.teamName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Team'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTitle('Edit Team'),
          _buildSubtitle(
              'Edit team details below. Changes will be reflected upon saving.'),
          const SizedBox(height: 16),
          _buildTeamNameField(),
          const SizedBox(height: 16),
          _buildAdjustableRow('Points', currentPlayer.points, pointDifference,
              (change) => setState(() => pointDifference += change)),
          _buildAdjustableRow(
              'Coins',
              currentPlayer.coinBalance,
              coinDifference,
              (change) => setState(() => coinDifference += change)),
          const SizedBox(height: 16),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: baseTextStyle.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Text(
      text,
      style: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTeamNameField() {
    return TextField(
      controller: teamNameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Team Name',
      ),
      maxLength: 25,
    );
  }

  Widget _buildAdjustableRow(String label, int baseValue, int difference,
      Function(int change) onAdjust) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ${baseValue + difference}',
          style: baseTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.circlePlus),
              onPressed: () => onAdjust(1),
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.circleMinus),
              onPressed: () => onAdjust(-1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return FilledButton(
      onPressed: () {
        currentPlayer.points += pointDifference;
        currentPlayer.coinBalance += coinDifference;
        currentPlayer.teamName = teamNameController.text;

        cGame!.logMessages.add(
          LogMessage(
            message:
                'The host has made changes. (Team: ${currentPlayer.teamName}, Point difference: $pointDifference, Coin difference: $coinDifference)',
            uid: FirebaseAuth.instance.currentUser!.uid,
            timestamp: DateTime.now(),
            displayName: 'Game Update',
          ),
        );

        updateGame(cGame!);
        Navigator.pop(context);
      },
      child: const Text('Save'),
    );
  }
}
