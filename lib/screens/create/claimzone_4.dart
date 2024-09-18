import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../models/game_template.dart';
import '../../utils/theme_data.dart';
import 'claimzone_1.dart';
import 'claimzone_5.dart';
import 'claimzone_addzone.dart';

class ClaimZone4 extends StatefulWidget {
  const ClaimZone4({super.key});

  @override
  State<ClaimZone4> createState() => _ClaimZone4State();
}

class _ClaimZone4State extends State<ClaimZone4> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Zones', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Zones (${gameTemplate.zones?.length ?? '0'})',
                  style: baseTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add the zones you want players to visit to claim them. You can change and add more zones later.',
                  style: baseTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildZoneList()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildContinueButton()),
                _buildPlusButton(),
              ],
            ),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneList() {
    if (gameTemplate.zones == null || gameTemplate.zones!.isEmpty) {
      return Center(
        child: _buildGlassCard(
          title: '',
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No zones added yet. Please add at least 3 zones to continue.',
              style: baseTextStyle.copyWith(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: gameTemplate.zones!.length,
      itemBuilder: (context, index) {
        final zone = gameTemplate.zones![index];
        return ListTile(
          onTap: () {
            edit = true;
            fromInfoPage = true;
            currentZoneId = zone.zoneId;
            Get.to(() => const AddZone());
          },
          leading:
              const FaIcon(FontAwesomeIcons.locationDot, color: Colors.white),
          title: Text(
            zone.zoneName,
            style: baseTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            _getTaskDescription(zone.taskType),
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          trailing: _buildZoneInfoChip(zone),
        );
      },
    );
  }

  String _getTaskDescription(String taskType) {
    switch (taskType) {
      case 'question':
        return 'Answer a question';
      case 'selfie':
        return 'Take a selfie';
      case 'qrcode':
        return 'Scan a QR code';
      default:
        return 'Unknown task';
    }
  }

  Widget _buildZoneInfoChip(Zone zone) {
    return Chip(
      padding: const EdgeInsets.all(0),
      backgroundColor: Colors.white,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${zone.points} ',
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.deepOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
          const FaIcon(
            FontAwesomeIcons.trophy,
            size: 14,
            color: Colors.deepOrange,
          ),
          const SizedBox(width: 4),
          Text(
            '${zone.coins} ',
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
          const FaIcon(
            FontAwesomeIcons.coins,
            size: 14,
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final canContinue =
        gameTemplate.zones != null && gameTemplate.zones!.length > 2;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: canContinue ? Colors.green : Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: canContinue
          ? () {
              fromInfoPage = false;
              Get.to(() => const ClaimZone5());
            }
          : null,
      child: Text(
        'Continue',
        style: baseTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPlusButton() {
    return IconButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {
        edit = false;
        Get.to(() => const AddZone());
      },
      icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
    );
  }

  Widget _buildGlassCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05)
          ],
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
}
