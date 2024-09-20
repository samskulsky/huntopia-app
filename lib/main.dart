import 'dart:developer';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/models/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_page.dart';
import 'screens/claimrush_ingame/maingamescreen.dart';
import 'utils/home_loading.dart';
import 'utils/live_activities.dart';
import 'utils/theme_data.dart';

late SharedPreferences prefs;

void main() async {
  // Ensure that Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Set API key for OpenAI
  try {
    OpenAI.apiKey = dotenv.env['OPENAI_KEY'].toString();
    OpenAI.requestsTimeOut = const Duration(seconds: 120);
  } catch (e) {
    log('OpenAI API key not found');
  }

  // Set up SharedPreferences
  prefs = await SharedPreferences.getInstance();
  // prefs.clear();

  // Set up Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  messaging.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final DynamicIslandManager diManager =
        DynamicIslandManager(channelKey: 'DI');
    print("Handling a foreground message: ${message.messageId}");

    if (prefs.containsKey('currentGameId')) {
      Game currentGame = (await getGame(prefs.getString('currentGameId')!))!;
      Player currentPlayer = currentGame.players.firstWhere((element) =>
          element.playerId == FirebaseAuth.instance.currentUser!.uid);

      Toastification toast = Toastification();
      toastification.show(
        style: ToastificationStyle.fillColored,
        applyBlurEffect: true,
        primaryColor: message.data['title'].contains('[TM]')
            ? Colors.blue[800]!
            : Colors.green[800]!,
        backgroundColor: message.data['title'].contains('[TM]')
            ? Colors.blue[800]!
            : Colors.green[800]!,
        showIcon: true,
        showProgressBar: message.data['title'] != 'Announcement',
        icon: message.data['title'].contains('[TM]')
            ? const Icon(Icons.message)
            : const Icon(Icons.notifications),
        autoCloseDuration: message.data['title'] == 'Announcement'
            ? null
            : const Duration(seconds: 5),
        context: Get.overlayContext,
        title: Text(
          message.data['title'].contains('[TM]')
              ? message.data['title'].toString().substring(4)
              : message.data['title'],
          style: baseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
        ),
        description: Text(
          message.data['body'],
          style: baseTextStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        alignment: Alignment.topCenter,
        boxShadow: highModeShadow,
      );
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
  });

  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final DynamicIslandManager diManager =
        DynamicIslandManager(channelKey: 'DI');

    print("Handling a background message: ${message.messageId}");

    if (prefs.containsKey('currentGameId')) {
      Game? currentGame = await getGame(prefs.getString('currentGameId')!);
      if (currentGame == null) {
        log("Current game not found");
        return;
      }

      // Initialize FirebaseAuth to get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        log("No user is currently signed in");
        return;
      }

      Player? currentPlayer = currentGame.players.firstWhereOrNull(
        (element) => element.playerId == currentUser.uid,
      );

      if (currentPlayer == null) {
        log("Current player not found in the game");
        return;
      }

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
  } catch (e) {
    print("Error in background message handler: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Huntopia',
      themeMode: ThemeMode.dark,
      defaultTransition: Transition.topLevel,
      transitionDuration: const Duration(milliseconds: 500),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: primaryColor,
          accentColor: primaryColor,
          brightness: brightness,
        ),
        brightness: brightness,
        fontFamily: baseTextStyle.fontFamily,
        splashColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        inputDecorationTheme: inputDecorationTheme,
        dividerTheme: const DividerThemeData(
          space: 0,
          thickness: 2,
          color: borderColor,
        ),
        switchTheme: Theme.of(context).switchTheme.copyWith(
              thumbColor: WidgetStateProperty.all(Colors.white),
              trackColor: WidgetStateProperty.all(Colors.grey.shade700),
            ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: Colors.grey.shade800,
          elevation: 1,
          shape: const CircularNotchedRectangle(),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor.withOpacity(0.8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color.fromARGB(255, 105, 105, 105),
          disabledColor: Colors.grey.shade100,
          selectedColor: primaryColor,
          secondarySelectedColor: Colors.black,
          padding: const EdgeInsets.all(2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: baseTextStyle.copyWith(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          secondaryLabelStyle: baseTextStyle.copyWith(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          brightness: brightness,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: const Color.fromARGB(255, 4, 7, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: borderColor, width: 2),
          ),
        ),
        sliderTheme: sliderTheme,
        filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.grey.shade800,
          elevation: 0,
          textStyle: baseTextStyle.copyWith(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 4, 7, 1),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: baseTextStyle.copyWith(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          shape: const Border(
            bottom: BorderSide(
              color: Color.fromARGB(255, 4, 29, 7),
              width: 2,
            ),
          ),
        ),
        scaffoldBackgroundColor: scaffoldBackgroundColor,
      ),
      home: FlutterSplashScreen.gif(
        useImmersiveMode: true,
        gifPath: 'assets/splash.gif',
        gifWidth: double.infinity,
        gifHeight: double.infinity,
        nextScreen: FirebaseAuth.instance.currentUser == null
            ? const AuthPage()
            : prefs.getString('currentGameId') != null
                ? const MainGameScreen()
                : const HomeLoading(),
        duration: const Duration(milliseconds: 3000),
      ),
    );
  }
}
