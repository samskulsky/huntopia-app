import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster_2/flutter_map_marker_cluster.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interactive_bottom_sheet/interactive_bottom_sheet.dart';
import 'package:latlong2/latlong.dart';

import '../../models/game_template.dart';
import '../../utils/theme_data.dart';
import 'claimzone_1.dart';
import 'claimzone_6.dart';
import 'claimzone_addzone.dart';

class ClaimZone5 extends StatefulWidget {
  const ClaimZone5({super.key});

  @override
  State<ClaimZone5> createState() => _ClaimZone5State();
}

class _ClaimZone5State extends State<ClaimZone5> {
  MapController mapController = MapController();

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
        title:
            const Text('Preview Zones', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: _buildFlutterMap(),
    );
  }

  Widget _buildBottomSheet() {
    return InteractiveBottomSheet(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Preview Your Game Map',
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                !fromInfoPage
                    ? 'This is a preview of your zones. If you need to make changes, you can do so later.'
                    : 'If your map was AI-generated and you are unable to look around, the AI may have incorrectly added a zone outside of the main area. If you delete it, you should be able to look around.',
                style:
                    baseTextStyle.copyWith(fontSize: 12, color: Colors.white70),
              ),
              trailing:
                  const FaIcon(FontAwesomeIcons.mapPin, color: Colors.white),
            ),
            if (!fromInfoPage) const SizedBox(height: 16),
            if (!fromInfoPage) _buildFinishButton(),
          ],
        ),
      ),
    );
  }

  LatLngBounds calculateBounds(GameTemplate currentGameTemplate) {
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

    double latBuffer = (maxLat - minLat) * 0.2;
    double lngBuffer = (maxLng - minLng) * 0.2;

    return LatLngBounds(
      LatLng(minLat - latBuffer, minLng - lngBuffer),
      LatLng(maxLat + latBuffer, maxLng + lngBuffer),
    );
  }

  Widget _buildFinishButton() {
    return Container(
      padding: const EdgeInsets.only(left: 16.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          saveGameTemplate(gameTemplate);
          Get.offAll(() => const ClaimZone6());
        },
        child: Text(
          'Finish',
          style: baseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFlutterMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(
            gameTemplate.center!.latitude, gameTemplate.center!.longitude),
        initialZoom: 15.0,
        cameraConstraint: CameraConstraint.containCenter(
            bounds: calculateBounds(gameTemplate)),
        minZoom: 12.0,
        maxZoom: 20.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.samdev.scavhuntapp',
        ),
        CircleLayer(
          circles: gameTemplate.zones!.map((zone) {
            return CircleMarker(
              point: LatLng(zone.location.latitude, zone.location.longitude),
              radius: zone.radius.toDouble(),
              useRadiusInMeter: true,
              color: Colors.grey.withOpacity(0.5),
              borderStrokeWidth: 2,
              borderColor: Colors.grey,
            );
          }).toList(),
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            disableClusteringAtZoom: 18,
            maxClusterRadius: 45,
            showPolygon: false,
            size: const Size(40, 40),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(50),
            maxZoom: 15,
            markers: List<Marker>.generate(
              gameTemplate.zones!.length,
              (index) {
                Zone currentZone = gameTemplate.zones![index];
                return Marker(
                  key: ValueKey(currentZone.zoneId),
                  width: 18 + (currentZone.points / 7 * 2) > 35
                      ? 35
                      : 18 + (currentZone.points / 7 * 2),
                  height: 18 + (currentZone.points / 7 * 2) > 35
                      ? 35
                      : 18 + (currentZone.points / 7 * 2),
                  point: LatLng(currentZone.location.latitude,
                      currentZone.location.longitude), // Location of the marker
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      currentZone.points.toStringAsFixed(0),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: currentZone.points >= 100
                            ? 20
                            : 10 + (currentZone.points / 8 * 2) > 27
                                ? 27
                                : 10 + (currentZone.points / 8 * 2),
                        fontWeight: FontWeight.w900,
                        color: currentZone.points <= 5
                            ? Colors.red
                            : currentZone.points <= 10
                                ? Colors.deepOrange
                                : currentZone.points <= 15
                                    ? Colors.orange
                                    : currentZone.points <= 20
                                        ? Colors.amber
                                        : currentZone.points <= 25
                                            ? Colors.yellow
                                            : currentZone.points <= 30
                                                ? Colors.lime
                                                : currentZone.points <= 40
                                                    ? Colors.lightGreen
                                                    : Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
            builder: (context, markers) {
              int points = 0;
              List<Zone> zones = gameTemplate.zones!
                  .where((element) => markers
                      .any((marker) => ValueKey(element.zoneId) == marker.key))
                  .toList();
              for (var zone in zones) {
                points += zone.points;
              }
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black),
                child: Center(
                  child: Text(
                    points.toString(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: points < 1000 ? 20 : 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget _buildGlassCard({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
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
          child: child,
        ),
      ),
    ),
  );
}
