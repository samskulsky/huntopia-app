import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../models/game_template.dart';
import '../../utils/theme_data.dart';
import '../../utils/toastification_helper.dart';
import 'claimzone_view.dart';
import 'claimzone_1.dart';
import 'claimzone_4.dart';
import 'claimzone_loc_picker.dart' as loc;

class AddZone extends StatefulWidget {
  const AddZone({super.key});

  @override
  State<AddZone> createState() => _AddZoneState();
}

bool edit = false;
bool fromInfoPage = false;
String currentZoneId = '';

class _AddZoneState extends State<AddZone> {
  TextEditingController zoneNameController = TextEditingController();
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  TextEditingController qrCodeController = TextEditingController();

  final MapController mapController = MapController();
  String dropdownValue = 'selfie';

  int sliderValue = 30;
  int pointsSliderValue = 10;
  int coinsSliderValue = 5;
  double currentLat =
      loc.currentLat != 0 ? loc.currentLat : gameTemplate.center!.latitude;
  double currentLong =
      loc.currentLong != 0 ? loc.currentLong : gameTemplate.center!.longitude;
  CircleMarker? selectedZoneCircle;

  @override
  void initState() {
    super.initState();
    if (edit) {
      loadZoneDetails();
    }
  }

  void loadZoneDetails() {
    try {
      Zone zone = gameTemplate.zones!
          .firstWhere((element) => element.zoneId == currentZoneId);
      zoneNameController.text = zone.zoneName;
      currentLat = zone.location.latitude;
      currentLong = zone.location.longitude;
      sliderValue = zone.radius;
      dropdownValue = zone.taskType;
      questionController.text = zone.clue ?? '';
      answerController.text = zone.answer ?? '';
      qrCodeController.text = zone.qrCode ?? '';
      pointsSliderValue = zone.points;
      coinsSliderValue = zone.coins;
      selectedZoneCircle =
          createCircle(LatLng(currentLat, currentLong), sliderValue.toDouble());
    } catch (e) {
      print(e);
    }
  }

  CircleMarker createCircle(LatLng latLng, double radius) {
    return CircleMarker(
      point: latLng,
      color: Colors.deepPurple.withOpacity(0.5),
      borderStrokeWidth: 2,
      borderColor: Colors.deepPurple,
      useRadiusInMeter: true,
      radius: radius,
    );
  }

  void updateZoneCircle(LatLng latLng, double radius) {
    setState(() {
      selectedZoneCircle = createCircle(latLng, radius);
      currentLat = latLng.latitude;
      currentLong = latLng.longitude;
    });
  }

  void saveZone() {
    if (zoneNameController.text.isEmpty ||
        currentLat == 0 ||
        currentLong == 0) {
      showErrorToast(
          'To save the zone, please complete all fields and select a location on the map.');
      return;
    }
    if (dropdownValue == 'question' &&
        (questionController.text.isEmpty || answerController.text.isEmpty)) {
      showErrorToast(
          'To save a question task zone, please complete the question and answer fields.');
      return;
    }
    if (dropdownValue == 'qrcode' && qrCodeController.text.isEmpty) {
      showErrorToast(
          'To save a QR code task zone, please complete the QR code field.');
      return;
    }

    if (edit) {
      updateExistingZone();
    } else {
      addNewZone();
    }

    if (!fromInfoPage) {
      navigateTo(const ClaimZone4());
    } else {
      updateGameTemplate(gameTemplate);
      navigateTo(const ClaimZoneView());
    }
  }

  void updateExistingZone() {
    Zone zone = gameTemplate.zones!
        .firstWhere((element) => element.zoneId == currentZoneId);
    zone.zoneName = zoneNameController.text;
    zone.location = GeoPoint(currentLat, currentLong);
    zone.radius = sliderValue.toInt();
    zone.taskType = dropdownValue;
    zone.clue = questionController.text;
    zone.answer = answerController.text;
    zone.qrCode = qrCodeController.text;
    zone.points = pointsSliderValue;
    zone.coins = coinsSliderValue;
    edit = false;
    currentZoneId = '';
  }

  void addNewZone() {
    gameTemplate.zones ??= [];
    gameTemplate.zones!.add(Zone(
      zoneName: zoneNameController.text,
      location: GeoPoint(currentLat, currentLong),
      radius: sliderValue,
      taskType: dropdownValue,
      clue: questionController.text,
      answer: answerController.text,
      qrCode: qrCodeController.text,
      points: pointsSliderValue,
      coins: coinsSliderValue,
      zoneId: const Uuid().v4(),
      originalPoints: pointsSliderValue,
    ));
  }

  void navigateTo(Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  void showErrorToast(String message) {
    ToastificationHelper.showErrorToast(context, message);
  }

  @override
  void dispose() {
    fromInfoPage = false;
    zoneNameController.dispose();
    questionController.dispose();
    answerController.dispose();
    qrCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Zone', style: baseTextStyle),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (edit)
            IconButton(
              onPressed: () {
                gameTemplate.zones!
                    .removeWhere((element) => element.zoneId == currentZoneId);
                navigateTo(
                    fromInfoPage ? const ClaimZoneView() : const ClaimZone4());
              },
              icon: const FaIcon(FontAwesomeIcons.trash),
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlassCard(
              title: 'Zone Editor',
              child: Text(
                'Complete the following fields to add a zone to your game.',
                style: baseTextStyle.copyWith(color: Colors.white70),
              ),
            ),
            _buildGlassCard(
              title: 'Zone Name',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write the name of the zone you want to add.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: zoneNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Zone Name',
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
                    style: baseTextStyle.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            _buildGlassCard(
              title: 'Zone Location',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select the location of the zone on the map.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                            edit ? currentLat : gameTemplate.center!.latitude,
                            edit
                                ? currentLong
                                : gameTemplate.center!.longitude),
                        initialZoom: 15.0,
                        onTap: (tapPosition, latLng) {
                          updateZoneCircle(latLng, sliderValue.toDouble());
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.samdev.scavhuntapp',
                        ),
                        CircleLayer(
                          circles: [
                            if (gameTemplate.zones != null &&
                                gameTemplate.zones!.isNotEmpty)
                              for (Zone zone in gameTemplate.zones!.where(
                                  (element) => element.zoneId != currentZoneId))
                                CircleMarker(
                                  point: LatLng(zone.location.latitude,
                                      zone.location.longitude),
                                  color: Colors.redAccent.withOpacity(0.5),
                                  borderStrokeWidth: 1,
                                  borderColor: Colors.redAccent,
                                  useRadiusInMeter: true,
                                  radius: zone.radius.toDouble(),
                                ),
                            if (selectedZoneCircle != null) selectedZoneCircle!,
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The selected location is at $currentLat, $currentLong',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            _buildGlassCard(
              title: 'Zone Radius',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select the radius (in meters) of the zone. This is the area that players must enter to claim the zone.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$sliderValue meters',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Slider(
                    value: sliderValue.toDouble(),
                    min: 10,
                    max: 500,
                    label: '$sliderValue meters',
                    activeColor: Colors.green,
                    inactiveColor: Colors.white70,
                    onChanged: (value) {
                      updateZoneCircle(LatLng(currentLat, currentLong), value);
                      setState(() {
                        sliderValue = value.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),
            _buildGlassCard(
              title: 'Zone Task',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select the task that players must complete to claim the zone.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    dropdownColor: Colors.black,
                    icon: const Icon(FontAwesomeIcons.caretDown,
                        color: Colors.green, size: 16),
                    underline: Container(height: 2, color: Colors.green),
                    value: dropdownValue,
                    items: const [
                      DropdownMenuItem(
                          value: 'question', child: Text('Answer a question')),
                      DropdownMenuItem(
                          value: 'selfie', child: Text('Take a selfie')),
                      DropdownMenuItem(
                          value: 'qrcode', child: Text('Scan a QR code')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  buildTaskFields(),
                ],
              ),
            ),
            _buildGlassCard(
              title: 'Awards',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select the number of points and coins that players will receive when they claim the zone. More points should be awarded for more difficult tasks.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$pointsSliderValue Points',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Slider(
                    value: pointsSliderValue.toDouble(),
                    min: 5,
                    max: 100,
                    label: '$pointsSliderValue Points',
                    activeColor: Colors.green,
                    inactiveColor: Colors.white70,
                    onChanged: (value) {
                      setState(() {
                        pointsSliderValue = value.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$coinsSliderValue Coins',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Slider(
                    value: coinsSliderValue.toDouble(),
                    min: 0,
                    max: 100,
                    label: '$coinsSliderValue Coins',
                    activeColor: Colors.green,
                    inactiveColor: Colors.white70,
                    onChanged: (value) {
                      setState(() {
                        coinsSliderValue = value.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),
            _buildGlassCard(
              title: '',
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: saveZone,
                  child: Text(
                    'Save Zone',
                    style: baseTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildTaskFields() {
    if (dropdownValue == 'question') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlassCard(
            title: '',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTaskTile(
                    'Answer a question',
                    'Players will need to answer a question correctly to claim the zone.',
                    FontAwesomeIcons.question),
                const SizedBox(height: 8),
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'Question',
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
                  style: baseTextStyle.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    labelText: 'Correct Answer',
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
                  style: baseTextStyle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (dropdownValue == 'selfie') {
      return _buildGlassCard(
        title: '',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTaskTile(
                'Take a selfie',
                'Players will need to take a photo of themselves to claim the zone.',
                FontAwesomeIcons.camera),
            const SizedBox(height: 8),
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                labelText: 'Challenge (Optional)',
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
              style: baseTextStyle.copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    } else if (dropdownValue == 'qrcode') {
      return _buildGlassCard(
        title: '',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTaskTile(
                'Scan a QR code',
                'Players will need to scan a QR code to claim the zone.',
                FontAwesomeIcons.qrcode),
            const SizedBox(height: 8),
            TextField(
              controller: qrCodeController,
              decoration: InputDecoration(
                labelText: 'QR Code Value',
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
              style: baseTextStyle.copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget buildTaskTile(String title, String subtitle, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: Icon(icon, color: Colors.white),
      title: Text(title,
          style: baseTextStyle.copyWith(
              fontSize: 18, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle,
          style: baseTextStyle.copyWith(
              fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildGlassCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05)
          ],
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
}
