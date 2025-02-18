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
  late LatLngBounds bounds;

  @override
  void initState() {
    super.initState();
    bounds = calculateBounds(gameTemplate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    });
  }

  @override
  void dispose() {
    fromInfoPage = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preview Zones',
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
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(
                gameTemplate.center!.latitude,
                gameTemplate.center!.longitude,
              ),
              initialZoom: 15.0,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.samdev.scavhuntapp',
              ),
              CircleLayer(
                circles: gameTemplate.zones!.map((zone) {
                  return CircleMarker(
                    point:
                        LatLng(zone.location.latitude, zone.location.longitude),
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
                            currentZone.location.longitude),
                        child: Container(
                          alignment: Alignment.center,
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
                          child: Text(
                            currentZone.points.toStringAsFixed(0),
                            style: baseTextStyle.copyWith(
                              fontSize: currentZone.points >= 100
                                  ? 20
                                  : 10 + (currentZone.points / 8 * 2) > 27
                                      ? 27
                                      : 10 + (currentZone.points / 8 * 2),
                              fontWeight: FontWeight.w900,
                              color: _getPointsColor(currentZone.points),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  builder: (context, markers) {
                    int points = 0;
                    List<Zone> zones = gameTemplate.zones!
                        .where((element) => markers.any(
                            (marker) => ValueKey(element.zoneId) == marker.key))
                        .toList();
                    for (var zone in zones) {
                      points += zone.points;
                    }
                    return Container(
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
                      child: Center(
                        child: Text(
                          points.toString(),
                          style: baseTextStyle.copyWith(
                            fontSize: points < 1000 ? 20 : 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.mapPin,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Game Preview',
                              style: baseTextStyle.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${gameTemplate.zones?.length ?? 0} zones created',
                              style: baseTextStyle.copyWith(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
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
                  'Preview Your Game Map',
                  style: baseTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  !fromInfoPage
                      ? 'This is a preview of your zones. If you need to make changes, you can do so later.'
                      : 'If your map was AI-generated and you are unable to look around, the AI may have incorrectly added a zone outside of the main area. If you delete it, you should be able to look around.',
                  style: baseTextStyle.copyWith(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                if (!fromInfoPage) const SizedBox(height: 20),
                if (!fromInfoPage)
                  SizedBox(
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
                      onPressed: () {
                        saveGameTemplate(gameTemplate);
                        Get.offAll(() => const ClaimZone6());
                      },
                      child: Text(
                        'Finish',
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

  Color _getPointsColor(int points) {
    if (points <= 5) return Colors.red;
    if (points <= 10) return Colors.deepOrange;
    if (points <= 15) return Colors.orange;
    if (points <= 20) return Colors.amber;
    if (points <= 25) return Colors.yellow;
    if (points <= 30) return Colors.lime;
    if (points <= 40) return Colors.lightGreen;
    return Colors.green;
  }

  LatLngBounds calculateBounds(GameTemplate currentGameTemplate) {
    if (currentGameTemplate.zones == null ||
        currentGameTemplate.zones!.isEmpty) {
      return LatLngBounds(
        LatLng(currentGameTemplate.center!.latitude - 0.1,
            currentGameTemplate.center!.longitude - 0.1),
        LatLng(currentGameTemplate.center!.latitude + 0.1,
            currentGameTemplate.center!.longitude + 0.1),
      );
    }

    double minLat = currentGameTemplate.zones!.first.location.latitude;
    double maxLat = currentGameTemplate.zones!.first.location.latitude;
    double minLng = currentGameTemplate.zones!.first.location.longitude;
    double maxLng = currentGameTemplate.zones!.first.location.longitude;

    for (var zone in currentGameTemplate.zones!) {
      minLat = min(minLat, zone.location.latitude);
      maxLat = max(maxLat, zone.location.latitude);
      minLng = min(minLng, zone.location.longitude);
      maxLng = max(maxLng, zone.location.longitude);
    }

    double latBuffer = (maxLat - minLat) * 0.2;
    double lngBuffer = (maxLng - minLng) * 0.2;

    return LatLngBounds(
      LatLng(minLat - latBuffer, minLng - lngBuffer),
      LatLng(maxLat + latBuffer, maxLng + lngBuffer),
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
