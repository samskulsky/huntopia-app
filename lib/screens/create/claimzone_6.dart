import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/widgets/gradient_background.dart';

import '../../utils/theme_data.dart';
import 'claimzone_1.dart';
import '../home_screen.dart';

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
        title: Text(
          'Finish',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Text(
                  'That\'s it! ',
                  style: baseTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text('🎉', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ve successfully created a game. Your game can be found in the "My Games" section of the app. You can edit it at any time.',
              style: baseTextStyle.copyWith(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'What\'s next?',
              style: baseTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildActionTile(
                    icon: FontAwesomeIcons.coins,
                    title: 'Add a Coin Shop',
                    subtitle:
                        'So far, coins are not used in your game. Add a coin shop to allow players to buy coins.',
                    onTap: () {},
                    isFirst: true,
                  ),
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  _buildActionTile(
                    icon: FontAwesomeIcons.shareNodes,
                    title: 'Share your game',
                    subtitle:
                        'Share your game with friends and family so they can play.',
                    onTap: () {},
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Game Summary',
              style: baseTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSummaryRow(
                    icon: FontAwesomeIcons.gamepad,
                    label: 'Game Name',
                    value: gameTemplate.gameName,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    icon: FontAwesomeIcons.locationDot,
                    label: 'Number of Zones',
                    value: gameTemplate.zones!.length.toString(),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    icon: FontAwesomeIcons.trophy,
                    label: 'Total Points',
                    value: gameTemplate.zones!
                        .fold<int>(0, (prev, zone) => prev + zone.points)
                        .toString(),
                    valueColor: Colors.green.shade400,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    icon: FontAwesomeIcons.coins,
                    label: 'Total Coins',
                    value: gameTemplate.zones!
                        .fold<int>(0, (prev, zone) => prev + zone.coins)
                        .toString(),
                    valueColor: Colors.purple.shade400,
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
                onPressed: () => Get.offAll(() => const HomeScreen()),
                child: Text(
                  'Back to Home',
                  style: baseTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: ListTile(
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
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: baseTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: baseTextStyle.copyWith(
              color: Colors.white70,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FaIcon(
              icon,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ),
        Text(
          value,
          style: baseTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
