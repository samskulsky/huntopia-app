import 'dart:async';
import 'dart:ui';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster_2/flutter_map_marker_cluster.dart';
import 'package:flutter_podium/flutter_podium.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'package:scavhuntapp/screens/create/claimzone_1.dart';
import 'package:scavhuntapp/screens/home_screen.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../utils/live_activities.dart';
import '../../utils/theme_data.dart';
import 'purchase_screen.dart';

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
              if (zone.points == zone.originalPoints) {
                zone.points =
                    (zone.points * currentPlayer.pointMultiplier).round();
              }
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
              currentGame.endTime
                  .toLocal()
                  .isBefore(DateTime.now().toLocal())) {
            currentGame.players.sort((a, b) =>
                (b.points + b.coinBalance).compareTo(a.points + a.coinBalance));

            cGame = currentGame;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Game Ended'),
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Game Over! 🏁',
                    style: baseTextStyle.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                      .animate()
                      .flip(duration: const Duration(seconds: 1))
                      .scale(duration: const Duration(seconds: 1)),
                  const SizedBox(height: 16),
                  Text(
                    'The game has ended. Your final score is ${currentPlayer.points + currentPlayer.coinBalance} points. Each extra coin (you had ${currentPlayer.coinBalance}) was converted to a point. \n\nView the game recap at https://scavhuntapp.web.app/#/${currentGame.gameId}.\n\nWe hope you had fun! 😀\n',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      launchUrl(
                          Uri.parse(
                              'https://scavhuntapp.web.app/#/${currentGame.gameId}'),
                          mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      'View Game Recap',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Leaderboard',
                    style: baseTextStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(
                      duration: const Duration(seconds: 1),
                      delay: const Duration(seconds: 3)),
                  const SizedBox(height: 16),
                  ListView.separated(
                    itemCount: currentGame.players.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(0),
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.only(right: 16),
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  index == 0
                                      ? '🥇 '
                                      : index == 1
                                          ? '🥈 '
                                          : index == 2
                                              ? '🥉 '
                                              : '',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 40,
                                  ),
                                ),
                                Text(
                                  currentGame.players[index].teamName,
                                  style: baseTextStyle.copyWith(
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                            if (index < 3)
                              GradientText(
                                (currentGame.players[index].points +
                                        currentGame.players[index].coinBalance)
                                    .toString(),
                                style: baseTextStyle.copyWith(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                                colors: index == 0
                                    ? [
                                        const Color.fromARGB(255, 241, 189, 0),
                                        const Color.fromARGB(255, 241, 129, 0),
                                        const Color.fromARGB(255, 241, 145, 0),
                                      ]
                                    : index == 1
                                        ? [
                                            const Color.fromARGB(
                                                255, 168, 169, 173),
                                            const Color.fromARGB(
                                                255, 192, 192, 195),
                                            const Color.fromARGB(
                                                255, 165, 165, 165),
                                          ]
                                        : [
                                            const Color.fromARGB(
                                                255, 128, 74, 0),
                                            const Color.fromARGB(
                                                255, 137, 94, 26),
                                            const Color.fromARGB(
                                                255, 176, 141, 87),
                                          ],
                              ),
                            if (index >= 3)
                              Text(
                                currentGame.players[index].points.toString(),
                                style: baseTextStyle.copyWith(
                                  fontSize: 30,
                                  color: getColor(
                                      currentGame.players[index].teamColor),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(
                              duration: const Duration(seconds: 2),
                              delay: Duration(seconds: 4 + index))
                          .slideX(
                              duration: const Duration(seconds: 1),
                              delay: Duration(seconds: 5 + index));
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      prefs.remove('currentGameId');
                      FirebaseMessaging messaging = FirebaseMessaging.instance;

                      messaging.unsubscribeFromTopic('game-$currentGameId');
                      Get.off(() => const HomeScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Leave Game',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(
                      duration: const Duration(seconds: 1),
                      delay: Duration(seconds: 6 + currentGame.players.length)),
                ],
              ),
            );
          }

          if (currentGame.gameStatus == 'pending') {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Game Lobby'),
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Any moment now! 🚀',
                    style: baseTextStyle.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The game will start soon! You will receive a notification when it starts.\n\nIn the meantime, plan your strategy by viewing the map and reading the rules.',
                    style: baseTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white54,
                    ),
                  ),
                  TextButton(
                    child: const Text('Read the Rules'),
                    onPressed: () {
                      // full screen dialog with game rules
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        fullscreenDialog: true,
                        builder: (BuildContext context) {
                          return Scaffold(
                            appBar: AppBar(
                              title: const Text('Game Rules'),
                              leading: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            body: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                Text(
                                  'Object of the Game',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'The object of the game is to obtain as many points as possible by claiming zones and collecting coins. The team with the most points at the end of the game wins.\n\nThis game will last for a total of ${currentGame.durationMinutes} minutes, at which point the game will end and all remaining coins will be converted to points. Then, the team with the most points wins!',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Claiming Zones',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'To claim a zone, tap on the zone\'s circle on the map. You must be within the zone\'s circle to claim it.\n\nYou will be prompted to answer a question or complete a task to claim the zone. Once claimed, the zone will be colored with your team\'s color, and no other team will be allowed to claim it.\n\nYou will earn points and coins for each zone claimed.',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Collecting Coins',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Whenever you claim a zone, you will earn coins. Coins can be used to purchase items in the shop. This game offers the following items for purchase:',
                                  style: baseTextStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: currentGameTemplate
                                          .coinShopItems?.length ??
                                      0,
                                  itemBuilder: (context, index) {
                                    CoinShopItem item = currentGameTemplate
                                        .coinShopItems![index];
                                    if (currentPlayer.pointBoostUntil
                                            .isAfter(DateTime.now()) &&
                                        item.itemType == 'booster') {
                                      return const SizedBox();
                                    }
                                    return _buildGlassCard(
                                      title: '',
                                      child: ListTile(
                                        dense: true,
                                        leading: item.itemType == 'booster'
                                            ? const FaIcon(FontAwesomeIcons.gem,
                                                size: 30)
                                            : item.itemType == 'disabler'
                                                ? const FaIcon(
                                                    FontAwesomeIcons.ban,
                                                    size: 30)
                                                : item.itemType == 'coin'
                                                    ? const FaIcon(
                                                        FontAwesomeIcons.coins,
                                                        size: 30)
                                                    : const FaIcon(
                                                        FontAwesomeIcons
                                                            .forward,
                                                        size: 30),
                                        title: Text(item.itemName,
                                            style: baseTextStyle.copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700)),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.itemType == 'booster'
                                                ? '${item.multiplier}x point booster for ${item.duration} minutes'
                                                : item.itemType == 'disabler'
                                                    ? 'Disables a team for ${item.duration} minutes'
                                                    : item.itemType == 'coin'
                                                        ? 'Exchange ${item.itemPrice} coins for ${item.pointsPerCoin! * item.itemPrice} points'
                                                        : 'Skip any claim task once'),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('${item.itemPrice} ',
                                                style: baseTextStyle.copyWith(
                                                    fontSize: 20,
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            const FaIcon(
                                              FontAwesomeIcons.coins,
                                              size: 16,
                                              color: Colors.green,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ));
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      mapController = MapController();
                      // full screen dialog with game map, but no interaction
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        fullscreenDialog: true,
                        builder: (BuildContext context) {
                          return Scaffold(
                            appBar: AppBar(
                              title: const Text('Game Map'),
                              leading: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            body: buildMap(
                              currentGame,
                              currentGameTemplate,
                              currentPlayer,
                              currentGameTemplate.zones!,
                              interaction: false,
                            ),
                          );
                        },
                      ));
                    },
                    child: Text(
                      'View the Map',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    maxLength: 25,
                    decoration: InputDecoration(
                      labelText: 'Team Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(FontAwesomeIcons.users),
                    ),
                    onSubmitted: (value) {
                      currentPlayer.teamName = value;
                      currentGame.players[currentGame.players.indexWhere(
                              (element) =>
                                  element.playerId == currentPlayer.playerId)] =
                          currentPlayer;
                      updateGame(currentGame);
                    },
                    style: baseTextStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    controller: teamNameController,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _buildInfoRow('Game Code', currentGame.gameId),
                          const SizedBox(height: 4),
                          _buildInfoRow('Duration',
                              '${currentGame.durationMinutes} minutes'),
                          const SizedBox(height: 4),
                          _buildInfoRow('Teams Joined',
                              '${currentGame.players.length} / ${currentGame.maxTeams}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Team Color',
                              style: baseTextStyle.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildColorSelection(currentGame, currentPlayer),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (host)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: currentGame.players.length < 2
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
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _leaveGameDialog(currentGame, host);
                    },
                    child: Text('Leave Game',
                        style: baseTextStyle.copyWith(color: Colors.red)),
                  ),
                ],
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
                    centerTitle: false,
                    title: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Game Map'),
                        Text('Tap a zone\'s point value to claim it!',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white54)),
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
                            preferredSize: const Size.fromHeight(60),
                            child: ListTile(
                              dense: true,
                              tileColor: Colors.red,
                              title: Text(
                                'You\'ve Been Disabled!',
                                style: baseTextStyle.copyWith(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                'You cannot claim zones until ${DateFormat.jm().format(currentPlayer.sabotagedUntil.toLocal())}',
                                style: baseTextStyle.copyWith(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              leading: const FaIcon(
                                FontAwesomeIcons.triangleExclamation,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  extendBody: false,
                  body: Stack(
                    children: [
                      buildMap(
                          currentGame,
                          currentGameTemplate,
                          currentPlayer,
                          currentGameTemplate.zones!
                              .where((element) =>
                                  !currentGame.players.any((player) => player
                                      .zonesClaimed
                                      .contains(element.zoneId)) &&
                                  element.points > 0)
                              .toList()),
                      _buildGameCodeChip(context, currentGame),
                      _buildPlayerScoreChip(
                          context, currentGame, currentPlayer),
                      _buildPlayerStatusChip(context, currentPlayer),
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
                    title: const Text('Zones'),
                  ),
                  body: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    itemCount: currentGameTemplate.zones!.length,
                    itemBuilder: (context, index) {
                      Zone currZone = currentGameTemplate.zones![index];
                      Player? claimedBy = currentGame.players.firstWhereOrNull(
                          (element) =>
                              element.zonesClaimed.contains(currZone.zoneId));
                      return Card(
                        color: claimedBy != null
                            ? getColor(claimedBy.teamColor).withOpacity(0.3)
                            : Theme.of(context)
                                .dividerTheme
                                .color!
                                .withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: claimedBy != null
                                ? getColor(claimedBy.teamColor)
                                : Theme.of(context).dividerTheme.color!,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            currZone.zoneName,
                            style: baseTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                currZone.points.toString(),
                                style: baseTextStyle.copyWith(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              const FaIcon(FontAwesomeIcons.trophy, size: 12),
                              const SizedBox(width: 8),
                              Text(
                                currZone.coins.toString(),
                                style: baseTextStyle.copyWith(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              const FaIcon(FontAwesomeIcons.coins, size: 12),
                              const SizedBox(width: 8),
                              Text(
                                claimedBy != null
                                    ? claimedBy.teamName
                                    : 'Unclaimed',
                                style: baseTextStyle.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const FaIcon(
                                    FontAwesomeIcons.locationArrow),
                                onPressed: () {
                                  _controller.jumpToTab(0);
                                  mapController.move(
                                    LatLng(currZone.location.latitude,
                                        currZone.location.longitude),
                                    18,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.infoCircle),
                                onPressed: () {
                                  if (currentGame.players.any((player) => player
                                      .zonesClaimed
                                      .contains(currZone.zoneId))) {
                                    disabled = false;
                                    Get.to(() => const CantClaim());
                                    return;
                                  }

                                  Player currentPlayer = currentGame.players
                                      .firstWhere((element) =>
                                          element.playerId ==
                                          FirebaseAuth
                                              .instance.currentUser!.uid);

                                  if (currentPlayer.sabotagedUntil
                                      .isAfter(DateTime.now())) {
                                    disabled = true;
                                    Get.to(() => const CantClaim());
                                    return;
                                  }

                                  cGame = currentGame;
                                  curGame = currentGame;
                                  curPlayer = currentPlayer;
                                  currentZone = currZone;

                                  Get.to(() => const ClaimZoneScreen());
                                },
                              ),
                            ],
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
                    title: const Text('Leaderboard'),
                  ),
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Each extra coin will be converted to a point at the end of the game.',
                          style: baseTextStyle.copyWith(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
                          currentGame.players[1].teamName.toUpperCase(),
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
                                      Text(currentGame
                                          .players[index].coinBalance
                                          .toString()),
                                      const SizedBox(width: 4),
                                      const FaIcon(FontAwesomeIcons.coins,
                                          size: 14),
                                    ],
                                  )),
                                  DataCell(Text(
                                      '${currentGame.players[index].zonesClaimed.length}')),
                                  DataCell(Text(
                                    currentGame.players[index]
                                                    .pointMultiplier ==
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
              if (currentGameTemplate.coinShopItems!.isNotEmpty)
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
                          'Booster Shop',
                          style: baseTextStyle.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use your coins to buy boosters to help you win the game! Tap on an item to purchase it.',
                          style: baseTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white54,
                          ),
                        ),
                        if (currentPlayer.pointBoostUntil
                            .isAfter(DateTime.now()))
                          const SizedBox(height: 8),
                        if (currentPlayer.pointBoostUntil
                            .isAfter(DateTime.now()))
                          Text(
                            'You currently have a point multiplier active. You will be able to purchase another one at ${DateFormat.jm().format(currentPlayer.pointBoostUntil.toLocal())}.',
                            style: baseTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentPlayer.coinBalance.toString(),
                              style: baseTextStyle.copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const FaIcon(FontAwesomeIcons.coins, size: 30),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
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
                            return Card(
                              color: item.itemPrice > currentPlayer.coinBalance
                                  ? Colors.grey.withOpacity(0.1)
                                  : item.itemType == 'booster'
                                      ? Colors.green.withOpacity(0.5)
                                      : item.itemType == 'disabler'
                                          ? Colors.red.withOpacity(0.5)
                                          : item.itemType == 'coin'
                                              ? Colors.blue.withOpacity(0.5)
                                              : Colors.purple.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color:
                                      item.itemPrice > currentPlayer.coinBalance
                                          ? Colors.grey.withOpacity(0.1)
                                          : item.itemType == 'booster'
                                              ? Colors.green
                                              : item.itemType == 'disabler'
                                                  ? Colors.red
                                                  : item.itemType == 'coin'
                                                      ? Colors.blue
                                                      : Colors.purple,
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  if (item.itemPrice <=
                                      currentPlayer.coinBalance) {
                                    itemID = item.itemId;
                                    cGame = currentGame;
                                    Get.to(() => const PurchaseScreen());
                                  }
                                },
                                leading: item.itemType == 'booster'
                                    ? const FaIcon(FontAwesomeIcons.gem,
                                        size: 30)
                                    : item.itemType == 'disabler'
                                        ? const FaIcon(FontAwesomeIcons.ban,
                                            size: 30)
                                        : item.itemType == 'coin'
                                            ? const FaIcon(
                                                FontAwesomeIcons.coins,
                                                size: 30)
                                            : const FaIcon(
                                                FontAwesomeIcons.forward,
                                                size: 30),
                                title: Text(item.itemName,
                                    style: baseTextStyle.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.itemType == 'booster'
                                        ? '${item.multiplier}x point booster for ${item.duration} minutes'
                                        : item.itemType == 'disabler'
                                            ? 'Disables a team for ${item.duration} minutes'
                                            : item.itemType == 'coin'
                                                ? 'Exchange ${item.itemPrice} coins for ${item.pointsPerCoin! * item.itemPrice} points'
                                                : 'Skip any claim task once'),
                                    if (item.itemType == 'skip')
                                      Text(
                                          'You currently have ${currentPlayer.skips} skip${currentPlayer.skips == 1 ? '' : 's'}',
                                          style: baseTextStyle.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                trailing: Chip(
                                  padding: const EdgeInsets.all(0),
                                  color: MaterialStateProperty.resolveWith(
                                      (states) => Colors.white),
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${item.itemPrice} ',
                                          style: baseTextStyle.copyWith(
                                              fontSize: 20,
                                              color: item.itemPrice <=
                                                      currentPlayer.coinBalance
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.w700)),
                                      FaIcon(
                                        FontAwesomeIcons.coins,
                                        size: 16,
                                        color: item.itemPrice <=
                                                currentPlayer.coinBalance
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
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
                  body: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            labelText: 'Message',
                            helperText:
                                'Send a message to all teams in the game',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffix: IconButton(
                              padding: EdgeInsets.zero,
                              visualDensity: const VisualDensity(
                                  horizontal: -4, vertical: -4),
                              icon: const FaIcon(FontAwesomeIcons.paperPlane),
                              onPressed: () {
                                if (messageController.text.isNotEmpty) {
                                  currentGame.logMessages.add(
                                    LogMessage(
                                      message: '[TM]${messageController.text}',
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid,
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: currentGame.logMessages.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            visualDensity: const VisualDensity(vertical: 4),
                            tileColor: index % 2 == 0
                                ? Colors.greenAccent.withOpacity(0.05)
                                : Colors.transparent,
                            leading: RotatedBox(
                              quarterTurns: -1,
                              child: Text(
                                  DateFormat.jm().format(currentGame
                                      .logMessages[index].timestamp
                                      .toLocal()),
                                  style: GoogleFonts.spaceMono(
                                      fontSize: 14, color: Colors.green)),
                            ),
                            title:
                                Text(currentGame.logMessages[index].displayName,
                                    style: baseTextStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    )),
                            subtitle: Text(
                                currentGame.logMessages[index].message,
                                style: baseTextStyle.copyWith(fontSize: 18)),
                            trailing: currentGame
                                    .logMessages[index].imageUrl.isNotEmpty
                                ? GestureDetector(
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(currentGame
                                              .logMessages[index].imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      imUrl = currentGame
                                          .logMessages[index].imageUrl;
                                      Get.to(() => const FullImageView());
                                    },
                                  )
                                : null,
                          );
                        },
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
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(
                            'As the host, you have the ability to control the game. Use these controls to manage the game and players. Please note, all changes will be reflected in real-time and broadcast to all players.',
                            style: baseTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Edit Teams',
                            style: baseTextStyle.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          for (var player in currentGame.players)
                            ListTile(
                              leading: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: getColor(player.teamColor),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              title: Text(player.teamName,
                                  style: baseTextStyle.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              subtitle: Text(
                                  'Points: ${player.points}, Coins: ${player.coinBalance}, Multiplier: ${player.pointMultiplier}x',
                                  style: baseTextStyle.copyWith(fontSize: 16)),
                              trailing: const Icon(FontAwesomeIcons.angleRight),
                              onTap: () {
                                currentPlayerId = player.playerId;
                                cGame = currentGame;
                                Get.to(() => const EditTeamScreen());
                              },
                            ),
                          const SizedBox(height: 16),
                          Text(
                            'Edit End Time',
                            style: baseTextStyle.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                              'The game is scheduled to end at ${DateFormat.jm().format(currentGame.endTime)} ${DateFormat.Md().format(currentGame.endTime)}.'),
                          TextButton(
                            child: const Text('Update End Time'),
                            onPressed: () async {
                              TimeOfDay? tod = await showTimePicker(
                                context: context,
                                initialTime:
                                    TimeOfDay.fromDateTime(currentGame.endTime),
                              );
                              if (tod != null) {
                                if (tod.isAfter(TimeOfDay.now())) {
                                  currentGame.endTime = DateTime.now().copyWith(
                                      hour: tod.hour, minute: tod.minute);
                                  currentGame.logMessages.add(
                                    LogMessage(
                                      message:
                                          'The game now ends at ${DateFormat.jm().format(currentGame.endTime)}.',
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      timestamp: DateTime.now(),
                                      displayName: 'Game Update',
                                    ),
                                  );
                                  updateGame(currentGame);
                                }
                              }
                            },
                          ),
                          Text(
                            'Send Announcement',
                            style: baseTextStyle.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: announcementController,
                            decoration: InputDecoration(
                              labelText: 'Announcement',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffix: IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: const VisualDensity(
                                    horizontal: -4, vertical: -4),
                                icon: const FaIcon(FontAwesomeIcons.paperPlane),
                                onPressed: () {
                                  if (announcementController.text.isNotEmpty) {
                                    currentGame.logMessages.add(
                                      LogMessage(
                                        message: announcementController.text,
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
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Game Controls',
                            style: baseTextStyle.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            child: const Text('Halve All Point Values'),
                            onPressed: () async {
                              // are you sure?
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
                                        // for unclaimed zones, double the points
                                        for (var zone
                                            in currentGameTemplate.zones!) {
                                          if (!currentGame.players.any(
                                              (player) => player.zonesClaimed
                                                  .contains(zone.zoneId))) {
                                            zone.points =
                                                (zone.points.toDouble() / 2.0)
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text('Halve Points',
                                          style: baseTextStyle.copyWith(
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          TextButton(
                            child: const Text('Double All Point Values'),
                            onPressed: () async {
                              // are you sure?
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
                                        // for unclaimed zones, double the points
                                        for (var zone
                                            in currentGameTemplate.zones!) {
                                          if (!currentGame.players.any(
                                              (player) => player.zonesClaimed
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text('Double Points',
                                          style: baseTextStyle.copyWith(
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('End Game'),
                                      content: const Text(
                                          'Are you sure you want to end the game early? You will not be able to undo this action.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            currentGame.gameStatus = 'ended';
                                            currentGame.endTime = DateTime.now()
                                                .subtract(
                                                    const Duration(seconds: 1));
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
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: Text('End Game',
                                              style: baseTextStyle.copyWith(
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Text(
                              'End Game',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        });
  }

  Widget buildMap(
    Game currentGame,
    GameTemplate currentGameTemplate,
    Player currentPlayer,
    List<Zone> unclaimedZones, {
    bool interaction = true,
    List<Widget> children = const [], // Optional with default empty list
  }) {
    List<Zone> unclaimedZones = currentGameTemplate.zones!
        .where((element) =>
            !currentGame.players.any(
                (player) => player.zonesClaimed.contains(element.zoneId)) &&
            element.points > 0)
        .toList();
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(
              currentGameTemplate.center!.latitude,
              currentGameTemplate.center!.longitude,
            ),
            cameraConstraint: CameraConstraint.containCenter(
                bounds: calculateBounds(currentGameTemplate)),
            initialZoom: 15.0,
            minZoom: 12,
            maxZoom: 20,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'com.samdev.scavhuntapp',
            ),
            CircleLayer(
              circles: currentGameTemplate.zones!.map((zone) {
                Player? claimedBy = currentGame.players.firstWhereOrNull(
                    (element) => element.zonesClaimed.contains(zone.zoneId));
                return CircleMarker(
                  point:
                      LatLng(zone.location.latitude, zone.location.longitude),
                  radius: zone.radius.toDouble(),
                  useRadiusInMeter: true,
                  color: claimedBy != null
                      ? getColor(claimedBy.teamColor).withOpacity(0.75)
                      : Colors.grey.withOpacity(0.5),
                  borderStrokeWidth: 2,
                  borderColor: claimedBy != null
                      ? getColor(claimedBy.teamColor)
                      : Colors.grey,
                );
              }).toList(),
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                disableClusteringAtZoom: 18,
                maxClusterRadius: 45,
                showPolygon: false,
                size: const Size(40, 40),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(50),
                maxZoom: 15,
                onMarkerTap: (marker) {
                  Zone tappedZone = unclaimedZones.firstWhere(
                      (element) => ValueKey(element.zoneId) == marker.key);
                  if (!interaction) {
                    return;
                  }
                  if (currentGame.players.any((player) =>
                      player.zonesClaimed.contains(tappedZone.zoneId))) {
                    disabled = false;
                    Get.to(() => const CantClaim());
                    return;
                  }

                  Player currentPlayer = currentGame.players.firstWhere(
                      (element) =>
                          element.playerId ==
                          FirebaseAuth.instance.currentUser!.uid);

                  if (currentPlayer.sabotagedUntil.isAfter(DateTime.now())) {
                    disabled = true;
                    Get.to(() => const CantClaim());
                    return;
                  }

                  cGame = currentGame;
                  curGame = currentGame;
                  curPlayer = currentPlayer;
                  currentZone = tappedZone;

                  Get.to(() => const ClaimZoneScreen());
                },
                markers: List<Marker>.generate(
                  unclaimedZones.length,
                  (index) {
                    Zone currentZone = unclaimedZones[index];
                    return Marker(
                      key: ValueKey(currentZone.zoneId),
                      width: 18 + (currentZone.points / 7 * 2) > 35
                          ? 35
                          : 18 + (currentZone.points / 7 * 2),
                      height: 18 + (currentZone.points / 7 * 2) > 35
                          ? 35
                          : 18 + (currentZone.points / 7 * 2),
                      point: LatLng(
                          currentZone.location.latitude,
                          currentZone
                              .location.longitude), // Location of the marker
                      child: Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          currentZone.points.toStringAsFixed(0),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: currentZone.points >= 100
                                ? 20
                                : 10 + (currentZone.points / 8 * 2) > 27
                                    ? 27
                                    : 10 + (currentZone.points / 8 * 2),
                            fontWeight: FontWeight.w900,
                            color: currentZone.points <= 5
                                ? Colors.red
                                : currentZone.points <= 10
                                    ? Colors.deepOrange
                                    : currentZone.points <= 15
                                        ? Colors.orange
                                        : currentZone.points <= 20
                                            ? Colors.amber
                                            : currentZone.points <= 25
                                                ? Colors.yellow
                                                : currentZone.points <= 30
                                                    ? Colors.lime
                                                    : currentZone.points <= 40
                                                        ? Colors.lightGreen
                                                        : Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                builder: (context, markers) {
                  int points = 0;
                  List<Zone> zones = unclaimedZones
                      .where((element) => markers.any(
                          (marker) => ValueKey(element.zoneId) == marker.key))
                      .toList();
                  for (var zone in zones) {
                    points += zone.points;
                  }
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black),
                    child: Center(
                      child: Text(
                        points.toString(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: points < 1000 ? 20 : 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            CurrentLocationLayer(),
          ],
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave Game'),
          content: Text(
              'Are you sure you want to leave the game? ${host && currentGame.players.length > 1 ? 'Since you are the host, another player will be chosen as the new host.' : host ? 'Since you are the only player, the live game will be deleted. (The game template will not be deleted)' : ''}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                prefs.remove('currentGameId');
                FirebaseMessaging messaging = FirebaseMessaging.instance;
                messaging.unsubscribeFromTopic('game-$currentGameId');
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Leave Game',
                  style: baseTextStyle.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameCodeChip(BuildContext context, Game currentGame) {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(top: 4),
      child: Chip(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            bottomLeft: Radius.circular(6),
          ),
          side: BorderSide(
            color: Color.fromARGB(255, 19, 20, 47),
            width: 2,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Game Code',
                style: baseTextStyle.copyWith(
                    fontSize: 12, color: Colors.white54)),
            Text(currentGame.gameId,
                style: baseTextStyle.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerScoreChip(
      BuildContext context, Game currentGame, Player currentPlayer) {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(top: 50),
      child: Chip(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            bottomLeft: Radius.circular(6),
          ),
          side: BorderSide(
            color: Color.fromARGB(255, 19, 20, 47),
            width: 2,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        label: SizedBox(
          height: 24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.trophy, size: 16),
              const SizedBox(width: 4),
              Text(
                  currentGame.players
                      .firstWhere((element) =>
                          element.playerId ==
                          FirebaseAuth.instance.currentUser!.uid)
                      .points
                      .toString(),
                  style: baseTextStyle.copyWith(
                      fontSize: 16, color: Colors.white)),
              const SizedBox(width: 16),
              const VerticalDivider(),
              const SizedBox(width: 16),
              const FaIcon(FontAwesomeIcons.coins, size: 16),
              const SizedBox(width: 4),
              Text(
                  currentGame.players
                      .firstWhere((element) =>
                          element.playerId ==
                          FirebaseAuth.instance.currentUser!.uid)
                      .coinBalance
                      .toString(),
                  style: baseTextStyle.copyWith(
                      fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerStatusChip(BuildContext context, Player currentPlayer) {
    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.only(bottom: 100),
      child: Chip(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            bottomLeft: Radius.circular(6),
          ),
          side: BorderSide(
            color: Color.fromARGB(255, 19, 20, 47),
            width: 2,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        label: SizedBox(
          height:
              currentPlayer.sabotagedUntil.isAfter(DateTime.now()) ? 100 : 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green,
                    ),
                    child: Column(
                      children: [
                        Text(
                          currentPlayer.pointBoostUntil.isBefore(DateTime.now())
                              ? '1x'
                              : currentPlayer.pointMultiplier == 2 ||
                                      currentPlayer.pointMultiplier == 3
                                  ? '${currentPlayer.pointMultiplier.toStringAsFixed(0)}x'
                                  : '${currentPlayer.pointMultiplier.toStringAsFixed(1)}x',
                          style: baseTextStyle.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.gem,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (currentPlayer.pointBoostUntil.isAfter(DateTime.now()))
                    SlideCountdown(
                      duration: currentPlayer.pointBoostUntil
                          .difference(DateTime.now()),
                      slideDirection: SlideDirection.down,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      style: baseTextStyle.copyWith(
                        fontSize: 24,
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                      separatorStyle: baseTextStyle.copyWith(
                        fontSize: 24,
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                      onDone: () {
                        setState(() {});
                      },
                    ),
                ],
              ),
              if (currentPlayer.sabotagedUntil.isAfter(DateTime.now()))
                const SizedBox(height: 8),
              if (currentPlayer.sabotagedUntil.isAfter(DateTime.now()))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.ban,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (currentPlayer.sabotagedUntil.isAfter(DateTime.now()))
                      SlideCountdown(
                        duration: currentPlayer.sabotagedUntil
                            .difference(DateTime.now()),
                        slideDirection: SlideDirection.down,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        style: baseTextStyle.copyWith(
                          fontSize: 24,
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                        separatorStyle: baseTextStyle.copyWith(
                          fontSize: 24,
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                        onDone: () {
                          setState(() {});
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
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
