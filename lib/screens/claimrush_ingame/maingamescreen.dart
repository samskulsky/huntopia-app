import 'dart:ui';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_podium/flutter_podium.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:scavhuntapp/main.dart';
import 'package:scavhuntapp/models/game.dart';
import 'package:scavhuntapp/models/game_template.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/cant_claim.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/claim_zone.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/edit_team.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/full_image_view.dart';
import 'package:scavhuntapp/screens/home_screen.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../utils/game_utils.dart';
import '../../utils/live_activities.dart';
import '../../utils/theme_data.dart';
import 'purchase_screen.dart';
import 'package:scavhuntapp/widgets/game_map.dart';
import 'package:scavhuntapp/widgets/game_ui_components.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/game_end_screen.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

bool update = true;
bool liveActivityStarted = false;

class _MainGameScreenState extends State<MainGameScreen> {
  bool edit = false;
  TextEditingController teamNameController = TextEditingController();
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  late String currentGameId;
  final DynamicIslandManager diManager = DynamicIslandManager(channelKey: 'DI');
  TextEditingController announcementController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    currentGameId = prefs.getString('currentGameId')!;
    FirebaseMessaging.instance.requestPermission();
  }

  @override
  void dispose() {
    super.dispose();
    liveActivityStarted = false;
    diManager.stopLiveActivity();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Game>(
      stream: gameStream(currentGameId),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          snapshot.printError();
          return const Scaffold(
            body: Center(
              child: SpinKitFadingCube(
                color: Colors.green,
                size: 30.0,
              ),
            ),
          );
        }
        Game currentGame = snapshot.data!;
        GameTemplate currentGameTemplate = currentGame.game;

        currentGame.players.sort((a, b) => b.points.compareTo(a.points));

        // sort zones by points, then by name
        currentGameTemplate.zones!.sort((a, b) {
          if (a.points == b.points) {
            return a.zoneName.compareTo(b.zoneName);
          }
          return b.points.compareTo(a.points);
        });

        // sort coin shop items by price
        currentGameTemplate.coinShopItems!
            .sort((a, b) => a.itemPrice.compareTo(b.itemPrice));

        Player currentPlayer = currentGame.players.firstWhere((element) =>
            element.playerId == FirebaseAuth.instance.currentUser!.uid);

        if (teamNameController.text.isEmpty && !edit) {
          teamNameController.text = currentPlayer.teamName;
        }

        bool host =
            currentGame.hostUid == FirebaseAuth.instance.currentUser!.uid;

        currentGameTemplate.coinShopItems!
            .sort((a, b) => a.itemPrice.compareTo(b.itemPrice));

        currentGame.logMessages
            .sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (currentPlayer.pointMultiplier != 1 &&
            currentPlayer.pointBoostUntil.isAfter(DateTime.now())) {
          for (var zone in currentGameTemplate.zones!) {
            zone.points =
                (zone.originalPoints * currentPlayer.pointMultiplier).round();
          }
        }

        if (DateTime.now().isAfter(currentGame.endTime)) {
          currentGame.gameStatus = 'ended';
        }

        if (!liveActivityStarted) {
          liveActivityStarted = true;
          Map<String, dynamic> data = {
            "gameId": currentGame.gameId,
            "gameName": currentGame.game.gameName,
            "hostName": currentGame.hostName,
            "startTime": currentGame.startTime.toIso8601String(),
            "endTime": currentGame.endTime.toIso8601String(),
            "timeLeftMinutes":
                currentGame.endTime.difference(DateTime.now()).inMinutes,
            "gameStatus": currentGame.gameStatus,
            "playerCount": currentGame.players.length,
            "maxTeams": currentGame.maxTeams,
            "durationMinutes": currentGame.durationMinutes,
            "teamPlace": currentGame.players.indexWhere(
                    (element) => element.playerId == currentPlayer.playerId) +
                1,
            "teamScore": currentPlayer.points,
            "teamCoins": currentPlayer.coinBalance,
            "teamName": currentPlayer.teamName,
            "teamColor": currentPlayer.teamColor,
            "zonesClaimed": currentPlayer.zonesClaimed.length,
          };
          diManager.startLiveActivity(
            jsonData: data,
          );
        } else {
          Map<String, dynamic> data = {
            "gameId": currentGame.gameId,
            "gameName": currentGame.game.gameName,
            "hostName": currentGame.hostName,
            "startTime": currentGame.startTime.toIso8601String(),
            "endTime": currentGame.endTime.toIso8601String(),
            "timeLeftMinutes":
                currentGame.endTime.difference(DateTime.now()).inMinutes,
            "gameStatus": currentGame.gameStatus,
            "playerCount": currentGame.players.length,
            "maxTeams": currentGame.maxTeams,
            "durationMinutes": currentGame.durationMinutes,
            "teamPlace": currentGame.players.indexWhere(
                    (element) => element.playerId == currentPlayer.playerId) +
                1,
            "teamScore": currentPlayer.points,
            "teamCoins": currentPlayer.coinBalance,
            "teamName": currentPlayer.teamName,
            "teamColor": currentPlayer.teamColor,
            "zonesClaimed": currentPlayer.zonesClaimed.length,
          };
          diManager.updateLiveActivity(jsonData: data);
        }

        // if (update) {
        //   Future.delayed(const Duration(milliseconds: 100), () {});
        // }

        if (currentGame.gameStatus == 'ended' ||
            currentGame.endTime.toLocal().isBefore(DateTime.now().toLocal())) {
          currentGame.players.sort((a, b) =>
              (b.points + b.coinBalance).compareTo(a.points + a.coinBalance));

          cGame = currentGame;

          return GameEndScreen(
            currentGame: currentGame,
            currentPlayer: currentPlayer,
          );
        }

        if (currentGame.gameStatus == 'pending') {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Game Lobby',
                style: baseTextStyle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Any moment now! 🚀',
                    style: baseTextStyle.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 12),
                  Text(
                    'The game will start soon! You will receive a notification when it starts.',
                    style: baseTextStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildLobbyTile(
                          icon: FontAwesomeIcons.gamepad,
                          title: 'Game Code',
                          value: currentGame.gameId,
                          isFirst: true,
                        ),
                        Divider(
                            color: Colors.white.withOpacity(0.1), height: 1),
                        _buildLobbyTile(
                          icon: FontAwesomeIcons.clock,
                          title: 'Duration',
                          value: '${currentGame.durationMinutes} minutes',
                        ),
                        Divider(
                            color: Colors.white.withOpacity(0.1), height: 1),
                        _buildLobbyTile(
                          icon: FontAwesomeIcons.users,
                          title: 'Teams Joined',
                          value:
                              '${currentGame.players.length} / ${currentGame.maxTeams}',
                          isLast: true,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
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
                            'Your Team',
                            style: baseTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        Divider(
                            color: Colors.white.withOpacity(0.1), height: 1),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: teamNameController,
                                decoration: InputDecoration(
                                  labelText: 'Team Name',
                                  labelStyle: baseTextStyle.copyWith(
                                      color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.green.shade400),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style:
                                    baseTextStyle.copyWith(color: Colors.white),
                                onFieldSubmitted: (value) {
                                  currentPlayer.teamName = value;
                                  currentGame.players[currentGame.players
                                          .indexWhere((element) =>
                                              element.playerId ==
                                              currentPlayer.playerId)] =
                                      currentPlayer;
                                  updateGame(currentGame);
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Team Color',
                                style: baseTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildColorSelection(currentGame, currentPlayer),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                  const SizedBox(height: 32),
                  if (host)
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
                        onPressed: currentGame.players.length < 0
                            ? null
                            : () {
                                currentGame.gameStatus = 'live';
                                currentGame.startTime = DateTime.now().add(
                                  const Duration(seconds: 5),
                                );
                                currentGame.endTime = DateTime.now().add(
                                  Duration(
                                      minutes: currentGame.durationMinutes,
                                      seconds: 5),
                                );
                                currentGame.logMessages.add(
                                  LogMessage(
                                    uid: 'system',
                                    message:
                                        'The game has started! Good luck! It will end at ${DateFormat.jm().format(currentGame.endTime.toLocal())}',
                                    timestamp: DateTime.now(),
                                    displayName: 'ClaimRush',
                                  ),
                                );
                                updateGame(currentGame);
                              },
                        child: Text(
                          'Start Game',
                          style: baseTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _leaveGameDialog(currentGame, host),
                      child: Text(
                        'Leave Game',
                        style: baseTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
                ],
              ),
            ),
          );
        }

        return PersistentTabView(
          navBarBuilder: (navBarConfig) => Style6BottomNavBar(
            navBarConfig: navBarConfig,
            navBarDecoration: NavBarDecoration(
              color: Get.theme.scaffoldBackgroundColor,
            ),
          ),
          controller: _controller,
          tabs: [
            PersistentTabConfig(
              item: ItemConfig(
                icon: const FaIcon(FontAwesomeIcons.mapLocationDot),
                title: "Map",
                activeForegroundColor: Colors.green,
              ),
              screen: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: false,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Game Map',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Tap a zone\'s point value to claim it!',
                        style: baseTextStyle.copyWith(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    if (currentGame.endTime.isAfter(DateTime.now()))
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SlideCountdown(
                          showZeroValue: false,
                          duration:
                              currentGame.endTime.difference(DateTime.now()),
                          slideDirection: SlideDirection.down,
                          separator: ':',
                          style: baseTextStyle.copyWith(
                            fontSize: 20,
                            color: currentGame.endTime
                                        .difference(DateTime.now())
                                        .inMinutes <
                                    10
                                ? Colors.red
                                : const Color.fromARGB(255, 84, 86, 150),
                            fontWeight: FontWeight.w700,
                          ),
                          separatorStyle: baseTextStyle.copyWith(
                            fontSize: 20,
                            color: currentGame.endTime
                                        .difference(DateTime.now())
                                        .inMinutes <=
                                    10
                                ? Colors.red
                                : const Color.fromARGB(255, 84, 86, 150),
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color.fromARGB(255, 19, 20, 47),
                              width: 2,
                            ),
                          ),
                          onDone: () {
                            setState(() {});
                          },
                        ),
                      ),
                    IconButton(
                      onPressed: () {
                        mapController = MapController();
                        setState(() {});
                      },
                      icon: const FaIcon(FontAwesomeIcons.rotate),
                    ),
                  ],
                  bottom: currentPlayer.sabotagedUntil.isAfter(DateTime.now())
                      ? PreferredSize(
                          preferredSize: const Size.fromHeight(90),
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              border: Border.all(
                                  color: Colors.red.shade300, width: 1.5),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              title: Text(
                                'You\'ve Been Disabled!',
                                style: baseTextStyle.copyWith(
                                  fontSize: 18,
                                  color: Colors.red.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'You cannot claim zones until ${DateFormat.jm().format(currentPlayer.sabotagedUntil.toLocal())}',
                                style: baseTextStyle.copyWith(
                                  fontSize: 14,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.triangleExclamation,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
                extendBody: false,
                body: Stack(
                  children: [
                    GameMap(
                      currentGame: currentGame,
                      currentGameTemplate: currentGameTemplate,
                      currentPlayer: currentPlayer,
                      unclaimedZones: currentGameTemplate.zones!
                          .where((element) =>
                              !currentGame.players.any((player) => player
                                  .zonesClaimed
                                  .contains(element.zoneId)) &&
                              element.points > 0)
                          .toList(),
                      mapController: mapController,
                    ),
                    GameCodeChip(currentGame: currentGame),
                    PlayerScoreChip(
                      currentGame: currentGame,
                      currentPlayer: currentPlayer,
                    ),
                    PlayerStatusChip(currentPlayer: currentPlayer),
                  ],
                ),
              ),
            ),
            PersistentTabConfig(
              item: ItemConfig(
                icon: const FaIcon(FontAwesomeIcons.list),
                title: "Zones",
                activeForegroundColor: Colors.green,
              ),
              screen: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Zones',
                    style: baseTextStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                body: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 24, 12, 120),
                  itemCount: currentGameTemplate.zones!.length,
                  itemBuilder: (context, index) {
                    Zone currZone = currentGameTemplate.zones![index];
                    Player? claimedBy = currentGame.players.firstWhereOrNull(
                        (element) =>
                            element.zonesClaimed.contains(currZone.zoneId));
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: claimedBy != null
                              ? getColor(claimedBy.teamColor).withOpacity(0.5)
                              : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: FaIcon(
                              _getTaskIcon(currZone.taskType),
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        title: Text(
                          currZone.zoneName,
                          style: baseTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currZone.points.toString(),
                                        style: baseTextStyle.copyWith(
                                          fontSize: 14,
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const FaIcon(
                                        FontAwesomeIcons.trophy,
                                        size: 12,
                                        color: Colors.deepOrange,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currZone.coins.toString(),
                                        style: baseTextStyle.copyWith(
                                          fontSize: 14,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const FaIcon(
                                        FontAwesomeIcons.coins,
                                        size: 12,
                                        color: Colors.yellow,
                                      ),
                                    ],
                                  ),
                                ),
                                if (claimedBy != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: getColor(claimedBy.teamColor)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: getColor(claimedBy.teamColor)
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      claimedBy.teamName,
                                      style: baseTextStyle.copyWith(
                                        fontSize: 14,
                                        color: getColor(claimedBy.teamColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.locationArrow,
                            color: Colors.white70,
                            size: 16,
                          ),
                          onPressed: () {
                            mapController.move(
                              LatLng(
                                currZone.location.latitude,
                                currZone.location.longitude,
                              ),
                              18.0,
                            );
                            _controller.jumpToTab(0);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            PersistentTabConfig(
              item: ItemConfig(
                icon: const FaIcon(FontAwesomeIcons.rankingStar),
                title: "Leaderboard",
                activeForegroundColor: Colors.green,
              ),
              screen: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Leaderboard',
                    style: baseTextStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                body: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        'Each extra coin will be converted to a point at the end of the game.',
                        style: baseTextStyle.copyWith(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Podium(
                      height: 180,
                      color: Colors.green,
                      showRankingNumberInsteadOfText: true,
                      firstPosition: Text(
                        currentGame.players[0].teamName.toUpperCase(),
                        style: baseTextStyle.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      secondPosition: Text(
                        currentGame.players.length > 1
                            ? currentGame.players[1].teamName.toUpperCase()
                            : '',
                        style: baseTextStyle.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      thirdPosition: Text(
                        currentGame.players.length > 2
                            ? currentGame.players[2].teamName.toUpperCase()
                            : '',
                        style: baseTextStyle.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: const ScrollBehavior().copyWith(
                          physics: const ClampingScrollPhysics(),
                        ),
                        child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 800,
                          headingRowHeight: 40,
                          headingRowDecoration: const BoxDecoration(
                            color: Colors.green,
                          ),
                          isVerticalScrollBarVisible: false,
                          isHorizontalScrollBarVisible: false,
                          headingTextStyle: baseTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          dataTextStyle: baseTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          fixedLeftColumns: 1,
                          columns: const [
                            DataColumn2(
                              numeric: false,
                              label: Text('#'),
                              size: ColumnSize.S,
                              fixedWidth: 20,
                            ),
                            DataColumn2(
                              label: Text('Team Name'),
                              size: ColumnSize.L,
                            ),
                            DataColumn2(
                              numeric: true,
                              label: Text('Points'),
                              size: ColumnSize.S,
                            ),
                            DataColumn2(
                              numeric: true,
                              label: Text('Coins'),
                              size: ColumnSize.S,
                            ),
                            DataColumn2(
                              numeric: true,
                              label: Text('Zones'),
                              size: ColumnSize.S,
                            ),
                            DataColumn2(
                              numeric: true,
                              label: Text('Multiplier'),
                              size: ColumnSize.M,
                            ),
                            DataColumn2(
                              numeric: true,
                              label: Text('Disabled?'),
                              size: ColumnSize.L,
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            currentGame.players.length,
                            (index) => DataRow(
                              selected: currentGame.players[index].playerId ==
                                  FirebaseAuth.instance.currentUser!.uid,
                              cells: [
                                DataCell(Text(
                                  (index + 1).toString(),
                                  style: baseTextStyle.copyWith(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                )),
                                DataCell(Text(
                                  currentGame.players[index].teamName,
                                  style: baseTextStyle.copyWith(
                                    color: getColor(
                                        currentGame.players[index].teamColor),
                                    fontWeight: FontWeight.w700,
                                  ),
                                )),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(currentGame.players[index].points
                                        .toString()),
                                    const SizedBox(width: 4),
                                    const FaIcon(FontAwesomeIcons.trophy,
                                        size: 14),
                                  ],
                                )),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(currentGame.players[index].coinBalance
                                        .toString()),
                                    const SizedBox(width: 4),
                                    const FaIcon(FontAwesomeIcons.coins,
                                        size: 14),
                                  ],
                                )),
                                DataCell(Text(
                                    '${currentGame.players[index].zonesClaimed.length}')),
                                DataCell(Text(
                                  currentGame.players[index].pointMultiplier ==
                                              1 ||
                                          currentGame
                                              .players[index].pointBoostUntil
                                              .isBefore(DateTime.now())
                                      ? '1x'
                                      : currentGame.players[index]
                                                  .pointMultiplier ==
                                              2
                                          ? '2x'
                                          : currentGame.players[index]
                                                      .pointMultiplier ==
                                                  3
                                              ? '3x'
                                              : '${currentGame.players[index].pointMultiplier.toStringAsFixed(1)}x',
                                  style: baseTextStyle.copyWith(
                                    color: currentGame.players[index]
                                                .pointMultiplier ==
                                            1
                                        ? Colors.white54
                                        : currentGame.players[index]
                                                    .pointMultiplier ==
                                                2
                                            ? Colors.green
                                            : currentGame.players[index]
                                                        .pointMultiplier ==
                                                    3
                                                ? Colors.blue
                                                : Colors.purple,
                                  ),
                                )),
                                DataCell(Text(
                                  currentGame.players[index].sabotagedUntil
                                          .isAfter(DateTime.now())
                                      ? 'Until ${DateFormat.jm().format(currentGame.players[index].sabotagedUntil.toLocal())}'
                                      : 'No',
                                  style: baseTextStyle.copyWith(
                                    color: currentGame
                                            .players[index].sabotagedUntil
                                            .isAfter(DateTime.now())
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PersistentTabConfig(
              item: ItemConfig(
                icon: const FaIcon(FontAwesomeIcons.shop),
                title: "Shop",
                activeForegroundColor: Colors.green,
              ),
              screen: Scaffold(
                appBar: AppBar(
                  title: const Text('Booster Shop'),
                ),
                body: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Use your coins to buy boosters to help you win the game! Tap on an item to purchase it.',
                      style: baseTextStyle.copyWith(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    if (currentPlayer.pointBoostUntil
                        .isAfter(DateTime.now())) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: Text(
                          'You currently have a point multiplier active. You will be able to purchase another one at ${DateFormat.jm().format(currentPlayer.pointBoostUntil.toLocal())}.',
                          style: baseTextStyle.copyWith(
                            fontSize: 14,
                            color: Colors.green,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentPlayer.coinBalance.toString(),
                          style: baseTextStyle.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const FaIcon(
                          FontAwesomeIcons.coins,
                          size: 28,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Available Items',
                              style: baseTextStyle.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Divider(
                              color: Colors.white.withOpacity(0.1), height: 1),
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                currentGameTemplate.coinShopItems?.length ?? 0,
                            itemBuilder: (context, index) {
                              CoinShopItem item =
                                  currentGameTemplate.coinShopItems![index];
                              if (currentPlayer.pointBoostUntil
                                      .isAfter(DateTime.now()) &&
                                  item.itemType == 'booster') {
                                return const SizedBox();
                              }

                              Color itemColor = item.itemType == 'booster'
                                  ? Colors.green
                                  : item.itemType == 'disabler'
                                      ? Colors.red
                                      : item.itemType == 'coin'
                                          ? Colors.blue
                                          : Colors.purple;

                              bool canAfford =
                                  item.itemPrice <= currentPlayer.coinBalance;

                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    onTap: canAfford
                                        ? () {
                                            itemID = item.itemId;
                                            cGame = currentGame;
                                            Get.to(
                                                () => const PurchaseScreen());
                                          }
                                        : null,
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: itemColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: FaIcon(
                                          item.itemType == 'booster'
                                              ? FontAwesomeIcons.gem
                                              : item.itemType == 'disabler'
                                                  ? FontAwesomeIcons.ban
                                                  : item.itemType == 'coin'
                                                      ? FontAwesomeIcons.coins
                                                      : FontAwesomeIcons
                                                          .forward,
                                          color: itemColor,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      item.itemName,
                                      style: baseTextStyle.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        item.itemType == 'booster'
                                            ? '${item.multiplier}x point booster for ${item.duration} minutes'
                                            : item.itemType == 'disabler'
                                                ? 'Disables a team for ${item.duration} minutes'
                                                : item.itemType == 'coin'
                                                    ? 'Exchange ${item.itemPrice} coins for ${item.pointsPerCoin! * item.itemPrice} points'
                                                    : 'Skip any claim task once',
                                        style: baseTextStyle.copyWith(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: canAfford
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: canAfford
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item.itemPrice.toString(),
                                            style: baseTextStyle.copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: canAfford
                                                  ? Colors.white
                                                  : Colors.red,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          FaIcon(
                                            FontAwesomeIcons.coins,
                                            size: 12,
                                            color: canAfford
                                                ? Colors.amber
                                                : Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (index <
                                      (currentGameTemplate
                                                  .coinShopItems?.length ??
                                              0) -
                                          1)
                                    Divider(
                                      color: Colors.white.withOpacity(0.1),
                                      height: 1,
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
            PersistentTabConfig(
              item: ItemConfig(
                icon: const FaIcon(FontAwesomeIcons.bell),
                title: "Game Alerts",
                activeForegroundColor: Colors.green,
              ),
              screen: Scaffold(
                appBar: AppBar(
                  title: const Text('Game Alerts'),
                ),
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: messageController,
                        style: baseTextStyle.copyWith(color: Colors.white),
                        maxLines: 1,
                        maxLength: 100,
                        decoration: InputDecoration(
                          hintText: 'Send a message to all teams...',
                          hintStyle:
                              baseTextStyle.copyWith(color: Colors.white60),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.green.withOpacity(0.5)),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          suffixIcon: IconButton(
                            icon: const FaIcon(FontAwesomeIcons.paperPlane,
                                size: 20),
                            color: Colors.green,
                            onPressed: () {
                              if (messageController.text.isNotEmpty) {
                                currentGame.logMessages.add(
                                  LogMessage(
                                    message: '[TM]${messageController.text}',
                                    uid: FirebaseAuth.instance.currentUser!.uid,
                                    timestamp: DateTime.now(),
                                    displayName: currentPlayer.teamName,
                                  ),
                                );
                                updateGame(currentGame);
                                messageController.clear();
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    // Messages List
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentGame.logMessages.length,
                        itemBuilder: (context, index) {
                          final message = currentGame.logMessages[index];
                          final isTeamMessage =
                              message.message.contains('[TM]');

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.05),
                                  Colors.white.withOpacity(0.02),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with timestamp and name
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isTeamMessage
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.blue.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          message.displayName,
                                          style: baseTextStyle.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isTeamMessage
                                                ? Colors.green
                                                : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        DateFormat.jm().format(
                                            message.timestamp.toLocal()),
                                        style: baseTextStyle.copyWith(
                                          fontSize: 12,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Message content
                                  Text(
                                    message.message.replaceAll('[TM]', ''),
                                    style: baseTextStyle.copyWith(
                                      fontSize: 16,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                  ),

                                  // Image if present
                                  if (message.imageUrl.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () {
                                        imUrl = message.imageUrl;
                                        Get.to(() => const FullImageView());
                                      },
                                      child: Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(message.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (host)
              PersistentTabConfig(
                item: ItemConfig(
                  icon: const FaIcon(FontAwesomeIcons.key),
                  title: "Host",
                  activeForegroundColor: Colors.green,
                ),
                screen: Scaffold(
                  appBar: AppBar(
                    title: const Text('Host Controls'),
                  ),
                  body: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          'As the host, you have the ability to control the game. Use these controls to manage the game and players. All changes will be reflected in real-time.',
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
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Teams',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Divider(
                                  color: Colors.white.withOpacity(0.1),
                                  height: 1),
                              for (var player in currentGame.players)
                                ListTile(
                                  contentPadding: const EdgeInsets.all(20),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: getColor(player.teamColor),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  title: Text(
                                    player.teamName,
                                    style: baseTextStyle.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Points: ${player.points}, Coins: ${player.coinBalance}, Multiplier: ${player.pointMultiplier}x',
                                    style: baseTextStyle.copyWith(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const FaIcon(
                                      FontAwesomeIcons.angleRight,
                                      size: 20,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      currentPlayerId = player.playerId;
                                      cGame = currentGame;
                                      Get.to(() => const EditTeamScreen());
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Game Time',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Divider(
                                  color: Colors.white.withOpacity(0.1),
                                  height: 1),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current End Time:',
                                      style: baseTextStyle.copyWith(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${DateFormat.jm().format(currentGame.endTime)} ${DateFormat.Md().format(currentGame.endTime)}',
                                      style: baseTextStyle.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Colors.white.withOpacity(0.1),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          TimeOfDay? tod = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                currentGame.endTime),
                                          );
                                          if (tod != null) {
                                            if (tod.isAfter(TimeOfDay.now())) {
                                              currentGame.endTime =
                                                  DateTime.now().copyWith(
                                                      hour: tod.hour,
                                                      minute: tod.minute);
                                              currentGame.logMessages.add(
                                                LogMessage(
                                                  message:
                                                      'The game now ends at ${DateFormat.jm().format(currentGame.endTime)}.',
                                                  uid: FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  timestamp: DateTime.now(),
                                                  displayName: 'Game Update',
                                                ),
                                              );
                                              updateGame(currentGame);
                                            }
                                          }
                                        },
                                        child: Text(
                                          'Update End Time',
                                          style: baseTextStyle.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Announcements',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Divider(
                                  color: Colors.white.withOpacity(0.1),
                                  height: 1),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: TextField(
                                  controller: announcementController,
                                  decoration: InputDecoration(
                                    hintText: 'Type your announcement...',
                                    hintStyle: baseTextStyle.copyWith(
                                        color: Colors.white38),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.white.withOpacity(0.1)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.white.withOpacity(0.1)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          const BorderSide(color: Colors.green),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const FaIcon(
                                          FontAwesomeIcons.paperPlane,
                                          size: 20),
                                      onPressed: () {
                                        if (announcementController
                                            .text.isNotEmpty) {
                                          currentGame.logMessages.add(
                                            LogMessage(
                                              message:
                                                  announcementController.text,
                                              uid: FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              timestamp: DateTime.now(),
                                              displayName: 'Announcement',
                                            ),
                                          );
                                          updateGame(currentGame);
                                          announcementController.clear();
                                        }
                                      },
                                    ),
                                  ),
                                  style: baseTextStyle.copyWith(
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Point Controls',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Divider(
                                  color: Colors.white.withOpacity(0.1),
                                  height: 1),
                              ListTile(
                                contentPadding: const EdgeInsets.all(20),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.divide,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  'Halve Points',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Divide all unclaimed zone points by 2',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                onTap: () {
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Halve Points'),
                                      content: const Text(
                                          'Are you sure you want to halve all point values? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            for (var zone
                                                in currentGameTemplate.zones!) {
                                              if (!currentGame.players.any(
                                                  (player) => player
                                                      .zonesClaimed
                                                      .contains(zone.zoneId))) {
                                                zone.points = (zone
                                                            .originalPoints
                                                            .toDouble() /
                                                        2.0)
                                                    .toInt();
                                              }
                                            }
                                            currentGame.logMessages.add(
                                              LogMessage(
                                                message:
                                                    'All point values have been halved.',
                                                uid: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                timestamp: DateTime.now(),
                                                displayName: 'Game Update',
                                              ),
                                            );
                                            updateGame(currentGame);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Halve Points'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                  color: Colors.white.withOpacity(0.1),
                                  height: 1),
                              ListTile(
                                contentPadding: const EdgeInsets.all(20),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.xmark,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  'Double Points',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Multiply all unclaimed zone points by 2',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                onTap: () {
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Double Points'),
                                      content: const Text(
                                          'Are you sure you want to double all point values? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            for (var zone
                                                in currentGameTemplate.zones!) {
                                              if (!currentGame.players.any(
                                                  (player) => player
                                                      .zonesClaimed
                                                      .contains(zone.zoneId))) {
                                                zone.points *= 2;
                                              }
                                            }
                                            currentGame.logMessages.add(
                                              LogMessage(
                                                message:
                                                    'All point values have been doubled!',
                                                uid: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                timestamp: DateTime.now(),
                                                displayName: 'Game Update',
                                              ),
                                            );
                                            updateGame(currentGame);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Double Points'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
                              backgroundColor: Colors.red.withOpacity(0.2),
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              showStandardDialog(
                                context: context,
                                title: 'End Game',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Are you sure you want to end the game early?',
                                      style: baseTextStyle.copyWith(
                                        fontSize: 16,
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'This action cannot be undone.',
                                      style: baseTextStyle.copyWith(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  buildDialogAction(
                                    text: 'Cancel',
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const SizedBox(width: 12),
                                  buildDialogAction(
                                    text: 'End Game',
                                    onPressed: () {
                                      currentGame.gameStatus = 'ended';
                                      currentGame.endTime = DateTime.now()
                                          .subtract(const Duration(seconds: 1));
                                      currentGame.logMessages.add(
                                        LogMessage(
                                          uid: FirebaseAuth
                                              .instance.currentUser!.uid,
                                          message:
                                              'The game has been ended early by the host. Thanks for playing!',
                                          timestamp: DateTime.now(),
                                          displayName: 'Game Update',
                                        ),
                                      );
                                      Navigator.pop(context);
                                      updateGame(currentGame);
                                    },
                                    isDestructive: true,
                                  ),
                                ],
                              );
                            },
                            child: Text(
                              'End Game',
                              style: baseTextStyle.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildMap(
    Game currentGame,
    GameTemplate currentGameTemplate,
    Player currentPlayer,
    List<Zone> unclaimedZones, {
    bool interaction = true,
    List<Widget> children = const [], // Optional with default empty list
  }) {
    return Stack(
      children: [
        GameMap(
          currentGame: currentGame,
          currentGameTemplate: currentGameTemplate,
          currentPlayer: currentPlayer,
          unclaimedZones: unclaimedZones,
          mapController: mapController,
          interaction: interaction,
        ),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: baseTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: baseTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  LatLngBounds calculateBounds(GameTemplate currentGameTemplate) {
    double minLat = currentGameTemplate.zones!.first.location.latitude;
    double maxLat = currentGameTemplate.zones!.first.location.latitude;
    double minLng = currentGameTemplate.zones!.first.location.longitude;
    double maxLng = currentGameTemplate.zones!.first.location.longitude;

    for (var zone in currentGameTemplate.zones!) {
      if (zone.location.latitude < minLat) {
        minLat = zone.location.latitude;
      }
      if (zone.location.latitude > maxLat) {
        maxLat = zone.location.latitude;
      }
      if (zone.location.longitude < minLng) {
        minLng = zone.location.longitude;
      }
      if (zone.location.longitude > maxLng) {
        maxLng = zone.location.longitude;
      }
    }

    // add a 20% buffer to the bounds
    double latBuffer = (maxLat - minLat) * 0.2;
    double lngBuffer = (maxLng - minLng) * 0.2;

    return LatLngBounds(
      LatLng(minLat - latBuffer, minLng - lngBuffer),
      LatLng(maxLat + latBuffer, maxLng + lngBuffer),
    );
  }

  Widget _buildColorSelection(Game currentGame, Player currentPlayer) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (var color in [
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
          'deepPurple',
        ])
          GestureDetector(
            onTap: () {
              if (currentGame.players
                  .any((element) => element.teamColor == color)) {
                return;
              }
              currentPlayer.teamColor = color;
              updateGame(currentGame);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: getColor(color),
                borderRadius: BorderRadius.circular(8),
                border: currentPlayer.teamColor == color
                    ? Border.all(
                        color: Colors.grey.shade200,
                        width: 2,
                      )
                    : null,
              ),
              child: currentPlayer.teamColor == color
                  ? const Icon(FontAwesomeIcons.check)
                  : currentGame.players
                          .any((element) => element.teamColor == color)
                      ? const Icon(FontAwesomeIcons.lock)
                      : null,
            ),
          ),
      ],
    );
  }

  void _leaveGameDialog(Game currentGame, bool host) {
    showStandardDialog(
      context: context,
      title: 'Leave Game',
      child: Text(
        'Are you sure you want to leave the game? ${host && currentGame.players.length > 1 ? 'Since you are the host, another player will be chosen as the new host.' : host ? 'Since you are the only player, the live game will be deleted. (The game template will not be deleted)' : ''}',
        style: baseTextStyle.copyWith(
          fontSize: 16,
          color: Colors.white70,
          height: 1.5,
        ),
      ),
      actions: [
        buildDialogAction(
          text: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        buildDialogAction(
          text: 'Leave Game',
          onPressed: () {
            prefs.remove('currentGameId');
            FirebaseMessaging.instance
                .unsubscribeFromTopic('game-$currentGameId');
            currentGame.players.removeWhere((element) =>
                element.playerId == FirebaseAuth.instance.currentUser!.uid);
            if (currentGame.players.isEmpty) {
              deleteGame(currentGame.gameId);
            } else if (host) {
              currentGame.hostUid = currentGame.players.first.playerId;
              updateGame(currentGame);
            } else {
              updateGame(currentGame);
            }
            Get.offAll(() => const HomeScreen());
          },
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildLobbyTile({
    required IconData icon,
    required String title,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: ListTile(
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
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Text(
          title,
          style: baseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          value,
          style: baseTextStyle.copyWith(
            fontSize: 16,
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  IconData _getTaskIcon(String taskType) {
    switch (taskType) {
      case 'question':
        return FontAwesomeIcons.question;
      case 'selfie':
        return FontAwesomeIcons.camera;
      case 'qrcode':
        return FontAwesomeIcons.qrcode;
      default:
        return FontAwesomeIcons.locationDot;
    }
  }
}

Color getColor(String color) {
  switch (color) {
    case 'red':
      return Colors.red;
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'yellow':
      return Colors.yellow;
    case 'purple':
      return Colors.purple;
    case 'orange':
      return Colors.orange;
    case 'pink':
      return Colors.pink;
    case 'cyan':
      return Colors.cyan;
    case 'teal':
      return Colors.teal;
    case 'indigo':
      return Colors.indigo;
    case 'amber':
      return Colors.amber;
    case 'lime':
      return Colors.lime;
    case 'brown':
      return Colors.brown;
    case 'grey':
      return Colors.grey;
    case 'deepOrange':
      return Colors.deepOrange;
    case 'deepPurple':
      return Colors.deepPurple;
    case 'lightBlue':
      return Colors.lightBlue;
    case 'lightGreen':
      return Colors.lightGreen;
    case 'blueGrey':
      return Colors.blueGrey;
    default:
      return Colors.blue;
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
    clipBehavior: Clip.antiAlias,
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
