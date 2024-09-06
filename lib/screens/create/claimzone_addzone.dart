import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scavhuntapp/screens/create/claimzone_1.dart';
import 'package:scavhuntapp/screens/create/claimzone_4.dart';
import 'package:scavhuntapp/screens/create/claimzone_loc_picker.dart' as loc;
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

import '../../models/game_template.dart';
import '../../utils/theme_data.dart';
import 'claimzone_view.dart';

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

  late GoogleMapController mapController;
  String dropdownValue = 'question';

  int sliderValue = 30;
  int pointsSliderValue = 10;
  int coinsSliderValue = 5;
  double currentLat =
      loc.currentLat != 0 ? loc.currentLat : gameTemplate.center!.latitude;
  double currentLong =
      loc.currentLong != 0 ? loc.currentLong : gameTemplate.center!.longitude;
  Circle? selectedZoneCircle;

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
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Circle createCircle(LatLng latLng, double radius) {
    return Circle(
      circleId: const CircleId("selectedZone"),
      center: latLng,
      radius: radius,
      fillColor: Colors.redAccent.withOpacity(0.3),
      strokeColor: Colors.redAccent,
      strokeWidth: 1,
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
    toastification.show(
      style: ToastificationStyle.fillColored,
      applyBlurEffect: true,
      context: context,
      type: ToastificationType.error,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 10),
    );
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
        title: const Text('Add Zone'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildTitleSection('Zone Editor',
              'Complete the following fields to add a zone to your game.'),
          buildTextField('1', 'Zone Name', zoneNameController,
              'Write the name of the zone you want to add.'),
          buildMapSection(),
          buildSliderSection('Zone Radius',
              'Select the radius (in meters) of the zone. This is the area that players must enter to claim the zone.'),
          buildDropdownSection(),
          buildAwardsSection(),
          buildSaveButton(),
        ],
      ),
    );
  }

  Widget buildTitleSection(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: baseTextStyle.copyWith(
                fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(subtitle,
            style: baseTextStyle.copyWith(
                fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildTextField(String num, String label,
      TextEditingController controller, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: buildCircleAvatar(num),
          title: Text(label,
              style: baseTextStyle.copyWith(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          subtitle: subtitle.isNotEmpty
              ? Text(subtitle,
                  style: baseTextStyle.copyWith(
                      fontSize: 16, fontWeight: FontWeight.w500))
              : null,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          style:
              baseTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: buildCircleAvatar('2'),
          title: Text('Zone Location',
              style: baseTextStyle.copyWith(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          subtitle: Text('Select the location of the zone on the map.',
              style: baseTextStyle.copyWith(
                  fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 8),
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26, width: 2),
          ),
          child: GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
                target: LatLng(currentLat, currentLong), zoom: 15.0),
            circles: selectedZoneCircle != null ? {selectedZoneCircle!} : {},
            onTap: (latLng) => updateZoneCircle(latLng, sliderValue.toDouble()),
            gestureRecognizers: Set()
              ..add(Factory<EagerGestureRecognizer>(
                  () => EagerGestureRecognizer())),
            myLocationButtonEnabled: false,
            indoorViewEnabled: true,
          ),
        ),
        const SizedBox(height: 8),
        Text('The selected location is at $currentLat, $currentLong',
            style: baseTextStyle.copyWith(
                fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildSliderSection(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: buildCircleAvatar('3'),
            title: Text(title,
                style: baseTextStyle.copyWith(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            subtitle: Text(subtitle,
                style: baseTextStyle.copyWith(
                    fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Text('$sliderValue meters',
              style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.green)),
          Slider(
            value: sliderValue.toDouble(),
            min: 10,
            max: 500,
            label: '$sliderValue meters',
            onChanged: (value) {
              updateZoneCircle(LatLng(currentLat, currentLong), value);
              sliderValue = value.toInt();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildDropdownSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: buildCircleAvatar('4'),
            title: Text('Zone Task',
                style: baseTextStyle.copyWith(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            subtitle: Text(
                'Select the task that players must complete to claim the zone.',
                style: baseTextStyle.copyWith(
                    fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.green),
              dropdownColor: Colors.black,
              icon: const Icon(FontAwesomeIcons.caretDown,
                  color: Colors.green, size: 16),
              underline: Container(height: 2, color: Colors.green),
              value: dropdownValue,
              items: const [
                DropdownMenuItem(
                    value: 'question', child: Text('Answer a question ')),
                DropdownMenuItem(
                    value: 'selfie', child: Text('Take a selfie ')),
                DropdownMenuItem(
                    value: 'qrcode', child: Text('Scan a QR code ')),
              ],
              onChanged: (value) => setState(() => dropdownValue = value!),
            ),
          ),
          buildTaskFields(),
        ],
      ),
    );
  }

  Widget buildTaskFields() {
    if (dropdownValue == 'question') {
      return buildQuestionFields();
    } else if (dropdownValue == 'selfie') {
      return buildSelfieField();
    } else if (dropdownValue == 'qrcode') {
      return buildQRCodeField();
    }
    return const SizedBox();
  }

  Widget buildQuestionFields() {
    return Card(
      child: Column(
        children: [
          buildTaskTile(
              'Answer a question',
              'Players will need to answer a question correctly to claim the zone.',
              FontAwesomeIcons.question),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buildTextField('A', 'Question', questionController, ''),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buildTextField('B', 'Correct Answer', answerController, ''),
          ),
        ],
      ),
    );
  }

  Widget buildSelfieField() {
    return Card(
      child: Column(
        children: [
          buildTaskTile(
              'Take a selfie',
              'Players will need to take a photo of themselves to claim the zone.',
              FontAwesomeIcons.camera),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buildTextField('A', 'Challenge', questionController, ''),
          ),
        ],
      ),
    );
  }

  Widget buildQRCodeField() {
    return Card(
      child: Column(
        children: [
          buildTaskTile(
              'Scan a QR code',
              'Players will need to scan a QR code to claim the zone.',
              FontAwesomeIcons.qrcode),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buildTextField('A', 'QR Code Value', qrCodeController, ''),
          ),
        ],
      ),
    );
  }

  Widget buildTaskTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title,
          style: baseTextStyle.copyWith(
              fontSize: 18, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
    );
  }

  Widget buildAwardsSection() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: buildCircleAvatar('5'),
          title: Text('Awards',
              style: baseTextStyle.copyWith(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          subtitle: Text(
            'Select the number of points and coins that players will receive when they claim the zone. More points should be awarded for more difficult tasks.',
            style: baseTextStyle.copyWith(
                fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        buildAwardSlider('Points', pointsSliderValue,
            (value) => setState(() => pointsSliderValue = value)),
        buildAwardSlider('Coins', coinsSliderValue,
            (value) => setState(() => coinsSliderValue = value)),
      ],
    );
  }

  Widget buildAwardSlider(
      String label, int value, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text('$value $label',
            style: baseTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.green)),
        Slider(
          value: value.toDouble(),
          min: 5,
          max: 100,
          label: '$value $label',
          onChanged: (newValue) => onChanged(newValue.toInt()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FilledButton(
        onPressed: saveZone,
        child: const Text('Save Zone'),
      ),
    );
  }

  CircleAvatar buildCircleAvatar(String number) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: Colors.green,
      child: Text(number,
          style: baseTextStyle.copyWith(
              fontSize: 20, fontWeight: FontWeight.w700)),
    );
  }
}
