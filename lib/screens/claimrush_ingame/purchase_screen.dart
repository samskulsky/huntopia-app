import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemHeader(item),
          const SizedBox(height: 16),
          _buildItemDescription(item),
          if (item.itemType == 'disabler') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          const SizedBox(height: 16),
          _buildConfirmation(item, player),
          const SizedBox(height: 16),
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
      title: Text(description, style: baseTextStyle),
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
      leading: const FaIcon(FontAwesomeIcons.coins),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: FilledButton(
        onPressed: item.itemType == 'disabler' && value.isEmpty
            ? null
            : () {
                _handlePurchase(item, player);
              },
        child: const Text('Purchase'),
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

  void _disableTeam(CoinShopItem item, Player player) {
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

  void _exchangeCoinsForPoints(CoinShopItem item, Player player) {
    player.coinBalance -= item.itemPrice;
    player.points += item.pointsPerCoin! * item.itemPrice;
    _logPurchase(player,
        'purchased ${item.itemPrice} coins for ${item.pointsPerCoin! * item.itemPrice} points.');
    updateGame(cGame!);
  }

  void _applyBooster(CoinShopItem item, Player player) {
    player.coinBalance -= item.itemPrice;
    player.pointMultiplier = item.multiplier!.toDouble();
    player.pointBoostUntil =
        DateTime.now().add(Duration(minutes: item.duration!));
    player.pointBoostAt = DateTime.now();
    _logPurchase(player,
        'purchased a ${item.multiplier}x point booster for ${item.duration} minutes.');
    updateGame(cGame!);
  }

  void _applySkip(CoinShopItem item, Player player) {
    player.coinBalance -= item.itemPrice;
    player.skips++;
    _logPurchase(player, 'purchased a task skip.');
    updateGame(cGame!);
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
