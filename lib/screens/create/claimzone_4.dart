import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/widgets/gradient_background.dart';

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
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ClaimRush',
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'My Zones (${gameTemplate.zones?.length ?? '0'})',
                    style: baseTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add the zones you want players to visit to claim them. You can change and add more zones later.',
                    style: baseTextStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildZoneList(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneList() {
    if (gameTemplate.zones == null || gameTemplate.zones!.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const FaIcon(
                FontAwesomeIcons.locationDot,
                color: Colors.white70,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No zones added yet',
              style: baseTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please add at least 3 zones to continue',
              style: baseTextStyle.copyWith(
                fontSize: 16,
                color: Colors.white70,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gameTemplate.zones!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final zone = gameTemplate.zones![index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ListTile(
            onTap: () {
              edit = true;
              fromInfoPage = true;
              currentZoneId = zone.zoneId;
              Get.to(() => const AddZone());
            },
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                zone.zoneName,
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            subtitle: Text(
              _getTaskDescription(zone.taskType),
              style: baseTextStyle.copyWith(
                color: Colors.white70,
                height: 1.3,
              ),
            ),
            trailing: _buildZoneInfoChip(zone),
          ),
        );
      },
    );
  }

  Widget _buildZoneInfoChip(Zone zone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${zone.points}',
            style: baseTextStyle.copyWith(
              fontSize: 14,
              color: Colors.green.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          FaIcon(
            FontAwesomeIcons.trophy,
            size: 12,
            color: Colors.green.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            '${zone.coins}',
            style: baseTextStyle.copyWith(
              fontSize: 14,
              color: Colors.purple.shade300,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          FaIcon(
            FontAwesomeIcons.coins,
            size: 12,
            color: Colors.purple.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gameTemplate.zones != null &&
                              gameTemplate.zones!.length > 2
                          ? Colors.white
                          : Colors.white.withOpacity(0.1),
                      foregroundColor: gameTemplate.zones != null &&
                              gameTemplate.zones!.length > 2
                          ? Colors.black
                          : Colors.white38,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: gameTemplate.zones != null &&
                            gameTemplate.zones!.length > 2
                        ? () {
                            fromInfoPage = false;
                            Get.to(() => const ClaimZone5());
                          }
                        : null,
                    child: Text(
                      'Continue',
                      style: baseTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                width: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    edit = false;
                    Get.to(() => const AddZone());
                  },
                  child: const FaIcon(FontAwesomeIcons.plus),
                ),
              ),
            ],
          ),
        ),
      ),
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
}
