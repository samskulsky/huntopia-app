import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/game.dart';
import '../../utils/theme_data.dart';
import 'purchase_screen.dart';
import '../../utils/game_utils.dart';

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
  double newMultiplier = 0;
  DateTime? newBoostUntil;
  DateTime? newSabotagedUntil;
  int? newSkips;

  @override
  void initState() {
    super.initState();
    currentPlayer = cGame!.players.firstWhere(
      (element) => element.playerId == currentPlayerId,
    );
    teamNameController = TextEditingController(text: currentPlayer.teamName);
    newMultiplier = currentPlayer.pointMultiplier;
    newBoostUntil = currentPlayer.pointBoostUntil;
    newSabotagedUntil = currentPlayer.sabotagedUntil;
    newSkips = currentPlayer.skips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Team',
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
            'Team Management',
            style: baseTextStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Edit team details below. Changes will be reflected in real-time for all players.',
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
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Team Details',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: teamNameController,
                    decoration: InputDecoration(
                      labelText: 'Team Name',
                      labelStyle: baseTextStyle.copyWith(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green.shade400),
                      ),
                    ),
                    style: baseTextStyle.copyWith(fontSize: 16),
                    maxLength: 25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Point & Coin Adjustments',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                _buildAdjustmentTile(
                  'Points',
                  currentPlayer.points,
                  pointDifference,
                  (change) => setState(() => pointDifference += change),
                  FontAwesomeIcons.trophy,
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                _buildAdjustmentTile(
                  'Coins',
                  currentPlayer.coinBalance,
                  coinDifference,
                  (change) => setState(() => coinDifference += change),
                  FontAwesomeIcons.coins,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Power-Ups & Status',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.bolt,
                        color: Colors.yellow,
                        size: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    'Point Multiplier',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current: ${newBoostUntil != null && newBoostUntil!.isAfter(DateTime.now()) ? newMultiplier : 1.0}x${newMultiplier != currentPlayer.pointMultiplier ? ' (was: ${currentPlayer.pointMultiplier}x)' : ''}',
                        style: baseTextStyle.copyWith(
                          fontSize: 14,
                          color: newMultiplier != currentPlayer.pointMultiplier
                              ? Colors.yellow
                              : Colors.white70,
                        ),
                      ),
                      if (newBoostUntil != null &&
                          newBoostUntil!.isAfter(DateTime.now()))
                        Text(
                          'Active until ${DateFormat.jm().format(newBoostUntil!)}',
                          style: baseTextStyle.copyWith(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const FaIcon(FontAwesomeIcons.pen, size: 16),
                    onPressed: () {
                      showStandardDialog(
                        context: context,
                        title: 'Edit Multiplier',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set point multiplier',
                              style: baseTextStyle.copyWith(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                for (var multiplier in [1.0, 1.5, 2.0, 3.0])
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: newMultiplier ==
                                                  multiplier
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.1),
                                          foregroundColor:
                                              newMultiplier == multiplier
                                                  ? Colors.green
                                                  : Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            newMultiplier = multiplier;
                                            newBoostUntil = DateTime.now()
                                                .add(Duration(minutes: 5));
                                          });
                                        },
                                        child: Text('${multiplier}x'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Set duration',
                              style: baseTextStyle.copyWith(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                for (var minutes in [5, 15, 30, 60])
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.white.withOpacity(0.1),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            newBoostUntil = DateTime.now().add(
                                                Duration(minutes: minutes));
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text('${minutes}m'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.ban,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    'Disable Status',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (newSabotagedUntil != null &&
                          newSabotagedUntil!.isAfter(DateTime.now()))
                        Text(
                          'Disabled until ${DateFormat.jm().format(newSabotagedUntil!)}',
                          style: baseTextStyle.copyWith(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        )
                      else
                        Text(
                          'Not currently disabled',
                          style: baseTextStyle.copyWith(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      if (newSabotagedUntil != currentPlayer.sabotagedUntil)
                        Text(
                          '• Status will be ${newSabotagedUntil!.isAfter(DateTime.now()) ? 'disabled until ${DateFormat.jm().format(newSabotagedUntil!)}' : 'cleared'}',
                          style: baseTextStyle.copyWith(
                            fontSize: 14,
                            color: Colors.yellow,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.pen,
                      size: 16,
                    ),
                    onPressed: () {
                      showStandardDialog(
                        context: context,
                        title: 'Disable Team',
                        child: Column(
                          children: [
                            Text(
                              'Set disable duration in minutes',
                              style: baseTextStyle.copyWith(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                for (var minutes in [0, 5, 10, 15])
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: minutes == 0
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.red.withOpacity(0.2),
                                          foregroundColor: minutes == 0
                                              ? Colors.green
                                              : Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (minutes == 0) {
                                              newSabotagedUntil =
                                                  DateTime.now();
                                            } else {
                                              newSabotagedUntil = DateTime.now()
                                                  .add(Duration(
                                                      minutes: minutes));
                                            }
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text(minutes == 0
                                            ? 'Clear'
                                            : '${minutes}m'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.forward,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    'Skip Tokens',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Current: ${newSkips}${newSkips != currentPlayer.skips ? ' (was: ${currentPlayer.skips})' : ''}',
                    style: baseTextStyle.copyWith(
                      fontSize: 14,
                      color: newSkips != currentPlayer.skips
                          ? Colors.yellow
                          : Colors.white70,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.minus, size: 16),
                        onPressed: () {
                          if (newSkips! > 0) {
                            setState(() => newSkips = newSkips! - 1);
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                        onPressed: () {
                          setState(() => newSkips = newSkips! + 1);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
              onPressed: () {
                showStandardDialog(
                  context: context,
                  title: 'Save Changes',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review Changes',
                        style: baseTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (teamNameController.text != currentPlayer.teamName)
                        Text(
                          '• Team name will be changed to "${teamNameController.text}"',
                          style: baseTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      if (pointDifference != 0)
                        Text(
                          '• Points will be ${pointDifference > 0 ? "increased" : "decreased"} by ${pointDifference.abs()}',
                          style: baseTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      if (coinDifference != 0)
                        Text(
                          '• Coins will be ${coinDifference > 0 ? "increased" : "decreased"} by ${coinDifference.abs()}',
                          style: baseTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      if (newMultiplier != currentPlayer.pointMultiplier)
                        Text(
                          '• Point multiplier will be changed to ${newMultiplier}x',
                          style: baseTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      if (newBoostUntil != currentPlayer.pointBoostUntil)
                        Text(
                          '• Point boost will be ${newBoostUntil!.isAfter(DateTime.now()) ? 'active until ${DateFormat.jm().format(newBoostUntil!)}' : 'cleared'}',
                          style: baseTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      if (newSabotagedUntil != currentPlayer.sabotagedUntil)
                        Text(
                          '• Disable status will be ${newSabotagedUntil!.isAfter(DateTime.now()) ? 'active until ${DateFormat.jm().format(newSabotagedUntil!)}' : 'cleared'}',
                          style: baseTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      if (newSkips != currentPlayer.skips)
                        Text(
                          '• Skip tokens will be changed to $newSkips',
                          style: baseTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      if (teamNameController.text == currentPlayer.teamName &&
                          pointDifference == 0 &&
                          coinDifference == 0 &&
                          newMultiplier == currentPlayer.pointMultiplier &&
                          newBoostUntil == currentPlayer.pointBoostUntil &&
                          newSabotagedUntil == currentPlayer.sabotagedUntil &&
                          newSkips == currentPlayer.skips)
                        Text(
                          'No changes have been made.',
                          style: baseTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    buildDialogAction(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    buildDialogAction(
                      text: 'Save Changes',
                      onPressed: () {
                        // Build a list of changes for the message first
                        List<String> changes = [];
                        String originalName = currentPlayer.teamName;
                        int originalPoints = currentPlayer.points;
                        int originalCoins = currentPlayer.coinBalance;
                        double originalMultiplier =
                            currentPlayer.pointMultiplier;
                        DateTime originalBoostUntil =
                            currentPlayer.pointBoostUntil;
                        DateTime originalSabotagedUntil =
                            currentPlayer.sabotagedUntil;
                        int originalSkips = currentPlayer.skips;

                        // Team name
                        if (teamNameController.text != originalName) {
                          changes.add(
                              'team name from "$originalName" to "${teamNameController.text}"');
                        }

                        // Points
                        if (pointDifference != 0) {
                          changes.add(
                              'points from $originalPoints to ${originalPoints + pointDifference}');
                        }

                        // Coins
                        if (coinDifference != 0) {
                          changes.add(
                              'coins from $originalCoins to ${originalCoins + coinDifference}');
                        }

                        // Point Multiplier & Boost
                        bool multiplierChanged =
                            newMultiplier != originalMultiplier;
                        bool boostTimeChanged =
                            newBoostUntil != originalBoostUntil;

                        if (multiplierChanged || boostTimeChanged) {
                          if (newMultiplier == 1) {
                            changes.add('cleared point boost');
                          } else if (newBoostUntil!.isAfter(DateTime.now())) {
                            changes.add(
                                'point multiplier to ${newMultiplier}x until ${DateFormat.jm().format(newBoostUntil!)}');
                          } else if (originalBoostUntil
                              .isAfter(DateTime.now())) {
                            changes.add(
                                'cleared point boost (was ${originalMultiplier}x)');
                          }
                        }

                        // Disable Status
                        if (newSabotagedUntil != originalSabotagedUntil) {
                          if (newSabotagedUntil!.isAfter(DateTime.now())) {
                            changes.add(
                                'disabled until ${DateFormat.jm().format(newSabotagedUntil!)}');
                          } else if (originalSabotagedUntil
                              .isAfter(DateTime.now())) {
                            changes.add('removed disable status');
                          }
                        }

                        // Skip Tokens
                        if (newSkips != originalSkips) {
                          changes.add(
                              'skip tokens from $originalSkips to $newSkips');
                        }

                        // Only proceed if there are actual changes
                        if (changes.isNotEmpty) {
                          // Create the log message
                          cGame!.logMessages.add(
                            LogMessage(
                              message:
                                  'Host edited ${originalName}: ${changes.join("; ")}.',
                              uid: FirebaseAuth.instance.currentUser!.uid,
                              timestamp: DateTime.now(),
                              displayName: 'Game Update',
                            ),
                          );

                          // Now apply all the changes
                          currentPlayer.points += pointDifference;
                          currentPlayer.coinBalance += coinDifference;
                          currentPlayer.teamName = teamNameController.text;
                          currentPlayer.pointMultiplier = newMultiplier;
                          if (newMultiplier == 1) {
                            currentPlayer.pointBoostUntil = DateTime.now();
                          } else {
                            currentPlayer.pointBoostUntil = newBoostUntil!;
                            currentPlayer.pointBoostAt = DateTime.now();
                          }
                          currentPlayer.sabotagedUntil = newSabotagedUntil!;
                          currentPlayer.sabotagedAt = DateTime.now();
                          currentPlayer.skips = newSkips!;

                          updateGame(cGame!);
                        }

                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Close screen
                      },
                      isPrimary: true,
                    ),
                  ],
                );
              },
              child: Text(
                'Save Changes',
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAdjustmentTile(
    String label,
    int baseValue,
    int difference,
    Function(int change) onAdjust,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.all(20),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      title: Text(
        label,
        style: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Current: ${baseValue + difference}${difference != 0 ? ' (was: $baseValue)' : ''}',
        style: baseTextStyle.copyWith(
          fontSize: 14,
          color: difference != 0 ? Colors.yellow : Colors.white70,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.minus, size: 16),
            onPressed: () => onAdjust(-1),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
            onPressed: () => onAdjust(1),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
