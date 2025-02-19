import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../info/game_info.dart';
import '../main.dart';
import '../models/app_user.dart';
import '../models/game.dart';
import '../models/game_template.dart';
import '../utils/game_utils.dart';
import '../utils/live_activities.dart';
import '../utils/theme_data.dart';
import '../utils/toastification_helper.dart';
import 'claimrush_ingame/warning.dart';
import 'create/ai_generate.dart';
import 'create/claimzone_1.dart';
import 'create/claimzone_view.dart';
import 'create/create_game.dart';
import 'profile/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

AppUser? currentUser;

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final DynamicIslandManager diManager =
      DynamicIslandManager(channelKey: 'DI'); // Ensure this is properly defined

  @override
  void initState() {
    super.initState();
    diManager.stopLiveActivity();
    _initializeUser();
  }

  void _initializeUser() async {
    if (currentUser == null) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        currentUser = await getUser(uid);
        if (mounted) setState(() {});
      }
    }
    updateFCMToken();
  }

  void updateFCMToken() async {
    try {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (currentUser != null) {
        if (currentUser!.apnsToken != apnsToken ||
            currentUser!.fcmToken != fcmToken) {
          currentUser!.apnsToken = apnsToken;
          currentUser!.fcmToken = fcmToken;
          updateAppUser(currentUser!);
          print('Updated FCM token');
        }
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.green.shade900.withOpacity(0.2),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Huntopia',
                      style: baseTextStyle.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.user,
                          color: Colors.white70),
                      onPressed: () => Get.to(() => const ProfilePage()),
                    ).animate().fadeIn(duration: 300.ms),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildJoinGame(),
                  const SizedBox(height: 24),
                  _buildCreateGame(),
                  const SizedBox(height: 12),
                  _buildActiveGenerationMessage(),
                  const SizedBox(height: 24),
                  _buildYourGames(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinGame() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join Game',
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter a 6-letter code to join',
                style: baseTextStyle.copyWith(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        SizedBox(
          width: 220,
          child: Pinput(
            length: 6,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            defaultPinTheme: PinTheme(
              width: 34,
              height: 42,
              textStyle: baseTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 34,
              height: 42,
              textStyle: baseTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade400),
              ),
            ),
            submittedPinTheme: PinTheme(
              width: 34,
              height: 42,
              textStyle: baseTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            onCompleted: (pin) async {
              await _handleGameJoin(pin);
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildCreateGame() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showCreateGameDialog(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.plus,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Game',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Start from scratch or use AI',
                        style: baseTextStyle.copyWith(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                const FaIcon(FontAwesomeIcons.angleRight,
                    color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildActiveGenerationMessage() {
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('aiGameRequests')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('status', whereIn: ['pending', 'processing'])
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Generation in Progress',
                      style: baseTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Check AI Creator for status',
                      style: baseTextStyle.copyWith(
                        fontSize: 13,
                        color: Colors.blue.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms);
      },
    );
  }

  Widget _buildYourGames() {
    if (currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    return StreamBuilder<List<GameTemplate>>(
      stream: getUserGameTemplates(currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (snapshot.data!.isEmpty) {
          return Text(
            'You have no games yet.',
            style: baseTextStyle.copyWith(color: Colors.white70),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Games',
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
                  ...snapshot.data!.map((game) => Column(
                        children: [
                          _buildGameCard(game),
                          if (game != snapshot.data!.last)
                            Divider(
                              color: Colors.white.withOpacity(0.1),
                              height: 1,
                            ),
                        ],
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildGameCard(GameTemplate game) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          gameTemplate = game;
          Get.to(() => const ClaimZoneView());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildGameIcon(game.gameType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.gameName,
                      style: baseTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Created ${DateFormat.MMMd().format(game.createdAt)}',
                      style: baseTextStyle.copyWith(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const FaIcon(FontAwesomeIcons.angleRight,
                  color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameIcon(String gameType) {
    IconData iconData;
    Color iconColor;

    if (gameType == 'claimthezone') {
      iconData = FontAwesomeIcons.mapLocationDot;
      iconColor = Colors.green;
    } else if (gameType == 'photohunt') {
      iconData = FontAwesomeIcons.camera;
      iconColor = Colors.blue;
    } else {
      iconData = FontAwesomeIcons.personRunning;
      iconColor = Colors.orange;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: FaIcon(
          iconData,
          color: iconColor,
          size: 16,
        ),
      ),
    );
  }

  Future<void> _handleGameJoin(String pin) async {
    final game = await getGame(pin);
    if (game == null) {
      ToastificationHelper.showErrorToast(context, 'Game not found');
    } else if (game.players.length >= game.maxTeams) {
      ToastificationHelper.showErrorToast(context, 'Game is full');
    } else if (game.players
        .any((element) => element.playerId == currentUser!.uid)) {
      ToastificationHelper.showErrorToast(context, 'Already in game');
    } else if (game.gameStatus != 'pending') {
      ToastificationHelper.showErrorToast(context, 'Game has already started');
    } else {
      // Add the user to the game
      List<String> colors = [
        'red',
        'blue',
        'green',
        'yellow',
        'purple',
        'orange',
        'pink',
        'indigo',
        'lime',
        'brown',
        'deepOrange',
        'deepPurple'
      ];
      String selectedColor = colors.firstWhere(
          (color) => !game.players.any((element) => element.teamColor == color),
          orElse: () => 'grey'); // Default to grey if all colors are taken

      game.players.add(
        Player(
          playerId: currentUser!.uid,
          teamName: 'Team ${currentUser!.displayName}',
          teamColor: selectedColor,
          points: 0,
          coinBalance: 0,
          sabotagedUntil: DateTime.now().subtract(const Duration(seconds: 1)),
          pointBoostUntil: DateTime.now().subtract(const Duration(seconds: 1)),
          sabotagedAt: DateTime.now(),
          pointBoostAt: DateTime.now(),
          pointMultiplier: 1,
          zonesClaimed: [],
          skips: 0,
          fcmToken: currentUser!.fcmToken ?? '',
          location: null,
        ),
      );
      updateGame(game);
      // Save the current game ID and navigate to the warning page
      prefs.setString('currentGameId', game.gameId);
      Get.offAll(() => const WarningPage());
    }
  }

  void _showCreateGameDialog() {
    showStandardDialog(
      context: context,
      title: 'Create New Game',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const CreateGamePage());
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.pencil,
                          color: Colors.green,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Manually',
                            style: baseTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Design your game from scratch',
                            style: baseTextStyle.copyWith(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const AIGenerate());
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.wandMagicSparkles,
                          color: Colors.purple,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generate with AI',
                            style: baseTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Let AI create a game for you',
                            style: baseTextStyle.copyWith(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
