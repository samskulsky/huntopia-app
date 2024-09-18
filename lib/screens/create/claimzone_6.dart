import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/theme_data.dart';
import 'claimzone_1.dart';
import 'claimzone_addzone.dart';
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
        title: const Text('Finish', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGlassCard(
            title: '',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'That\'s it!',
                  style: baseTextStyle.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ve successfully created a game. Your game can be found in the "My Games" section of the app. You can edit it at any time.',
                  style: baseTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white54),
                const SizedBox(height: 16),
                Text(
                  'What\'s next?',
                  style: baseTextStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
                  icon: FontAwesomeIcons.shareNodes,
                  title: 'Share your game',
                  subtitle:
                      'Share your game with friends and family so they can play.',
                ),
                const SizedBox(height: 16),
                _buildGameSummaryCard(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildGlassCard(
            title: '',
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.offAll(() => const HomeScreen());
                },
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: FaIcon(icon, color: Colors.white),
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: baseTextStyle.copyWith(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
      onTap: () {
        if (title == 'Add a Coin Shop') {
          Get.to(() => const AddZone());
        } else if (title == 'Share your game') {
          // Implement share functionality or navigate to share screen
        }
      },
    );
  }

  Widget _buildGameSummaryCard() {
    return _buildGlassCard(
      title: '',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const FaIcon(FontAwesomeIcons.trophy, color: Colors.white),
        title: Text(
          'Game Summary',
          style: baseTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              FaIcon(icon, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: baseTextStyle.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: baseTextStyle.copyWith(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildGlassCard({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    ),
  );
}
