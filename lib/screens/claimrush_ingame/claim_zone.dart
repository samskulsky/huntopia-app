import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'dart:developer' as dev;

import '../../models/game.dart';
import '../../models/game_template.dart';
import '../../utils/theme_data.dart';
import 'purchase_screen.dart';
import 'qr_view.dart';
import 'zone_claimed.dart';

class ClaimZoneScreen extends StatefulWidget {
  const ClaimZoneScreen({super.key});

  @override
  State<ClaimZoneScreen> createState() => _ClaimZoneScreenState();
}

Zone? currentZone;
Game? curGame;
Player? curPlayer;

class _ClaimZoneScreenState extends State<ClaimZoneScreen> {
  double currentLat = 0;
  double currentLong = 0;
  bool error = true;
  bool done = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = photo;
      });
    }
  }

  Future<String?> uploadImage(XFile? image) async {
    dev.log('Uploading image');
    if (image == null) return null;
    dev.log('Image not null');
    firebase_storage.Reference storageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().microsecondsSinceEpoch}');

    firebase_storage.UploadTask uploadTask =
        storageRef.putFile(File(image.path));
    await uploadTask;
    String downloadURL = await storageRef.getDownloadURL();
    return downloadURL;
  }

  Future<void> _takePhotoAndUpload() async {
    dev.log('Taking photo');
    // Pick an image
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 756,
      maxHeight: 1008,
    );

    dev.log('Photo taken');

    if (photo != null) {
      setState(() {
        _image = photo;
      });

      String? imageUrl = await uploadImage(photo);
      if (imageUrl != null) {
        setState(() {
          uploadUrl = imageUrl;
        });
        bool canClaim = await canClaimZone(
            curGame!.gameId, curPlayer!, currentZone!.zoneId);
        if (!canClaim) {
          dev.log('Cannot claim zone');
          return;
        }
        dev.log('Claiming zone');
        cGame!.logMessages.add(LogMessage(
          message:
              '${curPlayer!.teamName} has claimed ${currentZone!.zoneName} for ${currentZone!.points} points and ${currentZone!.coins} coins.',
          timestamp: DateTime.now(),
          displayName: 'Zone Claimed!',
          uid: FirebaseAuth.instance.currentUser!.uid,
          imageUrl: imageUrl,
        ));
        cGame!.players
            .firstWhere((element) => element.playerId == curPlayer!.playerId)
            .points += currentZone!.points;
        cGame!.players
            .firstWhere((element) => element.playerId == curPlayer!.playerId)
            .coinBalance += currentZone!.coins;
        cGame!.players
            .firstWhere((element) => element.playerId == curPlayer!.playerId)
            .zonesClaimed
            .add(currentZone!.zoneId);
        updateGame(cGame!);
        iUrl = imageUrl;
        Get.off(() => const ZoneClaimed());
      }
    }
  }

  String uploadUrl = '';

  @override
  void initState() {
    super.initState();
    iUrl = '';
    setLocData();
  }

  void setLocData() async {
    Location location = Location();

    bool deviceEnabled;
    PermissionStatus permissionGranted;

    deviceEnabled = await location.serviceEnabled();
    if (!deviceEnabled) {
      deviceEnabled = await location.requestService();
      if (!deviceEnabled) {
        error = true;
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        error = true;
        return;
      }
    }

    Future.delayed(const Duration(seconds: 4), () async {
      // initial location request
      LocationData? currentLocation;
      try {
        currentLocation = await location.getLocation();
        currentLat = currentLocation.latitude!;
        currentLong = currentLocation.longitude!;
        error = false;
      } catch (e) {
        error = true;
        return;
      }
    });

    location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 0,
    );
    error = false;
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (done) {
        return;
      }
      setState(() {
        error = false;
        currentLat = currentLocation.latitude!;
        currentLong = currentLocation.longitude!;
      });
    });
  }

  @override
  void dispose() {
    Location location = Location();
    // stop listening to location changes
    location.onLocationChanged
        .listen((LocationData currentLocation) {})
        .cancel();
    done = true;
    super.dispose();
  }

  String answer = '';

  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Radius of the Earth in meters
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    double distanceMeters = 0;
    if (!error) {
      distanceMeters = haversineDistance(
        currentLat,
        currentLong,
        currentZone!.location.latitude,
        currentZone!.location.longitude,
      );
    }

    if (curPlayer!.zonesClaimed.contains(currentZone!.zoneId) ||
        curPlayer!.sabotagedUntil.isAfter(DateTime.now())) {
      return const ZoneClaimed();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text('Claim Zone'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      currentZone!.zoneName,
                      style: baseTextStyle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        ' ${currentZone!.points}',
                        style: baseTextStyle.copyWith(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const FaIcon(
                        FontAwesomeIcons.trophy,
                        size: 20,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        ' ${currentZone!.coins}',
                        style: baseTextStyle.copyWith(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const FaIcon(
                        FontAwesomeIcons.coins,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final availableMaps = await MapLauncher.installedMaps;
              try {
                await availableMaps.first.showMarker(
                  coords: Coords(
                    currentZone!.location.latitude,
                    currentZone!.location.longitude,
                  ),
                  title: currentZone!.zoneName,
                );
              } catch (e) {
                print(e);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const FaIcon(
                  FontAwesomeIcons.locationArrow,
                  color: Colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'GET DIRECTIONS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.info, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentZone!.taskType == 'selfie'
                      ? 'To claim this zone, take a selfie at the location and upload it below.'
                      : currentZone!.taskType == 'question'
                          ? 'To claim this zone, answer the question below.'
                          : 'To claim this zone, scan the QR code at the location.',
                  style: baseTextStyle.copyWith(
                      fontSize: 14, color: Colors.white54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (error)
                  Column(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.triangleExclamation,
                        size: 100,
                        color: Colors.red,
                      ),
                      Text(
                        'Error getting location data',
                        style: baseTextStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Try moving your device to help it pick up a location signal. Ensure location devices are enabled.',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          color:
                              Get.isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                if (distanceMeters.toInt() > currentZone!.radius && !error)
                  Column(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.locationPinLock,
                        size: 100,
                        color: Colors.red,
                      ),
                      Text(
                        'You are ${distanceMeters.toInt() - currentZone!.radius} meters (${((distanceMeters.toInt() - currentZone!.radius) * 3.28084).toInt()} feet) away from this zone',
                        style: baseTextStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Please move closer to the zone to claim it',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          color:
                              Get.isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                if (distanceMeters.toInt() <= currentZone!.radius && !error)
                  Column(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 100,
                        color: Colors.green,
                      ),
                      Text(
                        'You are in the zone!',
                        style: baseTextStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Complete the task below to claim it',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          color:
                              Get.isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          if (currentZone!.taskType == 'selfie' &&
              distanceMeters <= currentZone!.radius &&
              !error)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task:',
                  style: baseTextStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (currentZone!.clue == null || currentZone!.clue!.isEmpty)
                  Text(
                    'Take a selfie at the location',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (currentZone!.clue != null && currentZone!.clue!.isNotEmpty)
                  Text(
                    currentZone!.clue!,
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        perm.Permission.camera.request();
                        _takePhotoAndUpload();
                      },
                      child: Text(
                        'Take a selfie',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
          if (currentZone!.taskType == 'question' &&
              distanceMeters <= currentZone!.radius &&
              !error)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task:',
                  style: baseTextStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Answer the question below',
                  style: baseTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const FaIcon(FontAwesomeIcons.solidCircleQuestion),
                  title: Text(
                    currentZone!.clue!,
                    style: baseTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Answer',
                    labelStyle: baseTextStyle.copyWith(color: Colors.white70),
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
                  onChanged: (value) {
                    answer = value;
                  },
                  onEditingComplete: () async {
                    int r = ratio(answer.toLowerCase().trim(),
                        currentZone!.answer!.toLowerCase().trim());
                    if (r > 80) {
                      bool canClaim = await canClaimZone(
                          curGame!.gameId, curPlayer!, currentZone!.zoneId);
                      if (!canClaim) {
                        return;
                      }
                      cGame!.logMessages.add(LogMessage(
                        message:
                            '${curPlayer!.teamName} has claimed ${currentZone!.zoneName} for ${currentZone!.points} points and ${currentZone!.coins} coins.',
                        timestamp: DateTime.now(),
                        displayName: 'Zone Claimed!',
                        uid: FirebaseAuth.instance.currentUser!.uid,
                      ));
                      cGame!.players
                          .firstWhere((element) =>
                              element.playerId == curPlayer!.playerId)
                          .points += currentZone!.points;
                      cGame!.players
                          .firstWhere((element) =>
                              element.playerId == curPlayer!.playerId)
                          .coinBalance += currentZone!.coins;
                      cGame!.players
                          .firstWhere((element) =>
                              element.playerId == curPlayer!.playerId)
                          .zonesClaimed
                          .add(currentZone!.zoneId);
                      updateGame(cGame!);
                      Get.off(() => const ZoneClaimed());
                    }
                  },
                ),
              ],
            ),
          if (currentZone!.taskType == 'qrcode' &&
              distanceMeters <= currentZone!.radius &&
              !error)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task:',
                  style: baseTextStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Scan the QR code at the location',
                  style: baseTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRView(),
                          ),
                        );
                      },
                      child: Text(
                        'Scan QR code',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
          if (distanceMeters <= currentZone!.radius && !error)
            Column(
              children: [
                const SizedBox(height: 16),
                Row(children: [
                  const Expanded(child: Divider()),
                  Text("  OR  ",
                      style: baseTextStyle.copyWith(
                          color: Theme.of(context).dividerTheme.color,
                          fontWeight: FontWeight.w700)),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.purple,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.forward,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    'Skip the Task',
                    style: baseTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    curPlayer!.skips > 0
                        ? 'You have ${curPlayer!.skips} skips remaining'
                        : 'You have no skips available',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Get.isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  trailing: curPlayer!.skips > 0
                      ? const Icon(FontAwesomeIcons.angleRight)
                      : null,
                  onTap: () async {
                    if (curPlayer!.skips > 0) {
                      bool canClaim = await canClaimZone(
                          curGame!.gameId, curPlayer!, currentZone!.zoneId);
                      if (!canClaim) {
                        return;
                      }
                      cGame!.logMessages.add(LogMessage(
                        message:
                            '${curPlayer!.teamName} has skipped the task for ${currentZone!.zoneName}.',
                        timestamp: DateTime.now(),
                        displayName: 'Task Skipped!',
                        uid: FirebaseAuth.instance.currentUser!.uid,
                      ));
                      cGame!.players
                          .firstWhere((element) =>
                              element.playerId == curPlayer!.playerId)
                          .skips -= 1;
                      cGame!.players
                          .firstWhere((element) =>
                              element.playerId == curPlayer!.playerId)
                          .points += currentZone!.points;
                      cGame!.players
                          .firstWhere((element) =>
                              element.playerId == curPlayer!.playerId)
                          .coinBalance += currentZone!.coins;
                      cGame!.players
                          .firstWhere((element) =>
                              element.playerId == curPlayer!.playerId)
                          .zonesClaimed
                          .add(currentZone!.zoneId);
                      updateGame(cGame!);
                      Get.off(() => const ZoneClaimed());
                    }
                  },
                ),
              ],
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
