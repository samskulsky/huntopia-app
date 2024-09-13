import 'package:avatar_brick/avatar_brick.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:pinput/pinput.dart';
import 'package:scavhuntapp/screens/create/ai_generate.dart';

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
import 'create/claimzone_1.dart';
import 'create/claimzone_addzone.dart';
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
  final TextEditingController phoneController = TextEditingController();
  final DynamicIslandManager diManager = DynamicIslandManager(channelKey: 'DI');

  @override
  void initState() {
    super.initState();
    diManager.stopLiveActivity();
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
          updateFCMTokenIfNeeded(currentUser!);
          usernameController.text = currentUser!.displayName ?? '';
          phoneController.text = currentUser!.phoneNumber ?? '';

          if (currentUser!.role == 'ban') {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your account has been disabled.',
                      style: baseTextStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This could be due to a violation of our terms of service. If you believe this is a mistake, please contact support.\n\nWe apologize for any inconvenience this may have caused.',
                      style: baseTextStyle.copyWith(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return PersistentTabView(
            tabs: _buildTabs(context, currentUser!),
            navBarBuilder: (navBarConfig) => Style5BottomNavBar(
              navBarConfig: navBarConfig,
              navBarDecoration: NavBarDecoration(
                color: Get.theme.scaffoldBackgroundColor,
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: SpinKitFadingCube(color: Colors.green, size: 30.0),
            ),
          );
        }
      },
    );
  }

  void updateFCMTokenIfNeeded(AppUser user) {
    if (user.fcmToken == null || user.apnsToken == null) {
      updateFCMToken();
    }
  }

  List<PersistentTabConfig> _buildTabs(BuildContext context, AppUser user) {
    return [
      PersistentTabConfig(
        screen: _buildHomeScreen(context, user),
        item: ItemConfig(
          icon: const FaIcon(FontAwesomeIcons.house),
          activeForegroundColor: Colors.green,
          title: "Home",
        ),
      ),
      PersistentTabConfig(
        screen: _buildGamesScreen(context, user),
        item: ItemConfig(
          icon: const FaIcon(FontAwesomeIcons.gamepad),
          activeForegroundColor: Colors.green,
          title: "Games",
        ),
      ),
      PersistentTabConfig(
        screen: _buildProfileScreen(context, user),
        item: ItemConfig(
          icon: const FaIcon(FontAwesomeIcons.solidUser),
          activeForegroundColor: Colors.green,
          title: "Profile",
        ),
      ),
    ];
  }

  Widget _buildHomeScreen(BuildContext context, AppUser user) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: AvatarBrick(
            backgroundColor: Colors.green,
            nameTextColor: Colors.white,
            name: '${user.firstName} ${user.lastName}',
            nameTextStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        title: const Text('Home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hello, ${user.firstName}!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          )
              .animate()
              .fade(duration: 500.ms)
              .then()
              .slideY(begin: -0.1)
              .scaleXY(begin: 0.9),
          const SizedBox(height: 16),
          _buildGameTypesCard(context),
          const SizedBox(height: 16),
          _buildJoinGameCard(context, user),
        ],
      ),
    );
  }

  Widget _buildGameTypesCard(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'GAME TYPES',
              style: baseTextStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: _buildGameTypeInfo().animate().fadeIn(duration: 400.ms),
            leading: const FaIcon(FontAwesomeIcons.mapLocationDot),
            trailing: const Icon(
              FontAwesomeIcons.angleRight,
              size: 20,
              color: Colors.grey,
            ),
            onTap: () {
              Get.to(() => const GameInfo());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameTypeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ClaimRush',
          style: baseTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          children: [
            const FaIcon(FontAwesomeIcons.users, color: Colors.grey, size: 13),
            const SizedBox(width: 4),
            Text(
              '2-12 teams',
              style: baseTextStyle.copyWith(
                fontSize: 13,
                color: Colors.white54,
              ),
            ),
            const SizedBox(width: 16),
            const FaIcon(FontAwesomeIcons.clock, color: Colors.grey, size: 13),
            const SizedBox(width: 4),
            Text(
              '0.5 - 10 hours',
              style: baseTextStyle.copyWith(
                fontSize: 13,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJoinGameCard(BuildContext context, AppUser user) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'JOIN A GAME',
              style: baseTextStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const Divider(),
          Center(
            child: Pinput(
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              length: 6,
              defaultPinTheme: PinTheme(
                width: 45,
                height: 45,
                margin: const EdgeInsets.only(top: 16, bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color.fromARGB(255, 37, 187, 44)),
                  borderRadius: BorderRadius.circular(0),
                ),
                textStyle: baseTextStyle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onCompleted: (pin) async => _handleGameJoin(pin, context, user),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              'Enter the 6-letter code to join a game. Don\'t have a code? Create a new game!',
              style: baseTextStyle.copyWith(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGameJoin(
      String pin, BuildContext context, AppUser user) async {
    final game = await getGame(pin);
    if (game == null) {
      ToastificationHelper.showErrorToast(context, 'Game not found');
    } else if (game.players.length >= game.maxTeams) {
      ToastificationHelper.showErrorToast(context, 'Game is full');
    } else if (game.players.any((element) => element.playerId == user.uid)) {
      ToastificationHelper.showErrorToast(context, 'Already in game');
    } else if (game.gameStatus != 'pending') {
      ToastificationHelper.showErrorToast(context, 'Game has already started');
    } else {
      _joinGame(game, user);
    }
  }

  void _joinGame(Game game, AppUser user) {
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
    game.players.add(
      Player(
        playerId: user.uid,
        teamName: 'Team ${user.displayName}',
        teamColor: colors.firstWhere((color) =>
            !game.players.any((element) => element.teamColor == color)),
        points: 0,
        coinBalance: 0,
        sabotagedUntil: DateTime.now().subtract(const Duration(seconds: 1)),
        pointBoostUntil: DateTime.now().subtract(const Duration(seconds: 1)),
        sabotagedAt: DateTime.now(),
        pointBoostAt: DateTime.now(),
        pointMultiplier: 1,
        zonesClaimed: [],
        skips: 0,
        fcmToken: user.fcmToken ?? '',
        location: null,
      ),
    );
    updateGame(game);
    prefs.setString('currentGameId', game.gameId);
    Get.offAll(() => const WarningPage());
  }

  Widget _buildGamesScreen(BuildContext context, AppUser user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
      ),
      body: StreamBuilder<List<GameTemplate>>(
        stream: getUserGameTemplates(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitFadingCube(color: Colors.green, size: 30.0),
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCreateGameCard(),
                const SizedBox(height: 16),
                _aiGameCard(),
                const SizedBox(height: 16),
                _buildGamesList(snapshot.data!),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCreateGameCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(121, 10, 83, 229),
            Color.fromARGB(122, 3, 47, 223)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
        child: ListTile(
          leading: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
          title: Text(
            'Create a Game',
            style: baseTextStyle.copyWith(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          subtitle: Text(
            'Start a new game and invite friends to join!',
            style: baseTextStyle.copyWith(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          trailing: const Icon(FontAwesomeIcons.angleRight,
              size: 20, color: Colors.white),
          onTap: () {
            Get.to(() => const CreateGamePage());
          },
        ),
      ),
    );
  }

  Widget _aiGameCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(121, 167, 229, 10),
            Color.fromARGB(121, 3, 223, 84)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
        child: ListTile(
          leading: const FaIcon(FontAwesomeIcons.robot, color: Colors.white),
          title: Text(
            'AI-Generated Game',
            style: baseTextStyle.copyWith(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let our AI create a game for you!',
                style: baseTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              Text(
                'You have ${currentUser!.tokens} AI token${currentUser!.tokens == 1 ? '' : 's'} remaining.',
                style: baseTextStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              )
            ],
          ),
          trailing: const Icon(FontAwesomeIcons.angleRight,
              size: 20, color: Colors.white),
          onTap: () {
            Get.to(() => const AIGenerate());
          },
        ),
      ),
    );
  }

  Widget _buildGamesList(List<GameTemplate> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: games.map((game) => _buildGameCard(game)).toList(),
    );
  }

  Widget _buildGameCard(GameTemplate game) {
    return Card(
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              game.gameType == 'claimthezone'
                  ? 'ClaimRush'
                  : game.gameType == 'photohunt'
                      ? 'SnapQuest'
                      : 'StarSprint',
              style: baseTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey),
            ),
            Text(game.gameName,
                style: baseTextStyle.copyWith(
                    fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Created ${DateFormat.yMd().format(game.createdAt)} • Updated ${DateFormat.yMd().format(game.lastUpdated)}',
              style: baseTextStyle.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            if (game.gameType == 'claimthezone') _buildGameDetails(game),
          ],
        ),
        leading: _buildGameIcon(game.gameType),
        trailing: const Icon(FontAwesomeIcons.angleRight,
            size: 20, color: Colors.grey),
        onTap: () {
          gameTemplate = game;
          Get.to(() => const ClaimZoneView());
        },
      ),
    );
  }

  Widget _buildGameIcon(String gameType) {
    return gameType == 'claimthezone'
        ? const FaIcon(FontAwesomeIcons.mapLocationDot)
        : gameType == 'photohunt'
            ? const FaIcon(FontAwesomeIcons.camera)
            : const FaIcon(FontAwesomeIcons.running);
  }

  Widget _buildGameDetails(GameTemplate game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGameDetailRow(FontAwesomeIcons.hashtag, 'Number of Zones: ',
            game.zones!.length.toString()),
        _buildGameDetailRow(
            FontAwesomeIcons.award,
            'Total Points: ',
            game.zones!
                .fold<int>(0,
                    (previousValue, element) => previousValue + element.points)
                .toString()),
        _buildGameDetailRow(
            FontAwesomeIcons.coins,
            'Total Coins: ',
            game.zones!
                .fold<int>(0,
                    (previousValue, element) => previousValue + element.coins)
                .toString()),
      ],
    );
  }

  Widget _buildGameDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        FaIcon(icon, size: 12),
        const SizedBox(width: 4),
        Text('$label $value',
            style: baseTextStyle.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildProfileScreen(BuildContext context, AppUser user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 16),
          _buildProfileField('User ID', FontAwesomeIcons.hashtag, user.uid,
              isReadOnly: true),
          const SizedBox(height: 16),
          _buildProfileField(
              'Phone Number', FontAwesomeIcons.phone, phoneController.text,
              isReadOnly: true),
          const SizedBox(height: 16),
          _buildUsernameField(),
          const SizedBox(height: 16),
          _buildSignOutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AppUser user) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: Text(
        "${user.firstName} ${user.lastName}",
        style:
            baseTextStyle.copyWith(fontSize: 26, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '@${user.displayName}',
        style: baseTextStyle.copyWith(
            fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white54),
      ),
      leading: AvatarBrick(
        radius: 20,
        name: '${user.firstName} ${user.lastName}',
        backgroundColor: Colors.green,
        nameTextColor: Colors.white,
      ),
    );
  }

  Widget _buildProfileField(String label, IconData icon, String value,
      {bool isReadOnly = false}) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isReadOnly
            ? IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ToastificationHelper.showSuccessToast(
                      context, 'Copied $label to clipboard');
                },
                icon: const Icon(FontAwesomeIcons.copy),
              )
            : null,
      ),
      readOnly: isReadOnly,
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: usernameController,
      decoration: const InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(FontAwesomeIcons.at),
      ),
      maxLength: 20,
      onChanged: (value) {
        usernameController.text = usernameController.text
            .replaceAll(RegExp(r'\s+'), '')
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      },
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        currentUser!.displayName = usernameController.text;
        updateAppUser(currentUser!);
      },
    );
  }

  Widget _buildSignOutButton() {
    return FilledButton(
      style: FilledButton.styleFrom(backgroundColor: Colors.red),
      onPressed: () {
        FocusScope.of(context).unfocus();
        FirebaseAuth.instance.signOut();
        Get.offAll(() => const AuthPage());
      },
      child: const Text('SIGN OUT'),
    );
  }
}
