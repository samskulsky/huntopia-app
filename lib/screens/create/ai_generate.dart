import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

import '../../models/game_template.dart';

class AIGenerate extends StatefulWidget {
  const AIGenerate({super.key});

  @override
  State<AIGenerate> createState() => _AIGenerateState();
}

class _AIGenerateState extends State<AIGenerate> {
  TextEditingController gameDescriptionController = TextEditingController();
  bool isLoading = false;

  // Initialize Google Maps Places API
  final GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: dotenv.env['GOOGLE_KEY'].toString(), httpClient: Client());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Game Using AI'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTitleText(),
              const SizedBox(height: 16),
              _buildGameDescriptionInfoText(),
              const SizedBox(height: 16),
              _buildDescriptionTextField(),
              const SizedBox(height: 16),
              isLoading ? const SizedBox() : _buildGenerateButton(),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.8), // Semi-transparent overlay
              child: const Center(
                child: SpinKitFadingCube(
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleText() {
    return Text(
      'Use AI to generate a game for you!',
      style: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildGameDescriptionInfoText() {
    return Text(
      'In order to successfully generate a game using AI, provide a brief description of the game you want to create. '
      'The more detailed the description, the better the game will be!',
      style: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildDescriptionTextField() {
    return TextField(
      controller: gameDescriptionController,
      decoration: const InputDecoration(
        hintText:
            'This game will take you on a journey through the streets of Tokyo, where you will visit famous landmarks and hidden gems.',
        hintStyle:
            TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
      ),
      maxLines: 4,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildGenerateButton() {
    return FilledButton(
      onPressed: () async {
        FocusScope.of(context).unfocus(); // Close keyboard
        if (gameDescriptionController.text.isEmpty) {
          _showErrorToast('Please enter a game description.');
          return;
        }

        setState(() {
          isLoading = true;
        });

        try {
          List<OpenAIChatCompletionModel> responses =
              await _generateMultipleZoneMessages(
                  gameDescriptionController.text, 50, [], []);
          if (responses.isEmpty) {
            throw Exception('Failed to generate any responses from GPT');
          }

          List<Zone> zones = await _combineZones(responses);

          if (zones.isEmpty) {
            throw Exception(
                'Failed to create zones from the generated responses');
          }

          var gameTemplate = GameTemplate(
            templateId: const Uuid().v4(),
            creatorUid: FirebaseAuth.instance.currentUser!.uid,
            creatorName: 'AI Game Creator',
            gameType: 'claimthezone',
            createdAt: DateTime.now(),
            lastUpdated: DateTime.now(),
            zones: zones,
            gameName: 'AI Generated Game',
            gameDescription: gameDescriptionController.text,
            center: GeoPoint(
                zones.first.location.latitude, zones.first.location.longitude),
          );

          await saveGameTemplate(gameTemplate);

          _showSuccessToast(
              'Game Generated Successfully! You can view it in the "My Games" section.');
        } catch (e) {
          print('Error: $e');
          _showErrorToast('Error: Failed to generate game. $e');
        } finally {
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pop();
        }
      },
      child: const Text('Generate Game'),
    );
  }

  Future<OpenAIChatCompletionModel> _generateGameWithAI(String prompt) async {
    final requestMessages = [
      OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
        ],
        role: OpenAIChatMessageRole.assistant,
      ),
    ];

    return OpenAI.instance.chat.create(
      model: "gpt-4o",
      responseFormat: {"type": "json_object"},
      messages: requestMessages,
      temperature: 0.7,
    );
  }

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
  "center": "35.0000:136.0000",
  "zones": [
    {
      "zoneId": "123e4567-e89b-12d3-a456-426614174000",
      "zoneName": "Famous Building",
      "location": "35.0000:136.0000",
      "radius": 25,  // For small buildings/landmarks, 15-25 meters. For big areas, it can be up to 100 meters.
      "clue": "What is the color of the building?", // ask any sort of visual question, not just color
      "answer": "Blue",
      "taskType": "question",
      "points": 10,
      "coins": 5,
      "originalPoints": 10
    },
    {
      "zoneId": "123e4567-e89b-12d3-a456-426614174001",
      "zoneName": "Iconic Street",
      "location": "35.0010:136.0010",
      "radius": 45,
      "clue": "Take a selfie here!", // make any sort of photo based task, it can be a challenge or a fun task that relates to the loc
      "taskType": "selfie",
      "points": 20,
      "coins": 5,
      "originalPoints": 20
    }
  ]
}
Please ensure the generated zones do not overlap. The game already has the following zone names: [$existingZonesStr] and the following geo locations: [$existingGeoPointsStr]. Ensure that no zones with these names or locations are repeated. 
Zones that are harder to get to or have more challenging tasks should have higher points. Based on this structure, generate a JSON object for a game template with $numZones zones. Ensure zones have accurate lat/long coordinates, and the description is: $description. Only return the JSON object, nothing else. If you cannot generate it, respond with "error".
""";
  }

  Future<List<OpenAIChatCompletionModel>> _generateMultipleZoneMessages(
      String description,
      int totalZones,
      List<String> existingZoneNames,
      List<String> existingGeoPoints) async {
    int batchSize = 5; // Number of zones to generate per message
    List<OpenAIChatCompletionModel> allResponses = [];
    int zonesRemaining = totalZones;

    while (zonesRemaining > 0) {
      int numZonesToGenerate =
          (zonesRemaining >= batchSize) ? batchSize : zonesRemaining;
      String prompt = getPrompt(description, numZonesToGenerate,
          existingZoneNames, existingGeoPoints);

      // Generate zones in batches
      OpenAIChatCompletionModel response = await _generateGameWithAI(prompt);

      // Log the GPT response for debugging purposes
      print('GPT response: ${response.choices.first.message.content}');

      if (response.choices.isEmpty ||
          response.choices.first.message.content == null) {
        throw Exception('No valid content returned in GPT response');
      }

      allResponses.add(response);

      // Update the list of existing zone names and locations to avoid duplication in future prompts
      Map<String, dynamic> gameMap =
          json.decode(response.choices.first.message.content![0].text!);

      List<String> newZoneNames = gameMap['zones']
          .map<String>((zone) => zone['zoneName'] as String)
          .toList();

      List<String> newGeoPoints = gameMap['zones']
          .map<String>((zone) =>
              '${zone['location'].split(":")[0]}:${zone['location'].split(":")[1]}')
          .toList();

      existingZoneNames.addAll(newZoneNames);
      existingGeoPoints.addAll(newGeoPoints);

      zonesRemaining -= numZonesToGenerate;
    }

    return allResponses;
  }

  Future<List<Zone>> _combineZones(
      List<OpenAIChatCompletionModel> allResponses) async {
    List<Zone> combinedZones = [];
    Set<String> zoneNames = {}; // Track zone names to avoid duplicate names
    Set<String> geoPoints =
        {}; // Track GeoPoints (lat:long) to avoid duplicate locations

    for (OpenAIChatCompletionModel response in allResponses) {
      try {
        print(
            'Raw GPT response: ${response.choices.first.message.content![0].text!}');

        Map<String, dynamic> gameMap =
            json.decode(response.choices.first.message.content![0].text!);

        if (gameMap.containsKey('zones') && gameMap.containsKey('center')) {
          List<Zone> zonesFromMap = await _createZonesFromMap(gameMap,
              gameMap['center'].split(':')[0], gameMap['center'].split(':')[1]);

          for (var zone in zonesFromMap) {
            String geoPointKey =
                '${zone.location.latitude}:${zone.location.longitude}';

            // Check if the zone name or geo point already exists in our set
            if (!zoneNames.contains(zone.zoneName) &&
                !geoPoints.contains(geoPointKey)) {
              // Add to the combined zones if it's not a duplicate
              combinedZones.add(zone);
              zoneNames.add(zone.zoneName); // Track this zone name
              geoPoints.add(geoPointKey); // Track this geo point (lat:long)
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

    return combinedZones;
  }

  Future<List<Zone>> _createZonesFromMap(
      Map<String, dynamic> gameMap, String centerLat, String centerLong) async {
    List<Zone> zones = [];

    if (gameMap['zones'] != null) {
      for (var zone in gameMap['zones']) {
        try {
          var predictions = await places.searchByText(
            zone['zoneName'],
            location: Location(
              lat: double.parse(centerLat),
              lng: double.parse(centerLong),
            ),
          );

          if (predictions.results.isNotEmpty) {
            var placeDetails = await places
                .getDetailsByPlaceId(predictions.results.first.placeId);

            // Add each zone with a radius limit (adjust radius if needed)
            zones.add(Zone(
              zoneId: const Uuid().v4(),
              zoneName: zone['zoneName'],
              location: GeoPoint(
                placeDetails.result.geometry!.location.lat,
                placeDetails.result.geometry!.location.lng,
              ),
              radius:
                  zone['radius'] > 50 ? 50 : zone['radius'], // Limit the radius
              clue: zone['clue'],
              answer: zone['answer'],
              photoURL: zone['photoURL'],
              qrCode: zone['qrCode'],
              taskType: zone['taskType'],
              points: zone['points'],
              coins: zone['coins'],
              originalPoints: zone['originalPoints'],
            ));
          } else {
            print('No results found for zone name: ${zone['zoneName']}');
          }
        } catch (e) {
          print('Error processing zone ${zone['zoneName']}: $e');
        }
      }
    } else {
      print('No zones found in the JSON response.');
    }

    return zones;
  }

  // Haversine formula to calculate the distance between two points on Earth
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    const double degToRad = pi / 180;
    double dLat = (lat2 - lat1) * degToRad;
    double dLon = (lon2 - lon1) * degToRad;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * degToRad) *
            cos(lat2 * degToRad) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return 2 * earthRadiusKm * atan2(sqrt(a), sqrt(1 - a));
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      style: ToastificationStyle.fillColored,
      applyBlurEffect: true,
      type: ToastificationType.error,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void _handleGenerationError() {
    setState(() {
      isLoading = false;
    });
    _showErrorToast('Error. Failed to generate game. Please try again.');
  }

  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
      style: ToastificationStyle.fillColored,
      applyBlurEffect: true,
      type: ToastificationType.success,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
