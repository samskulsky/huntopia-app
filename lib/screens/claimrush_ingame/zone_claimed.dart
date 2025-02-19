import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/claim_zone.dart';
import 'dart:math';

import '../../utils/theme_data.dart';

class ZoneClaimed extends StatefulWidget {
  const ZoneClaimed({super.key});

  @override
  State<ZoneClaimed> createState() => _ZoneClaimedState();
}

String iUrl = '';

class _ZoneClaimedState extends State<ZoneClaimed> {
  bool _hasPlayedAnimation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasPlayedAnimation) {
        _hasPlayedAnimation = true;
        _playCelebrationAnimation();
      }
    });
  }

  void _playCelebrationAnimation() {
    HapticFeedback.mediumImpact();

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // Expanding circle wave (slower and more waves)
            ...List.generate(5, (index) {
              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 2000 + (index * 300)),
                curve: Curves.easeOut,
                builder: (context, double value, child) {
                  return Center(
                    child: Transform.scale(
                      scale: value * 3,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.withOpacity((1 - value) * 0.3),
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            // Floating points text (slower fade)
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Center(
                  child: Transform.translate(
                    offset: Offset(0, -150 * value),
                    child: Opacity(
                      opacity: 1 - (value * 0.7),
                      child: Text(
                        '+${currentZone!.points}',
                        style: baseTextStyle.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Confetti particles (more particles, longer duration)
            ...List.generate(30, (index) {
              final random = Random();
              final startX = MediaQuery.of(context).size.width / 2;
              final startY = MediaQuery.of(context).size.height / 2;
              final angle = random.nextDouble() * 2 * pi;
              final velocity = 250.0 + random.nextDouble() * 200;
              final size = 8.0 + random.nextDouble() * 8;

              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 1500 + random.nextInt(1000)),
                curve: Curves.easeOut,
                builder: (context, double value, child) {
                  final dx = cos(angle) * velocity * value;
                  final dy =
                      sin(angle) * velocity * value - (400 * value * value);

                  return Positioned(
                    left: startX + dx,
                    top: startY + dy,
                    child: Transform.rotate(
                      angle: value * 4 * pi,
                      child: Opacity(
                        opacity: (1 - value * 0.7),
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: [
                              Colors.green,
                              Colors.white,
                              Colors.yellow
                            ][random.nextInt(3)],
                            shape: random.nextBool()
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 3500), () {
      overlayEntry.remove();
    });
  }

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
