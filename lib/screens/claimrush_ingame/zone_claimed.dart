import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/claim_zone.dart';

import '../../utils/theme_data.dart';

class ZoneClaimed extends StatefulWidget {
  const ZoneClaimed({super.key});

  @override
  State<ZoneClaimed> createState() => _ZoneClaimedState();
}

String iUrl = '';

class _ZoneClaimedState extends State<ZoneClaimed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zone Claimed'),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iUrl.isNotEmpty) _buildImagePreview(),
            if (iUrl.isNotEmpty) const SizedBox(height: 16),
            _buildZoneClaimedHeader(),
            const SizedBox(height: 16),
            _buildClaimDetails(),
            const SizedBox(height: 16),
            _buildScoreRow('New Score', curPlayer!.points.toString()),
            _buildScoreRow('Coin Balance', curPlayer!.coinBalance.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(iUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildZoneClaimedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const FaIcon(
          FontAwesomeIcons.solidCircleCheck,
          size: 40,
          color: Colors.green,
        ),
        Text(
          'Zone Claimed',
          style: baseTextStyle.copyWith(
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildClaimDetails() {
    return Text(
      'Your team has claimed ${currentZone!.zoneName}. You have earned ${currentZone!.points} points and ${currentZone!.coins} coins.',
      style: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: baseTextStyle.copyWith(fontSize: 20)),
        Text(
          value,
          style: baseTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
