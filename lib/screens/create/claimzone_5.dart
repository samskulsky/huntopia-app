import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:interactive_bottom_sheet/interactive_bottom_sheet.dart';

import '../../utils/theme_data.dart';
import 'claimzone_1.dart';
import 'claimzone_6.dart';
import '../../models/game_template.dart';
import 'claimzone_addzone.dart';

class ClaimZone5 extends StatefulWidget {
  const ClaimZone5({super.key});

  @override
  State<ClaimZone5> createState() => _ClaimZone5State();
}

class _ClaimZone5State extends State<ClaimZone5> {
  GoogleMapController? mapController;

  @override
  void dispose() {
    fromInfoPage = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: _buildBottomSheet(),
      appBar: AppBar(
        title: const Text('Preview Zones'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildGoogleMap(),
    );
  }

  Widget _buildBottomSheet() {
    return InteractiveBottomSheet(
      options: InteractiveBottomSheetOptions(
        initialSize: 0.35,
        backgroundColor: Get.context!.theme.scaffoldBackgroundColor,
      ),
      draggableAreaOptions: DraggableAreaOptions(
        backgroundColor: Get.context!.theme.scaffoldBackgroundColor,
        indicatorColor: Get.context!.theme.colorScheme.onBackground,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Preview Your Game Map',
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                !fromInfoPage
                    ? 'This is a preview of your zones. If you need to make changes, you can do so later.'
                    : 'This is a preview of your zones.\n\nIf your map was AI-generated and you are unable to look around, the AI may have incorrectly added a zone outside of the main area. If you delete it, you should be able to look around.',
                style: baseTextStyle,
              ),
              trailing: const FaIcon(FontAwesomeIcons.mapPin),
            ),
            if (!fromInfoPage) const SizedBox(height: 16),
            if (!fromInfoPage) _buildFinishButton(),
          ],
        ),
      ),
    );
  }

  CameraTargetBounds calculateBounds(GameTemplate currentGameTemplate) {
    double minLat = currentGameTemplate.zones!.first.location.latitude;
    double maxLat = currentGameTemplate.zones!.first.location.latitude;
    double minLng = currentGameTemplate.zones!.first.location.longitude;
    double maxLng = currentGameTemplate.zones!.first.location.longitude;

    for (var zone in currentGameTemplate.zones!) {
      if (zone.location.latitude < minLat) {
        minLat = zone.location.latitude;
      }
      if (zone.location.latitude > maxLat) {
        maxLat = zone.location.latitude;
      }
      if (zone.location.longitude < minLng) {
        minLng = zone.location.longitude;
      }
      if (zone.location.longitude > maxLng) {
        maxLng = zone.location.longitude;
      }
    }

    // add a 20% buffer to the bounds
    double latBuffer = (maxLat - minLat) * 0.2;
    double lngBuffer = (maxLng - minLng) * 0.2;

    return CameraTargetBounds(
      LatLngBounds(
        southwest: LatLng(minLat - latBuffer, minLng - lngBuffer),
        northeast: LatLng(maxLat + latBuffer, maxLng + lngBuffer),
      ),
    );
  }

  Widget _buildFinishButton() {
    return Container(
      padding: const EdgeInsets.only(left: 16.0),
      child: FilledButton(
        onPressed: () {
          saveGameTemplate(gameTemplate);
          Get.offAll(() => const ClaimZone6());
        },
        child: const Text('Finish'),
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (controller) {
        mapController = controller;
      },
      cameraTargetBounds: calculateBounds(gameTemplate),
      minMaxZoomPreference: const MinMaxZoomPreference(14, 20),
      initialCameraPosition: CameraPosition(
        target: LatLng(
          gameTemplate.center!.latitude,
          gameTemplate.center!.longitude,
        ),
        zoom: 16,
      ),
      markers: _createMarkers(),
      circles: _createCircles(),
    );
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('center'),
        position: LatLng(
          gameTemplate.center!.latitude,
          gameTemplate.center!.longitude,
        ),
        infoWindow: const InfoWindow(title: 'Starting Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    return markers;
  }

  Set<Circle> _createCircles() {
    Set<Circle> circles = {};

    for (var zone in gameTemplate.zones!) {
      circles.add(
        Circle(
          circleId: CircleId(zone.zoneId),
          center: LatLng(zone.location.latitude, zone.location.longitude),
          radius: zone.radius.toDouble(),
          fillColor: Colors.redAccent.withOpacity(0.3),
          strokeColor: Colors.redAccent,
          strokeWidth: 1,
        ),
      );
    }

    return circles;
  }
}
