import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/theme_data.dart';

class CantClaim extends StatefulWidget {
  const CantClaim({super.key});

  @override
  State<CantClaim> createState() => _CantClaimState();
}

bool disabled = false;

class _CantClaimState extends State<CantClaim> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cannot Claim'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const FaIcon(
                  FontAwesomeIcons.solidCircleXmark,
                  size: 40,
                  color: Colors.red,
                ),
                Text(
                  'Cannot Claim',
                  style: baseTextStyle.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              !disabled
                  ? 'This zone has already been claimed.'
                  : 'Your team is disabled and cannot claim any zones at the moment.',
              style: baseTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
