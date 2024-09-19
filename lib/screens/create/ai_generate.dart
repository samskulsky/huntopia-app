import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/utils/toastification_helper.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../models/game_template.dart';
import '../../utils/theme_data.dart';
import '../home_screen.dart';

class AIGenerate extends StatefulWidget {
  const AIGenerate({super.key});

  @override
  State<AIGenerate> createState() => _AIGenerateState();
}

class _AIGenerateState extends State<AIGenerate> {
  TextEditingController gameDescriptionController = TextEditingController();
  bool isLoading = false;

  String loadingMessage = "Initializing...";
  int totalZones = 0;
  int zonesGenerated = 0;

  // ignore: non_constant_identifier_names
  static String GEOAPIFY_API_KEY = dotenv.env['GEOAPIFY_KEY'].toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Generate Game Using AI',
          style: baseTextStyle.copyWith(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark),
          onPressed:
              isLoading ? null : () => Get.offAll(() => const HomeScreen()),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildGlassCard(
                title: 'Use AI to generate a game for you!',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'In order to successfully generate a game using AI, provide a brief description of the game you want to create. The more detailed the description, the better the game will be!',
                      style: baseTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    _buildDescriptionTextField(),
                    const SizedBox(height: 8),
                    Text(
                      'You currently have ${currentUser!.tokens} token${currentUser!.tokens == 1 ? '' : 's'} remaining.',
                      style: baseTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We recommend using the basic model for most games. If you need a larger game, use the advanced model.',
                      style: baseTextStyle.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (!isLoading && currentUser!.tokens >= 1)
                      _buildGenerateButton(),
                    if (!isLoading && currentUser!.tokens >= 15)
                      const SizedBox(height: 8),
                    if (!isLoading && currentUser!.tokens >= 15)
                      _buildGenerateButton2(),
                    if (!isLoading && currentUser!.tokens >= 50)
                      const SizedBox(height: 8),
                    if (!isLoading && currentUser!.tokens >= 50)
                      _buildGenerateButton3(),
                    if (currentUser!.tokens < 1) _buildBuyButton(),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitFadingCube(
                    color: Colors.white,
                    size: 50.0,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loadingMessage,
                    style: baseTextStyle.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTextField() {
    return TextField(
      controller: gameDescriptionController,
      decoration: InputDecoration(
        hintText:
            'This game will take you on a journey through the streets of Tokyo, where you will visit famous landmarks and hidden gems.',
        hintStyle: baseTextStyle.copyWith(
            color: Colors.white70, fontStyle: FontStyle.italic),
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
      maxLines: 4,
      maxLength: 200,
      keyboardType: TextInputType.text,
      style: baseTextStyle.copyWith(color: Colors.white),
    );
  }

  Widget _buildBuyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {},
        child: Text('No Tokens Left',
            style: baseTextStyle.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildGenerateButton() {
    totalZones = 40;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          FocusScope.of(context).unfocus();
          model = "gpt-4o-mini";
          if (gameDescriptionController.text.isEmpty) {
            ToastificationHelper.showErrorToast(
                context, 'Please enter a game description.');
            return;
          }

          setState(() {
            isLoading = true;
            loadingMessage = "Making request...";
          });

          currentUser!.tokens -= 1;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .update({'tokens': currentUser!.tokens});

          try {
            List<OpenAIChatCompletionModel> responses =
                await _generateMultipleZoneMessages(
                    gameDescriptionController.text, totalZones, [], []);
            if (responses.isEmpty) {
              throw Exception('Failed to generate any responses from GPT');
            }

            var gameData = await _combineZones(responses);

            var gameTemplate = GameTemplate(
              templateId: const Uuid().v4(),
              creatorUid: FirebaseAuth.instance.currentUser!.uid,
              creatorName: 'AI Game Creator',
              gameType: 'claimthezone',
              createdAt: DateTime.now(),
              lastUpdated: DateTime.now(),
              zones: gameData['zones'] as List<Zone>,
              gameName: 'AI Generated Game',
              gameDescription: gameDescriptionController.text,
              center: GeoPoint(
                  (gameData['zones'] as List<Zone>).first.location.latitude,
                  (gameData['zones'] as List<Zone>).first.location.longitude),
              coinShopItems: gameData['coinShopItems'] as List<CoinShopItem>,
            );

            await saveGameTemplate(gameTemplate);

            _showSuccessToast(
                'Game Generated Successfully! You can view it in the "My Games" section.');
          } catch (e) {
            print('Error: $e');
            ToastificationHelper.showErrorToast(
                context, 'Error: Failed to generate game. $e');
          } finally {
            setState(() {
              isLoading = false;
            });
            Get.offAll(() => const HomeScreen());
          }
        },
        child: Column(
          children: [
            Text('Generate Basic Game',
                style:
                    baseTextStyle.copyWith(color: Colors.white, fontSize: 18)),
            Text('Basic Model • Smaller Game • 1 Token',
                style: baseTextStyle.copyWith(
                    fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton2() {
    totalZones = 50;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          FocusScope.of(context).unfocus();
          if (gameDescriptionController.text.isEmpty) {
            ToastificationHelper.showErrorToast(
                context, 'Please enter a game description.');
            return;
          }

          setState(() {
            isLoading = true;
            loadingMessage = "Making request...";
          });

          currentUser!.tokens -= 15;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .update({'tokens': currentUser!.tokens});

          model = "gpt-4o";

          try {
            List<OpenAIChatCompletionModel> responses =
                await _generateMultipleZoneMessages(
                    gameDescriptionController.text, totalZones, [], []);
            if (responses.isEmpty) {
              throw Exception('Failed to generate any responses from GPT');
            }

            var gameData = await _combineZones(responses);

            var gameTemplate = GameTemplate(
              templateId: const Uuid().v4(),
              creatorUid: FirebaseAuth.instance.currentUser!.uid,
              creatorName: 'AI Game Creator',
              gameType: 'claimthezone',
              createdAt: DateTime.now(),
              lastUpdated: DateTime.now(),
              zones: gameData['zones'] as List<Zone>,
              gameName: 'AI Generated Game',
              gameDescription: gameDescriptionController.text,
              center: GeoPoint(
                  (gameData['zones'] as List<Zone>).first.location.latitude,
                  (gameData['zones'] as List<Zone>).first.location.longitude),
              coinShopItems: gameData['coinShopItems'] as List<CoinShopItem>,
            );

            await saveGameTemplate(gameTemplate);

            _showSuccessToast(
                'Game Generated Successfully! You can view it in the "My Games" section.');
          } catch (e) {
            print('Error: $e');
            ToastificationHelper.showErrorToast(
                context, 'Error: Failed to generate game. $e');
          } finally {
            setState(() {
              isLoading = false;
            });
            Get.offAll(() => const HomeScreen());
          }
        },
        child: Column(
          children: [
            Text('Generate Advanced Game',
                style:
                    baseTextStyle.copyWith(color: Colors.white, fontSize: 18)),
            Text('Advanced Model • Larger Game • 15 Tokens',
                style: baseTextStyle.copyWith(
                    fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton3() {
    totalZones = 165;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          FocusScope.of(context).unfocus();
          if (gameDescriptionController.text.isEmpty) {
            ToastificationHelper.showErrorToast(
                context, 'Please enter a game description.');
            return;
          }

          setState(() {
            isLoading = true;
            loadingMessage = "Making request...";
          });

          currentUser!.tokens -= 15;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .update({'tokens': currentUser!.tokens});

          model = "gpt-4o";

          try {
            List<OpenAIChatCompletionModel> responses =
                await _generateMultipleZoneMessages(
                    gameDescriptionController.text, totalZones, [], []);
            if (responses.isEmpty) {
              throw Exception('Failed to generate any responses from GPT');
            }

            var gameData = await _combineZones(responses);

            var gameTemplate = GameTemplate(
              templateId: const Uuid().v4(),
              creatorUid: FirebaseAuth.instance.currentUser!.uid,
              creatorName: 'AI Game Creator',
              gameType: 'claimthezone',
              createdAt: DateTime.now(),
              lastUpdated: DateTime.now(),
              zones: gameData['zones'] as List<Zone>,
              gameName: 'AI Generated Game',
              gameDescription: gameDescriptionController.text,
              center: GeoPoint(
                  (gameData['zones'] as List<Zone>).first.location.latitude,
                  (gameData['zones'] as List<Zone>).first.location.longitude),
              coinShopItems: gameData['coinShopItems'] as List<CoinShopItem>,
            );

            await saveGameTemplate(gameTemplate);

            _showSuccessToast(
                'Game Generated Successfully! You can view it in the "My Games" section.');
          } catch (e) {
            print('Error: $e');
            ToastificationHelper.showErrorToast(
                context, 'Error: Failed to generate game. $e');
          } finally {
            setState(() {
              isLoading = false;
            });
            Get.offAll(() => const HomeScreen());
          }
        },
        child: Column(
          children: [
            Text('Generate Expert Game',
                style:
                    baseTextStyle.copyWith(color: Colors.white, fontSize: 18)),
            Text('Advanced Model • Very Large Game • 50 Tokens',
                style: baseTextStyle.copyWith(
                    fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Future<OpenAIChatCompletionModel> _generateGameWithAI(String prompt) async {
    final requestMessages = [
      OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
        ],
        role: OpenAIChatMessageRole.user,
      ),
    ];

    return OpenAI.instance.chat.create(
      model: model,
      responseFormat: {"type": "json_object"},
      messages: requestMessages,
      temperature: 0.7,
    );
  }

  String model = "gpt-4o-mini";

  String getPrompt(String description, int numZones,
      List<String> existingZoneNames, List<String> existingGeoPoints) {
    String existingZonesStr =
        existingZoneNames.isEmpty ? "None" : existingZoneNames.join(", ");
    String existingGeoPointsStr =
        existingGeoPoints.isEmpty ? "None" : existingGeoPoints.join(", ");

    return """
In ClaimRush, teams compete to earn points by claiming "zones" within a time limit. They claim a zone by completing a task there, after which the zone is locked. Each zone has a specific task (question or selfie) and location.
The game is played via a Flutter/Firebase app, using the following JSON structure:
{
  "gameName": "Sample Game",
  "gameDescription": "A sample game description.",
  "center": {
    "latitude": 35.0000, // The center of the game area. It should be a central location given the area of the game.
    "longitude": 136.0000
  },
  "zones": [
    {
      "zoneId": "123e4567-e89b-12d3-a456-426614174000",
      "zoneName": "Famous Building",
      "location": {
        "latitude": 35.0000,
        "longitude": 136.0000
      },
      "radius": 25,  // For small buildings/landmarks, 15-25 meters. For big areas, it can be up to 100 meters.
      "clue": "What is the color of the building?",
      "answer": "Blue",
      "taskType": "question",
      "points": 10,
      "coins": 5,
      "originalPoints": 10
    },
    {
      "zoneId": "123e4567-e89b-12d3-a456-426614174001",
      "zoneName": "Iconic Street",
      "location": {
        "latitude": 35.0010,
        "longitude": 136.0010
      },
      "radius": 45,
      "clue": "Take a selfie here!",
      "taskType": "selfie",
      "points": 20,
      "coins": 5,
      "originalPoints": 20
    }
  ]
}
The game ALREADY has the following zone names: [$existingZonesStr]. 
DO NOT make ANY zones with the same name or location as the existing zones -- NO OVERLAPS.
Always use SPECIFIC LOCATIONS, like "Space Mountain" instead of "Roller Coaster". Ensure the names are accurate.
The names are used in a GEOCODING API to get the exact coordinates.
Try to SPREAD THE ZONES OUT across the area, as it makes the game take longer and be more fun.
Zones that are harder to get to, have more challenging tasks, or have fewer nearby zones should have higher points (25-50). Zones that are in a cluster, are easier to get to, and have easy tasks should have lower points (5 - 25).
Based on this structure, generate a JSON object for a game template with $numZones zones. Ensure zones have accurate latitude and longitude coordinates, and the description is: $description. Only return the JSON object, nothing else. If you cannot generate it, respond with "error".
DO RELEVANT AND INTERSESTING CHALLENGES.
Example selfie challenges (but make unique ones, just for reference):
- Take a selfie doing a Mona Lisa smile in front of the Louvre.
- Take a selfie with a street performer.
- Make yourself part of the Hollywood sign.
YOU MUST KNOW AN OBJECTIVE ANSWER TO THE QUESTION.
Example question challenges (but make unique ones, just for reference):
- How many steps does it take to climb this building?
- Which famous person lived in this house?
- How many windows are on the front of this building?
""";
  }

  Future<List<OpenAIChatCompletionModel>> _generateMultipleZoneMessages(
      String description,
      int totalZones,
      List<String> existingZoneNames,
      List<String> existingGeoPoints) async {
    int batchSize = 5;
    List<OpenAIChatCompletionModel> allResponses = [];
    int zonesRemaining = totalZones;

    while (zonesRemaining > 0) {
      int numZonesToGenerate =
          (zonesRemaining >= batchSize) ? batchSize : zonesRemaining;
      String prompt = getPrompt(description, numZonesToGenerate,
          existingZoneNames, existingGeoPoints);

      OpenAIChatCompletionModel response = await _generateGameWithAI(prompt);

      print('GPT response: ${response.choices.first.message.content}');

      if (response.choices.isEmpty ||
          response.choices.first.message.content == null) {
        throw Exception('No valid content returned in GPT response');
      }

      String content = response.choices.first.message.content!
          .map((item) => item.text)
          .join()
          .trim();

      if (content.toLowerCase() == "error") {
        throw Exception('GPT returned an error response.');
      }

      allResponses.add(response);

      Map<String, dynamic> gameMap = json.decode(content);

      List<String> newZoneNames = gameMap['zones']
          .map<String>((zone) => zone['zoneName'] as String)
          .toList();

      List<String> newGeoPoints = gameMap['zones']
          .map<String>((zone) =>
              '${zone['location']['latitude']}:${zone['location']['longitude']}')
          .toList();

      existingZoneNames.addAll(newZoneNames);
      existingGeoPoints.addAll(newGeoPoints);

      zonesRemaining -= numZonesToGenerate;

      setState(() {
        double progress = (totalZones - zonesRemaining) / totalZones * 100;
        loadingMessage =
            "Generating zones (${progress.toStringAsFixed(0)}%)...";
      });
    }

    setState(() {
      loadingMessage = "Adding boosters...";
    });

    return allResponses;
  }

  Future<Map<String, Object>> _combineZones(
      List<OpenAIChatCompletionModel> allResponses) async {
    List<Zone> combinedZones = [];
    Set<String> zoneNames = {};
    Set<String> geoPoints = {};
    GeoPoint centerPoint = const GeoPoint(0, 0);

    // Flag to check if center is extracted
    bool centerExtracted = false;

    for (OpenAIChatCompletionModel response in allResponses) {
      try {
        print('Raw GPT response: ${response.choices.first.message.content}');

        String content = response.choices.first.message.content!
            .map((item) => item.text)
            .join()
            .trim();

        Map<String, dynamic> gameMap = json.decode(content);

        if (gameMap.containsKey('zones') && gameMap.containsKey('center')) {
          // Extract center if not already extracted
          if (!centerExtracted) {
            double centerLat =
                (gameMap['center']['latitude'] as num).toDouble();
            double centerLon =
                (gameMap['center']['longitude'] as num).toDouble();
            centerPoint = GeoPoint(centerLat, centerLon);
            centerExtracted = true;
          }

          List<Zone> zonesFromMap = _createZonesFromMap(gameMap);

          for (var zone in zonesFromMap) {
            String geoPointKey =
                '${zone.location.latitude}:${zone.location.longitude}';

            if (!zoneNames.contains(zone.zoneName) &&
                !geoPoints.contains(geoPointKey)) {
              combinedZones.add(zone);
              zoneNames.add(zone.zoneName);
              geoPoints.add(geoPointKey);
            } else {
              print('Duplicate zone found: ${zone.zoneName} or $geoPointKey');
            }
          }
        } else {
          throw Exception('Invalid JSON structure: Missing required fields');
        }
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    }

    // Check if center was extracted
    if (!centerExtracted) {
      throw Exception('Failed to extract center from GPT responses.');
    }

    // Use Batch Geocoding API to get more accurate coordinates.
    setState(() {
      loadingMessage = "Improving zone coordinates...";
    });

    // Prepare the list of addresses
    List<String> addresses =
        combinedZones.map((zone) => zone.zoneName).toList();

    // Use the extracted center as the bias
    double biasLongitude = centerPoint.longitude;
    double biasLatitude = centerPoint.latitude;

    // Add a 5-mile radius filter (8046.72 meters)
    Map<String, GeoPoint> geocodedLocations =
        await _geocodeAddresses(addresses, biasLongitude, biasLatitude, 8047);

    // Update the zones with new coordinates.
    for (var zone in combinedZones) {
      String zoneName = zone.zoneName;
      if (geocodedLocations.containsKey(zoneName)) {
        zone.location = geocodedLocations[zoneName]!;
      } else {
        print(
            'No geocoded location found for zone $zoneName within 5 miles. Using original coordinates.');
        // Retain original coordinates from ChatGPT
      }
    }

    final coinShopItemsJson = [
      {
        "itemId": "008ede97-7eee-4f10-ad21-d18e6368a722",
        "itemName": "Point Boost 1.5x",
        "itemDescription": "Boosts points earned by 1.5x for 15 minutes.",
        "itemPrice": 20,
        "pointsPerCoin": 1,
        "itemType": "booster",
        "multiplier": 1.5,
        "duration": 15
      },
      {
        "itemId": "008ede97-7eee-4f10-ad21-d18e6368a722",
        "itemName": "Point Boost 2x",
        "itemDescription": "Boosts points earned by 2x for 15 minutes.",
        "itemPrice": 30,
        "pointsPerCoin": 1,
        "itemType": "booster",
        "multiplier": 2,
        "duration": 15
      },
      {
        "itemId": "161cb90e-fb6c-4174-8723-76b18797f128",
        "itemName": "Sabotage 15m",
        "itemDescription": "Disables opponents for 15 minutes.",
        "itemPrice": 25,
        "pointsPerCoin": 1,
        "itemType": "disabler",
        "multiplier": 1,
        "duration": 15
      },
      {
        "itemId": "161cb90e-fb6c-4174-8723-76b18797f128",
        "itemName": "Sabotage 30m",
        "itemDescription": "Disables opponents for 30 minutes.",
        "itemPrice": 45,
        "pointsPerCoin": 1,
        "itemType": "disabler",
        "multiplier": 1,
        "duration": 30
      },
      {
        "itemId": "72209ce5-10ef-4402-8433-9e6af173e7ec",
        "itemName": "Coin ATM",
        "itemDescription": "Earns 2 points for each coin spent.",
        "itemPrice": 5,
        "pointsPerCoin": 2,
        "itemType": "coin",
        "multiplier": 1,
        "duration": 0
      },
      {
        "itemId": "694c1bd3-e9ae-47dc-acdd-ed229f0421ca",
        "itemName": "Task Skip",
        "itemDescription": "Skips a task.",
        "itemPrice": 10,
        "pointsPerCoin": 1,
        "itemType": "skip",
        "multiplier": 1,
        "duration": 0
      }
    ];

    List<CoinShopItem> coinShopItems = coinShopItemsJson
        .map((item) => CoinShopItem.fromJson(item as Map<String, Object>))
        .toList();

    setState(() {
      loadingMessage = "Finishing up...";
    });

    return {"zones": combinedZones, "coinShopItems": coinShopItems};
  }

  Future<Map<String, GeoPoint>> _geocodeAddresses(List<String> addresses,
      double biasLongitude, double biasLatitude, double radiusMeters) async {
    String url =
        'https://api.geoapify.com/v1/batch/geocode/search?apiKey=$GEOAPIFY_API_KEY&bias=proximity:$biasLongitude,$biasLatitude&filter=circle:$biasLongitude,$biasLatitude,$radiusMeters';

    String requestBody = json.encode(addresses);

    var response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode != 202) {
      throw Exception(
          'Failed to create batch job: ${response.statusCode} ${response.reasonPhrase}');
    }

    Map<String, dynamic> responseBody = json.decode(response.body);

    String jobId = responseBody['id'];
    String jobUrl = responseBody['url'];

    bool isCompleted = false;
    int maxAttempts = 100;
    int attempts = 0;

    while (!isCompleted && attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));
      attempts++;

      var jobResponse = await http.get(Uri.parse(jobUrl));

      if (jobResponse.statusCode == 200) {
        isCompleted = true;

        List<dynamic> results = json.decode(jobResponse.body);

        Map<String, GeoPoint> geocodedLocations = {};

        for (var result in results) {
          String queryText = result['query']['text'];
          if (result.containsKey('lon') && result.containsKey('lat')) {
            double lon = result['lon'] is String
                ? double.parse(result['lon'])
                : result['lon'].toDouble();
            double lat = result['lat'] is String
                ? double.parse(result['lat'])
                : result['lat'].toDouble();
            GeoPoint point = GeoPoint(lat, lon);
            geocodedLocations[queryText] = point;
          } else {
            print('No coordinates found for $queryText within 5 miles.');
          }
        }

        return geocodedLocations;
      } else if (jobResponse.statusCode == 202) {
        print('Job is still pending. Attempts: $attempts');
        // Job is still pending.
        continue;
      } else {
        throw Exception(
            'Failed to get batch job result: ${jobResponse.statusCode} ${jobResponse.reasonPhrase}');
      }
    }

    throw Exception('Batch job did not complete in time');
  }

  List<Zone> _createZonesFromMap(Map<String, dynamic> gameMap) {
    List<Zone> zones = [];

    if (gameMap['zones'] != null) {
      for (var zone in gameMap['zones']) {
        try {
          zones.add(Zone(
            zoneId: const Uuid().v4(),
            zoneName: zone['zoneName'],
            location: GeoPoint(
              (zone['location']['latitude'] as num).toDouble(),
              (zone['location']['longitude'] as num).toDouble(),
            ),
            radius: zone['radius'] > 50 ? 50 : (zone['radius'] as num).toInt(),
            clue: zone['clue'],
            answer: zone['answer'],
            photoURL: zone['photoURL'] ?? '',
            qrCode: zone['qrCode'] ?? '',
            taskType: zone['taskType'],
            points: zone['points'],
            coins: zone['coins'],
            originalPoints: zone['originalPoints'],
          ));
        } catch (e) {
          print('Error processing zone ${zone['zoneName']}: $e');
        }
      }
    } else {
      print('No zones found in the JSON response.');
    }

    return zones;
  }

  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
      style: ToastificationStyle.fillColored,
      applyBlurEffect: true,
      type: ToastificationType.success,
      title: Text(message, style: baseTextStyle.copyWith(color: Colors.white)),
      autoCloseDuration: const Duration(seconds: 5),
    );
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
