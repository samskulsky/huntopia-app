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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cannot Claim',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Zone Unavailable',
            style: baseTextStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            !disabled
                ? 'This zone has already been claimed by another team.'
                : 'Your team is currently disabled and cannot claim any zones.',
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'What This Means',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                ListTile(
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
                        !disabled
                            ? FontAwesomeIcons.flag
                            : FontAwesomeIcons.ban,
                        color: !disabled ? Colors.blue : Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    !disabled ? 'Already Claimed' : 'Team Disabled',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    !disabled
                        ? 'Each zone can only be claimed once during the game. Try finding an unclaimed zone!'
                        : 'Your team has been temporarily disabled. Wait until the disable period ends to continue claiming zones.',
                    style: baseTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
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
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Got It',
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
