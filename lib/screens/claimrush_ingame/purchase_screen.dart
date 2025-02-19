import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import '../../models/game.dart';
import '../../models/game_template.dart';
import '../../utils/theme_data.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

Game? cGame;
String itemID = '';

class _PurchaseScreenState extends State<PurchaseScreen> {
  String value = '';

  @override
  Widget build(BuildContext context) {
    CoinShopItem item = cGame!.game.coinShopItems!
        .firstWhere((element) => element.itemId == itemID);

    Player player = cGame!.players.firstWhere(
      (element) => element.playerId == FirebaseAuth.instance.currentUser!.uid,
    );

    value = cGame!.players
            .firstWhereOrNull(
              (element) =>
                  element.playerId != FirebaseAuth.instance.currentUser!.uid,
            )
            ?.playerId ??
        '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Purchase Item'),
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildItemHeader(item),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildItemDescription(item),
                ),
                if (item.itemType == 'disabler') ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Select the team you want to disable:',
                      style: baseTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  _buildTeamSelection(player),
                ],
                const Divider(
                  color: Colors.white54,
                  thickness: 1,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildConfirmation(item, player),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildPurchaseButton(item, player),
        ],
      ),
    );
  }

  Widget _buildItemHeader(CoinShopItem item) {
    Color backgroundColor;
    IconData icon;

    switch (item.itemType) {
      case 'disabler':
        backgroundColor = Colors.red;
        icon = FontAwesomeIcons.ban;
        break;
      case 'booster':
        backgroundColor = Colors.green;
        icon = FontAwesomeIcons.gem;
        break;
      case 'coin':
        backgroundColor = Colors.blue;
        icon = FontAwesomeIcons.coins;
        break;
      case 'skip':
        backgroundColor = Colors.purple;
        icon = FontAwesomeIcons.forward;
        break;
      default:
        backgroundColor = Colors.grey;
        icon = FontAwesomeIcons.question;
        break;
    }

    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Text(
            item.itemName,
            style: baseTextStyle.copyWith(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDescription(CoinShopItem item) {
    String description;

    switch (item.itemType) {
      case 'disabler':
        description =
            'With this item, you can disable a team\'s claiming ability for ${item.duration} minutes.';
        break;
      case 'coin':
        description =
            'With this item, you can exchange ${item.itemPrice} coins for ${item.pointsPerCoin! * item.itemPrice} points.';
        break;
      case 'booster':
        description =
            'With this item, all claims will be worth ${item.multiplier}x points for ${item.duration} minutes.';
        break;
      case 'skip':
        description =
            'With this item, you can claim one location without completing its task.';
        break;
      default:
        description = 'No description available.';
        break;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        description,
        style: baseTextStyle,
      ),
    );
  }

  Widget _buildTeamSelection(Player player) {
    return Column(
      children: cGame!.players.map((team) {
        return RadioListTile(
          value: team.playerId,
          groupValue: value,
          onChanged: team.playerId != player.playerId
              ? (String? value) {
                  setState(() {
                    this.value = value!;
                  });
                }
              : null,
          title: Text(
            team.teamName,
            style: baseTextStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmation(CoinShopItem item, Player player) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const FaIcon(FontAwesomeIcons.coins),
      title: Text(
        'Are you sure you want to purchase ${item.itemName} for ${item.itemPrice} coins?',
        style: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'You will have ${player.coinBalance - item.itemPrice} coins remaining.',
        style: baseTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Get.isDarkMode ? Colors.white54 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(CoinShopItem item, Player player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: item.itemType == 'disabler' && value.isEmpty
            ? null
            : () {
                _handlePurchase(item, player);
              },
        child: Text(
          'Purchase',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handlePurchase(CoinShopItem item, Player player) {
    if (item.itemType == 'disabler') {
      _disableTeam(item, player);
    } else if (item.itemType == 'coin') {
      _exchangeCoinsForPoints(item, player);
    } else if (item.itemType == 'booster') {
      _applyBooster(item, player);
    } else if (item.itemType == 'skip') {
      _applySkip(item, player);
    }
    Navigator.pop(context);
    setState(() {});
  }

  void _disableTeam(CoinShopItem item, Player player) async {
    HapticFeedback.mediumImpact();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Center ban icon
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, double value, child) {
              return Center(
                child: Transform.scale(
                  scale: 1 + (1 - value),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.ban,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Expanding ring effect
          ...List.generate(3, (index) {
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 1500 + (index * 200)),
              builder: (context, double value, child) {
                return Center(
                  child: Transform.scale(
                    scale: value * 2,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity((1 - value) * 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    await Future.delayed(const Duration(milliseconds: 2000));
    overlayEntry.remove();

    player.coinBalance -= item.itemPrice;
    Player targetPlayer =
        cGame!.players.firstWhere((element) => element.playerId == value);
    targetPlayer.sabotagedUntil =
        DateTime.now().add(Duration(minutes: item.duration!));
    targetPlayer.sabotagedAt = DateTime.now();
    _logPurchase(player,
        'disabled ${targetPlayer.teamName} for ${item.duration} minutes.');
    updateGame(cGame!);
  }

  void _exchangeCoinsForPoints(CoinShopItem item, Player player) async {
    HapticFeedback.mediumImpact();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          for (var i = 0; i < 3; i++)
            for (var j = 0; j < 3; j++)
              TweenAnimationBuilder(
                tween: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ),
                duration: Duration(milliseconds: 1500 + ((i + j) * 200)),
                curve: Curves.easeInOut,
                builder: (context, double value, child) {
                  return Positioned(
                    left:
                        MediaQuery.of(context).size.width * (0.25 + (j * 0.25)),
                    top: MediaQuery.of(context).size.height *
                            (0.3 + (i * 0.15)) -
                        (value * 300),
                    child: Opacity(
                      opacity: 1 - value,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.coins,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    await Future.delayed(const Duration(milliseconds: 2500));
    overlayEntry.remove();

    player.coinBalance -= item.itemPrice;
    player.points += item.pointsPerCoin! * item.itemPrice;
    _logPurchase(player,
        'purchased ${item.pointsPerCoin! * item.itemPrice} points for ${item.itemPrice} coins.');
    updateGame(cGame!);
  }

  void _applyBooster(CoinShopItem item, Player player) async {
    HapticFeedback.mediumImpact();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Center multiplier text
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, double value, child) {
              return Center(
                child: Text(
                  '${item.multiplier}x',
                  style: baseTextStyle.copyWith(
                    fontSize: 80 * value,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.withOpacity(1 - value),
                  ),
                ),
              );
            },
          ),
          // Starburst rays
          ...List.generate(8, (index) {
            final angle = (index * pi / 4);
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 1200 + (index * 100)),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Center(
                  child: Transform.rotate(
                    angle: angle,
                    child: Opacity(
                      opacity: (1 - value) * 0.8,
                      child: Container(
                        height: 200 * value,
                        width: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.green.withOpacity(0),
                              Colors.green.withOpacity(0.5),
                              Colors.green.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Floating gems
          ...List.generate(6, (index) {
            final radius = 100.0;
            final angle = (index * pi / 3);
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 800 + (index * 150)),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Center(
                  child: Transform.translate(
                    offset: Offset(
                      cos(angle) * radius * value,
                      sin(angle) * radius * value,
                    ),
                    child: Transform.rotate(
                      angle: value * pi * 2,
                      child: Opacity(
                        opacity: (1 - value),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.gem,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    await Future.delayed(const Duration(milliseconds: 2000));
    overlayEntry.remove();

    player.coinBalance -= item.itemPrice;
    player.pointMultiplier = item.multiplier!.toDouble();
    player.pointBoostUntil =
        DateTime.now().add(Duration(minutes: item.duration!));
    player.pointBoostAt = DateTime.now();
    _logPurchase(player,
        'purchased a ${item.multiplier}x point booster for ${item.duration} minutes.');
    updateGame(cGame!);
  }

  void _applySkip(CoinShopItem item, Player player) async {
    HapticFeedback.mediumImpact();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => TweenAnimationBuilder(
        tween: Tween<double>(
            begin: -100, end: MediaQuery.of(context).size.width + 100),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, double value, child) {
          return Positioned(
            left: value,
            top: MediaQuery.of(context).size.height / 2 - 40,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const FaIcon(
                FontAwesomeIcons.forward,
                color: Colors.purple,
                size: 40,
              ),
            ),
          );
        },
        onEnd: () {
          overlayEntry.remove();
          player.coinBalance -= item.itemPrice;
          player.skips++;
          _logPurchase(player, 'purchased a task skip.');
          updateGame(cGame!);
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  void _logPurchase(Player player, String action) {
    cGame!.logMessages.add(
      LogMessage(
        displayName: 'Booster Purchased',
        message: '${player.teamName} has $action',
        timestamp: DateTime.now(),
        uid: FirebaseAuth.instance.currentUser!.uid,
      ),
    );
  }
}
