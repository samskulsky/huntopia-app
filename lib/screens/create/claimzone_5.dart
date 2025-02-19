import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster_2/flutter_map_marker_cluster.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

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
              cameraConstraint: CameraConstraint.containCenter(
                bounds: bounds,
              ),
              initialZoom: 15.0,
              minZoom: 12,
              maxZoom: 20,
              backgroundColor: const Color(0xFF1A1A1A),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.samdev.scavhuntapp',
              ),
              CircleLayer(
                circles: gameTemplate.zones!.map((zone) {
                  return CircleMarker(
                    point:
                        LatLng(zone.location.latitude, zone.location.longitude),
                    radius: zone.radius.toDouble(),
                    useRadiusInMeter: true,
                    color: Colors.grey.withOpacity(0.25),
                    borderStrokeWidth: 3,
                    borderColor: Colors.grey.withOpacity(0.5),
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
                  markers: _buildMarkers(),
                  builder: (context, markers) {
                    int totalPoints = _calculateClusterPoints(markers);
                    int minPoints =
                        gameTemplate.zones!.map((z) => z.points).reduce(min);
                    int maxPoints =
                        gameTemplate.zones!.map((z) => z.points).reduce(max);

                    Color clusterColor = _getGradientColor(
                      totalPoints,
                      minPoints * markers.length ~/ 2,
                      maxPoints * markers.length ~/ 2,
                    );

                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            clusterColor,
                            clusterColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white24,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: clusterColor.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              totalPoints.toString(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
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

  List<Marker> _buildMarkers() {
    int minPoints = gameTemplate.zones!.map((z) => z.points).reduce(min);
    int maxPoints = gameTemplate.zones!.map((z) => z.points).reduce(max);

    return List<Marker>.generate(
      gameTemplate.zones!.length,
      (index) {
        Zone currentZone = gameTemplate.zones![index];
        double markerSize =
            18 + (currentZone.points / maxPoints * 25).clamp(0, 25);
        Color markerColor =
            _getGradientColor(currentZone.points, minPoints, maxPoints);

        return Marker(
          key: ValueKey(currentZone.zoneId),
          width: markerSize,
          height: markerSize,
          point: LatLng(
              currentZone.location.latitude, currentZone.location.longitude),
          rotate: false,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  markerColor,
                  markerColor.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white24,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: markerColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  currentZone.points.toStringAsFixed(0),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: markerSize * 0.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getGradientColor(int points, int minPoints, int maxPoints) {
    double position = (points - minPoints) / (maxPoints - minPoints);
    position = position.clamp(0.0, 1.0);

    List<Color> colors = [
      const Color(0xFFFF5252), // Red
      const Color(0xFFFF7043), // Deep Orange
      const Color(0xFFFF9800), // Orange
      const Color(0xFFFFC107), // Amber
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFFCDDC39), // Lime
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFF4CAF50), // Green
      const Color(0xFF009688), // Teal
    ];

    int colorIndex = (position * (colors.length - 1)).floor();
    colorIndex = colorIndex.clamp(0, colors.length - 2);
    int nextColorIndex = colorIndex + 1;
    double colorPosition = (position * (colors.length - 1)) - colorIndex;
    colorPosition = colorPosition.clamp(0.0, 1.0);

    return Color.lerp(
      colors[colorIndex],
      colors[nextColorIndex],
      colorPosition,
    )!;
  }

  int _calculateClusterPoints(List<Marker> markers) {
    int points = 0;
    for (var marker in markers) {
      Zone zone = gameTemplate.zones!.firstWhere(
        (z) => ValueKey(z.zoneId) == marker.key,
      );
      points += zone.points;
    }
    return points;
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
