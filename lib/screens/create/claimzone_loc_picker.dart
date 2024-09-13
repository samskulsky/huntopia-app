import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:interactive_bottom_sheet/interactive_bottom_sheet.dart';

import 'claimzone_1.dart';
import 'claimzone_3.dart';

class ClaimZoneLocPicker extends StatefulWidget {
  const ClaimZoneLocPicker({super.key});

  @override
  State<ClaimZoneLocPicker> createState() => _ClaimZoneLocPickerState();
}

double currentLat = 0;
double currentLong = 0;

class _ClaimZoneLocPickerState extends State<ClaimZoneLocPicker> {
  GoogleMapController? mapController;
  Marker? selectedMarker;

  @override
  void initState() {
    super.initState();
    _setLocationData();
  }

  Future<void> _setLocationData() async {
    Location location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) return;
    }

    if (await location.hasPermission() == PermissionStatus.denied) {
      if (await location.requestPermission() != PermissionStatus.granted) {
        setState(() {
          currentLat = 40.7128;
          currentLong = -74.0060;
        });
        return;
      }
    }

    final locationData = await location.getLocation();
    setState(() {
      currentLat = locationData.latitude!;
      currentLong = locationData.longitude!;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _updateMarker(LatLng position) {
    setState(() {
      currentLat = position.latitude;
      currentLong = position.longitude;
      selectedMarker = Marker(
        markerId: const MarkerId('selectedLocation'),
        position: position,
        infoWindow: const InfoWindow(title: 'Starting Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });
  }

  void _onMapTap(LatLng position) {
    _updateMarker(position);
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Choose Starting Location',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Tap on the map to select the starting location. All zones will be created around this location.',
                ),
                trailing: const FaIcon(FontAwesomeIcons.mapPin),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton(
                  onPressed: selectedMarker == null ? null : _saveLocation,
                  child: const Text('Save Location'),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: ListTile(
            title: Text(
              'Selected Location',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text('Latitude: $currentLat\nLongitude: $currentLong'),
            leading: const FaIcon(FontAwesomeIcons.globe, color: Colors.grey),
            trailing: IconButton(
              icon: const FaIcon(FontAwesomeIcons.pen),
              onPressed: () {
                _showEditLocationDialog(context);
              },
            ),
          ),
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Starting Location'),
      ),
      body: currentLat != 0 && currentLong != 0
          ? GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLat, currentLong),
                zoom: 16,
              ),
              markers: selectedMarker != null ? {selectedMarker!} : {},
              onTap: _onMapTap,
            )
          : const Center(
              child: SpinKitFadingCube(
                color: Colors.green,
                size: 30.0,
              ),
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
              TextField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  _updateCoordinates(value, latController, true);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: longController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                ),
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

  void _updateCoordinates(
      String value, TextEditingController controller, bool isLatitude) {
    if (value.isEmpty ||
        (isLatitude
            ? double.parse(value) > 90 || double.parse(value) < -90
            : double.parse(value) > 180 || double.parse(value) < -180)) {
      return;
    }
    setState(() {
      if (isLatitude) {
        currentLat = double.parse(value);
      } else {
        currentLong = double.parse(value);
      }
      _updateMarker(LatLng(currentLat, currentLong));
    });
  }
}
