import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/screens/create/claimzone_1.dart';
import 'package:scavhuntapp/screens/home_screen.dart';

import '../../utils/theme_data.dart';

class ClaimZone6 extends StatefulWidget {
  const ClaimZone6({super.key});

  @override
  State<ClaimZone6> createState() => _ClaimZone6State();
}

class _ClaimZone6State extends State<ClaimZone6> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finish'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'That\'s it!',
              style: baseTextStyle.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve successfully created a game. Your game can be found in the "My Games" section of the app. You can edit it at any time.',
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
              'What\'s next?',
              style: baseTextStyle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _buildListTile(
              icon: FontAwesomeIcons.coins,
              title: 'Add a Coin Shop',
              subtitle:
                  'So far, coins are not used in your game. Add a coin shop to allow players to buy coins.',
            ),
            _buildListTile(
              icon: FontAwesomeIcons.locationDot,
              title: 'Share your game',
              subtitle:
                  'Share your game with friends and family so they can play.',
            ),
            _buildGameSummaryCard(),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Get.offAll(() => const HomeScreen());
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: FaIcon(icon),
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle, style: baseTextStyle),
    );
  }

  Widget _buildGameSummaryCard() {
    return Card(
      child: ListTile(
        leading: const FaIcon(FontAwesomeIcons.trophy),
        title: Text(
          'Game Summary',
          style: baseTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGameSummaryRow(
              icon: FontAwesomeIcons.envelopeOpenText,
              label: 'Game Name',
              value: gameTemplate.gameName,
            ),
            _buildGameSummaryRow(
              icon: FontAwesomeIcons.hashtag,
              label: 'Number of Zones',
              value: gameTemplate.zones!.length.toString(),
            ),
            _buildGameSummaryRow(
              icon: FontAwesomeIcons.award,
              label: 'Total Points',
              value: gameTemplate.zones!
                  .fold<int>(
                      0,
                      (previousValue, element) =>
                          previousValue + element.points)
                  .toString(),
            ),
            _buildGameSummaryRow(
              icon: FontAwesomeIcons.coins,
              label: 'Total Coins',
              value: gameTemplate.zones!
                  .fold<int>(0,
                      (previousValue, element) => previousValue + element.coins)
                  .toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FaIcon(icon, size: 12),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: baseTextStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
