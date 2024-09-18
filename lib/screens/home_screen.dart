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
        currentUser!.apnsToken = apnsToken;
        currentUser!.fcmToken = fcmToken;
        updateAppUser(currentUser!);
      }
    } catch (e) {
      ToastificationHelper.showErrorToast(
          context, 'Error updating token: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: appUserStream(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData &&
            snapshot.data != null) {
          currentUser = snapshot.data!;
          usernameController.text = currentUser?.displayName ?? '';
          emailController.text = currentUser?.email ?? '';

          // Update FCM token after fetching user data
          if (currentUser!.fcmToken == null || currentUser!.apnsToken == null) {
            updateFCMToken();
          }

          // Handle banned users
          if (currentUser!.role == 'ban') {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your account has been disabled.',
                        style: baseTextStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This could be due to a violation of our terms of service. If you believe this is a mistake, please contact support.\n\nWe apologize for any inconvenience this may have caused.',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: _buildHeader(),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildJoinGame(),
                        _buildGameTypes(),
                        _buildYourGames(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: SpinKitFadingCube(color: Colors.green),
            ),
          );
        }
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        AvatarBrick(
          size: const Size(40, 40),
          backgroundColor: Colors.green,
          nameTextColor: Colors.white,
          name: '${currentUser?.firstName} ${currentUser?.lastName}',
          nameTextStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          radius: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Hello, ${currentUser?.firstName}!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.gear),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute<void>(
              fullscreenDialog: true,
              builder: (BuildContext context) {
                return _buildProfileDialog();
              },
            ));
          },
        ),
      ],
    );
  }

  Widget _buildJoinGame() {
    return _buildGlassCard(
      title: 'Join a Game',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pinput(
            length: 6,
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
            ],
            defaultPinTheme: PinTheme(
              width: 48,
              height: 48,
              textStyle: const TextStyle(fontSize: 20, color: Colors.white),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onCompleted: (pin) async {
              await _handleGameJoin(pin);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Enter your game code above to join an existing game.',
            style: baseTextStyle.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              _showCreateGameOptions();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Create a New Game',
                  style: baseTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateGameOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create a New Game',
                style: baseTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const FaIcon(
                    FontAwesomeIcons.penToSquare,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Create Game Yourself',
                    style: baseTextStyle.copyWith(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Get.to(() => const CreateGamePage());
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const FaIcon(
                    FontAwesomeIcons.robot,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Use AI to Generate Game',
                    style: baseTextStyle.copyWith(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Get.to(() => const AIGenerate());
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameTypes() {
    return _buildGlassCard(
      title: 'Explore Game Details',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.blue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const FaIcon(FontAwesomeIcons.mapLocationDot,
              color: Colors.white, size: 18),
        ),
        title: Text(
          'ClaimRush',
          style: baseTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
        } else if (snapshot.data!.isEmpty) {
          return Text(
            'You have no games yet.',
            style: baseTextStyle.copyWith(color: Colors.white70),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Games',
                style: baseTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final game = snapshot.data![index];
                  return _buildGameCard(game);
                },
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildGameCard(GameTemplate game) {
    return _buildGlassCard(
      title: '',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _buildGameIcon(game.gameType),
        title: Text(
          game.gameName,
          style: baseTextStyle.copyWith(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          'Created ${DateFormat.yMMMd().format(game.createdAt)}',
          style: baseTextStyle.copyWith(fontSize: 14, color: Colors.white70),
        ),
        trailing:
            const FaIcon(FontAwesomeIcons.angleRight, color: Colors.white70),
        onTap: () {
          gameTemplate = game;
          Get.to(() => const ClaimZoneView());
        },
      ),
    );
  }

  Widget _buildGameIcon(String gameType) {
    IconData iconData;
    if (gameType == 'claimthezone') {
      iconData = FontAwesomeIcons.mapLocationDot;
    } else if (gameType == 'photohunt') {
      iconData = FontAwesomeIcons.camera;
    } else {
      iconData = FontAwesomeIcons.running;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FaIcon(iconData, color: Colors.green, size: 24),
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
        title: const Text('Profile'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          shrinkWrap: true,
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
                    fontSize: 24, fontWeight: FontWeight.bold),
              ).animate().fadeIn(duration: 500.ms),
            ),
            Center(
              child: Text(
                '@${currentUser?.displayName}',
                style: baseTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70),
              ).animate().fadeIn(duration: 500.ms),
            ),
            const SizedBox(height: 32),
            _buildProfileField(
                'User ID', FontAwesomeIcons.hashtag, currentUser?.uid ?? '',
                isReadOnly: true),
            const SizedBox(height: 16),
            _buildProfileField(
                'Email', FontAwesomeIcons.envelope, emailController.text,
                isReadOnly: true),
            const SizedBox(height: 16),
            _buildUsernameField(),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Get.offAll(() => const AuthPage());
              },
              child: Text(
                FirebaseAuth.instance.currentUser!.isAnonymous
                    ? 'DELETE ACCOUNT'
                    : 'SIGN OUT',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, IconData icon, String value,
      {bool isReadOnly = false}) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isReadOnly
            ? IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ToastificationHelper.showSuccessToast(
                      context, 'Copied $label to clipboard');
                },
                icon: const Icon(FontAwesomeIcons.copy, color: Colors.white),
              )
            : null,
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      readOnly: isReadOnly,
      style: baseTextStyle.copyWith(color: Colors.white),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: const Icon(FontAwesomeIcons.at, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
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
      style: baseTextStyle.copyWith(color: Colors.white),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }
}

Widget _buildGlassCard({required String title, required Widget child}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: baseTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              if (title.isNotEmpty) const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}
