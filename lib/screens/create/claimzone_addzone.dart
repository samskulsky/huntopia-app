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
    zone.radius = sliderValue;
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
        title: Text(
          edit ? 'Edit Zone' : 'Add Zone',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white70),
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
              icon: const FaIcon(FontAwesomeIcons.trash, color: Colors.white70),
            ),
        ],
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Zone Details',
                    style: baseTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Configure the zone details including its location, size, and the task players need to complete.',
                    style: baseTextStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: zoneNameController,
                    label: 'Zone Name',
                    hint: 'Enter a name for this zone',
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Zone Location',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            edit ? currentLat : gameTemplate.center!.latitude,
                            edit ? currentLong : gameTemplate.center!.longitude,
                          ),
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
                              if (gameTemplate.zones != null)
                                for (Zone zone in gameTemplate.zones!.where(
                                    (element) =>
                                        element.zoneId != currentZoneId))
                                  CircleMarker(
                                    point: LatLng(zone.location.latitude,
                                        zone.location.longitude),
                                    color: Colors.red.withOpacity(0.3),
                                    borderStrokeWidth: 2,
                                    borderColor: Colors.red,
                                    useRadiusInMeter: true,
                                    radius: zone.radius.toDouble(),
                                  ),
                              if (selectedZoneCircle != null)
                                selectedZoneCircle!,
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Zone Radius',
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$sliderValue meters',
                          style: baseTextStyle.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: sliderValue.toDouble(),
                          min: 10,
                          max: 500,
                          activeColor: Colors.green.shade400,
                          inactiveColor: Colors.white.withOpacity(0.1),
                          onChanged: (value) {
                            updateZoneCircle(
                                LatLng(currentLat, currentLong), value);
                            setState(() {
                              sliderValue = value.toInt();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Zone Task',
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
                        _buildTaskOption(
                          value: 'question',
                          icon: FontAwesomeIcons.question,
                          title: 'Answer a question',
                          subtitle: 'Players must answer correctly to claim',
                          isFirst: true,
                        ),
                        if (dropdownValue == 'question') ...[
                          Divider(
                              color: Colors.white.withOpacity(0.1), height: 1),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: questionController,
                                  label: 'Question',
                                  hint: 'Enter your question',
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: answerController,
                                  label: 'Answer',
                                  hint: 'Enter the correct answer',
                                ),
                              ],
                            ),
                          ),
                        ],
                        Divider(
                            color: Colors.white.withOpacity(0.1), height: 1),
                        _buildTaskOption(
                          value: 'selfie',
                          icon: FontAwesomeIcons.camera,
                          title: 'Take a selfie',
                          subtitle: 'Players must take a photo to claim',
                        ),
                        if (dropdownValue == 'selfie') ...[
                          Divider(
                              color: Colors.white.withOpacity(0.1), height: 1),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _buildTextField(
                              controller: questionController,
                              label: 'Challenge (Optional)',
                              hint: 'Enter a specific photo challenge',
                            ),
                          ),
                        ],
                        Divider(
                            color: Colors.white.withOpacity(0.1), height: 1),
                        _buildTaskOption(
                          value: 'qrcode',
                          icon: FontAwesomeIcons.qrcode,
                          title: 'Scan a QR code',
                          subtitle: 'Players must scan the correct QR code',
                          isLast: true,
                        ),
                        if (dropdownValue == 'qrcode') ...[
                          Divider(
                              color: Colors.white.withOpacity(0.1), height: 1),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _buildTextField(
                              controller: qrCodeController,
                              label: 'QR Code Value',
                              hint: 'Enter the QR code value',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Zone Rewards',
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
                        _buildRewardOption(
                          icon: FontAwesomeIcons.trophy,
                          title: 'Points',
                          value: pointsSliderValue,
                          color: Colors.green.shade400,
                          onChanged: (value) {
                            setState(() {
                              pointsSliderValue = value.toInt();
                            });
                          },
                          isFirst: true,
                        ),
                        Divider(
                            color: Colors.white.withOpacity(0.1), height: 1),
                        _buildRewardOption(
                          icon: FontAwesomeIcons.coins,
                          title: 'Coins',
                          value: coinsSliderValue,
                          color: Colors.purple.shade400,
                          onChanged: (value) {
                            setState(() {
                              coinsSliderValue = value.toInt();
                            });
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextCapitalization capitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: baseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: baseTextStyle.copyWith(
              color: Colors.white38,
              fontStyle: FontStyle.italic,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: baseTextStyle,
          maxLines: maxLines,
          textCapitalization: capitalization,
        ),
      ],
    );
  }

  Widget _buildTaskOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
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
      child: RadioListTile(
        value: value,
        groupValue: dropdownValue,
        onChanged: (value) {
          setState(() {
            dropdownValue = value.toString();
          });
        },
        activeColor: Colors.green.shade400,
        contentPadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            Container(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: baseTextStyle.copyWith(
                      color: Colors.white70,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardOption({
    required IconData icon,
    required String title,
    required int value,
    required Color color,
    required Function(double) onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: baseTextStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    value.toString(),
                    style: baseTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: value.toDouble(),
            min: title == 'Points' ? 5 : 0,
            max: 100,
            activeColor: color,
            inactiveColor: Colors.white.withOpacity(0.1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: saveZone,
              child: Text(
                'Save Zone',
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
