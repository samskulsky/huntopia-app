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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          edit = false;
          Get.to(() => const AddZone());
        },
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
      appBar: AppBar(
        title: const Text('My Zones'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(child: _buildZoneList()),
            _buildContinueButton(),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Zones (${gameTemplate.zones?.length ?? '0'})',
          style: baseTextStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add the zones you want players to visit to claim them. You can change and add more zones later.',
          style: baseTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Get.isDarkMode ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildZoneList() {
    if (gameTemplate.zones == null || gameTemplate.zones!.isEmpty) {
      return Center(
        child: Text(
          'No zones added yet. Please add at least 3 zones to continue.',
          style: baseTextStyle.copyWith(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: gameTemplate.zones!.length,
      itemBuilder: (context, index) {
        final zone = gameTemplate.zones![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            child: ListTile(
              onTap: () {
                edit = true;
                fromInfoPage = true;
                currentZoneId = zone.zoneId;
                Get.to(() => const AddZone());
              },
              leading: const FaIcon(FontAwesomeIcons.locationDot),
              title: Text(
                zone.zoneName,
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                _getTaskDescription(zone.taskType),
                style: baseTextStyle.copyWith(
                  fontSize: 16,
                ),
              ),
              trailing: _buildZoneInfoChip(zone),
            ),
          ),
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

    return FilledButton(
      onPressed: canContinue
          ? () {
              fromInfoPage = false;
              Get.to(() => const ClaimZone5());
            }
          : null,
      child: const Text('Continue'),
    );
  }
}
