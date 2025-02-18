import 'dart:ui';
import 'package:avatar_brick/avatar_brick.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:intl/intl.dart';

import '../info/game_info.dart';
import '../main.dart';
import '../models/app_user.dart';
import '../models/game.dart';
import '../models/game_template.dart';
import '../utils/live_activities.dart';
import '../utils/theme_data.dart';
import '../utils/toastification_helper.dart';
import 'auth/auth_page.dart';
import 'claimrush_ingame/warning.dart';
import 'create/ai_generate.dart';
import 'create/claimzone_1.dart';
import 'create/claimzone_view.dart';
import 'create/create_game.dart';

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
    // Token update will be handled after fetching currentUser
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
      ToastificationHelper.showErrorToast(
          context, 'Error updating token: ${e.toString()}');
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
              Colors.green.shade900.withOpacity(0.3),
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
                      'ClaimRush',
                      style: baseTextStyle.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.user,
                          color: Colors.white70),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => _buildProfileDialog(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Join Game',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Enter a 6-digit code to join an existing game',
                    style: baseTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Pinput(
                          length: 6,
                          defaultPinTheme: PinTheme(
                            width: 50,
                            height: 50,
                            textStyle: baseTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 50,
                            height: 50,
                            textStyle: baseTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade400),
                            ),
                          ),
                          submittedPinTheme: PinTheme(
                            width: 50,
                            height: 50,
                            textStyle: baseTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          onCompleted: (pin) async {
                            await _handleGameJoin(pin);
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: baseTextStyle.copyWith(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Create New Game',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Start a new game from scratch or use AI to generate one',
                    style: baseTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _showCreateGameOptions();
                    },
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
                              FontAwesomeIcons.plus,
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create a New Game',
                                style: baseTextStyle.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Start from scratch or use AI to generate',
                                style: baseTextStyle.copyWith(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  Text(
                    'Game Types',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Learn more about the different types of games',
                    style: baseTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 16),
                  _buildGameTypes()
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  _buildYourGames()
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTypes() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.mapLocationDot,
              color: Colors.blue,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'ClaimRush',
          style: baseTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Explore game details and how to play',
          style: baseTextStyle.copyWith(
            color: Colors.white70,
          ),
        ),
        trailing:
            const FaIcon(FontAwesomeIcons.angleRight, color: Colors.white70),
        onTap: () {
          Get.to(() => const GameInfo());
        },
      ),
    );
  }

  Widget _buildYourGames() {
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
                  ...snapshot.data!
                      .map((game) => Column(
                            children: [
                              _buildGameCard(game),
                              if (game != snapshot.data!.last)
                                Divider(
                                  color: Colors.white.withOpacity(0.1),
                                  height: 1,
                                ),
                            ],
                          ))
                      .toList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameCard(GameTemplate game) {
    return ListTile(
      contentPadding: const EdgeInsets.all(20),
      leading: _buildGameIcon(game.gameType),
      title: Text(
        game.gameName,
        style: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Created ${DateFormat.yMMMd().format(game.createdAt)}',
        style: baseTextStyle.copyWith(
          color: Colors.white70,
        ),
      ),
      trailing:
          const FaIcon(FontAwesomeIcons.angleRight, color: Colors.white70),
      onTap: () {
        gameTemplate = game;
        Get.to(() => const ClaimZoneView());
      },
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: FaIcon(
          iconData,
          color: iconColor,
          size: 20,
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

  Widget _buildProfileDialog() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.green.shade900.withOpacity(0.3),
              Colors.black,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: AvatarBrick(
                radius: 40,
                name: '${currentUser?.firstName} ${currentUser?.lastName}',
                backgroundColor: Colors.green,
                nameTextColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "${currentUser?.firstName} ${currentUser?.lastName}",
                style: baseTextStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 500.ms),
            ),
            Center(
              child: Text(
                '@${currentUser?.displayName}',
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ).animate().fadeIn(duration: 500.ms),
            ),
            const SizedBox(height: 32),
            Text(
              'User ID',
              style: baseTextStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: TextEditingController(text: currentUser?.uid ?? ''),
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: currentUser?.uid ?? ''));
                    ToastificationHelper.showSuccessToast(
                        context, 'User ID copied to clipboard');
                  },
                  icon: const FaIcon(FontAwesomeIcons.copy,
                      color: Colors.white70, size: 16),
                ),
              ),
              style: baseTextStyle.copyWith(color: Colors.white),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),
            Text(
              'Email',
              style: baseTextStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: TextEditingController(text: currentUser?.email ?? ''),
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: currentUser?.email ?? ''));
                    ToastificationHelper.showSuccessToast(
                        context, 'Email copied to clipboard');
                  },
                  icon: const FaIcon(FontAwesomeIcons.copy,
                      color: Colors.white70, size: 16),
                ),
              ),
              style: baseTextStyle.copyWith(color: Colors.white),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),
            Text(
              'Username',
              style: baseTextStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade400),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: baseTextStyle.copyWith(color: Colors.white),
              maxLength: 20,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              onChanged: (value) {
                usernameController.text = usernameController.text
                    .replaceAll(RegExp(r'\s+'), '')
                    .toLowerCase()
                    .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                usernameController.selection = TextSelection.fromPosition(
                    TextPosition(offset: usernameController.text.length));
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                if (currentUser != null) {
                  currentUser!.displayName = usernameController.text;
                  updateAppUser(currentUser!);
                }
              },
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Get.offAll(() => const AuthPage());
              },
              child: Text(
                FirebaseAuth.instance.currentUser!.isAnonymous
                    ? 'DELETE ACCOUNT'
                    : 'SIGN OUT',
                style: baseTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  void _showCreateGameOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
                left: BorderSide(color: Colors.white.withOpacity(0.1)),
                right: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Game',
                        style: baseTextStyle.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Get.to(() => const CreateGamePage());
                        },
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
                                  size: 20,
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Design your game from scratch',
                                    style: baseTextStyle.copyWith(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Get.to(() => const AIGenerate());
                        },
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
                                  size: 20,
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Let AI create a game for you',
                                    style: baseTextStyle.copyWith(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
