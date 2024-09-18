import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interactive_bottom_sheet/interactive_bottom_sheet.dart';
import 'package:latlong2/latlong.dart';

import '../../utils/theme_data.dart';
import 'claimzone_1.dart';
import 'claimzone_3.dart';

class ClaimZoneLocPicker extends StatefulWidget {
  const ClaimZoneLocPicker({super.key});

  @override
  State<ClaimZoneLocPicker> createState() => _ClaimZoneLocPickerState();
}

double currentLat = 40.7128;
double currentLong = -74.0060;

class _ClaimZoneLocPickerState extends State<ClaimZoneLocPicker> {
  MapController mapController = MapController();
  Marker? selectedMarker;

  @override
  void initState() {
    super.initState();
  }

  void _onMapTap(TapPosition position, LatLng latLng) {
    setState(() {
      currentLat = latLng.latitude;
      currentLong = latLng.longitude;
      selectedMarker = Marker(
        width: 80.0,
        height: 80.0,
        point: latLng,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              width: 45,
              height: 45,
            ),
            const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ],
        ),
      );
    });
  }

  void _saveLocation() {
    gameTemplate.center = GeoPoint(currentLat, currentLong);
    Get.to(() => const ClaimZone3());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: InteractiveBottomSheet(
        options: InteractiveBottomSheetOptions(
          initialSize: 0.35,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        draggableAreaOptions: DraggableAreaOptions(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          indicatorColor: Theme.of(context).colorScheme.onBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Choose Starting Location',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                subtitle: const Text(
                  'Tap on the map to select the starting location. All zones will be created around this location.',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing:
                    const FaIcon(FontAwesomeIcons.mapPin, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedMarker == null ? Colors.grey : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: selectedMarker == null ? null : _saveLocation,
                  child: Text(
                    'Save Location',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                'Selected Location',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                'Latitude: ${currentLat.toStringAsFixed(4)}\nLongitude: ${currentLong.toStringAsFixed(4)}',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white70,
                ),
              ),
              leading: const FaIcon(FontAwesomeIcons.globe, color: Colors.grey),
              trailing: IconButton(
                icon: const FaIcon(FontAwesomeIcons.pen, color: Colors.white),
                onPressed: () {
                  _showEditLocationDialog(context);
                },
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Starting Location',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(currentLat, currentLong),
          initialZoom: 16.0,
          onTap: _onMapTap,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.samdev.scavhuntapp',
          ),
          if (selectedMarker != null)
            MarkerLayer(
              markers: [selectedMarker!],
            ),
        ],
      ),
    );
  }

  void _showEditLocationDialog(BuildContext context) {
    TextEditingController latController =
        TextEditingController(text: currentLat.toString());
    TextEditingController longController =
        TextEditingController(text: currentLong.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: const Text('Edit Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: latController,
                labelText: 'Latitude',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  _updateCoordinates(value, latController, true);
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: longController,
                labelText: 'Longitude',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  _updateCoordinates(value, longController, false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.spaceGrotesk(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
      keyboardType: keyboardType,
      style: GoogleFonts.spaceGrotesk(color: Colors.white),
      onChanged: onChanged,
    );
  }

  void _updateCoordinates(
      String value, TextEditingController controller, bool isLatitude) {
    if (value.isEmpty) {
      return;
    }
    double? parsedValue = double.tryParse(value);
    if (parsedValue == null ||
        (isLatitude
            ? parsedValue > 90 || parsedValue < -90
            : parsedValue > 180 || parsedValue < -180)) {
      return;
    }
    setState(() {
      if (isLatitude) {
        currentLat = parsedValue;
      } else {
        currentLong = parsedValue;
      }
      _updateMarker(LatLng(currentLat, currentLong));
      mapController.move(
          LatLng(currentLat, currentLong), mapController.camera.zoom);
    });
  }

  void _updateMarker(LatLng position) {
    setState(() {
      selectedMarker = Marker(
        width: 80.0,
        height: 80.0,
        point: position,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              width: 45,
              height: 45,
            ),
            const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ],
        ),
      );
    });
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
                  style: GoogleFonts.spaceGrotesk(
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
