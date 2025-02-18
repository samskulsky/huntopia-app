import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Starting Location',
          style: baseTextStyle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
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
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.globe,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Location',
                              style: baseTextStyle.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Latitude: ${currentLat.toStringAsFixed(4)}\nLongitude: ${currentLong.toStringAsFixed(4)}',
                              style: baseTextStyle.copyWith(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.pen,
                          color: Colors.white70,
                          size: 18,
                        ),
                        onPressed: () => _showEditLocationDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.black,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Starting Location',
                  style: baseTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tap on the map to select the starting location. All zones will be created around this location.',
                        style: baseTextStyle.copyWith(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const FaIcon(
                      FontAwesomeIcons.mapPin,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedMarker == null
                          ? Colors.grey.shade800
                          : Colors.white,
                      foregroundColor: selectedMarker == null
                          ? Colors.white38
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: selectedMarker == null ? null : _saveLocation,
                    child: Text(
                      'Save Location',
                      style: baseTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onMapTap(TapPosition position, LatLng latLng) {
    setState(() {
      currentLat = latLng.latitude;
      currentLong = latLng.longitude;
      selectedMarker = Marker(
        width: 50.0,
        height: 50.0,
        point: latLng,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    });
  }

  void _saveLocation() {
    gameTemplate.center = GeoPoint(currentLat, currentLong);
    Get.to(() => const ClaimZone3());
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
          backgroundColor: Colors.grey[900],
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Edit Location',
            style: baseTextStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: baseTextStyle.copyWith(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Save',
                style: baseTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
        width: 50.0,
        height: 50.0,
        point: position,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    });
  }
}
