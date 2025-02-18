import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/screens/home_screen.dart';
import 'package:scavhuntapp/widgets/gradient_background.dart';

import '../../utils/theme_data.dart';
import 'setup_2.dart';

class SetupPage5 extends StatefulWidget {
  const SetupPage5({super.key});

  @override
  State<SetupPage5> createState() => _SetupPage5State();
}

class _SetupPage5State extends State<SetupPage5> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'All Set!',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'That\'s it! 🎉',
                style: baseTextStyle.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 12),
              Text(
                'You\'re all set up and ready to go! Tap the button below to start using the app.',
                style: baseTextStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              if (appUser.tokens > 0) ...[
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(121, 167, 229, 10),
                        Color.fromARGB(121, 3, 223, 84)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child:
                            FaIcon(FontAwesomeIcons.robot, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      'Create a Game with AI',
                      style: baseTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'We added ${appUser.tokens} AI token${appUser.tokens != 1 ? 's' : ''} to your account for free! Each token can be used to generate a full scavenger hunt with AI.',
                      style: baseTextStyle.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Get.offAll(() => const HomeScreen()),
                  child: Text(
                    'Get Started',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      title: Text(title, style: baseTextStyle.copyWith(fontSize: 18)),
      subtitle: Text(subtitle),
      leading: FaIcon(icon),
    );
  }
}
