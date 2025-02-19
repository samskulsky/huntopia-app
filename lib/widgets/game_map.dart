import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster_2/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:scavhuntapp/models/game.dart';
import 'package:scavhuntapp/models/game_template.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/cant_claim.dart';
import 'package:scavhuntapp/screens/claimrush_ingame/claim_zone.dart';

import '../screens/claimrush_ingame/purchase_screen.dart';
import '../utils/game_utils.dart';

class GameMap extends StatelessWidget {
  final Game currentGame;
  final GameTemplate currentGameTemplate;
  final Player currentPlayer;
  final List<Zone> unclaimedZones;
  final MapController mapController;
  final bool interaction;
  final List<Widget> children;

  const GameMap({
    super.key,
    required this.currentGame,
    required this.currentGameTemplate,
    required this.currentPlayer,
    required this.unclaimedZones,
    required this.mapController,
    this.interaction = true,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(
              currentGameTemplate.center!.latitude,
              currentGameTemplate.center!.longitude,
            ),
            cameraConstraint: CameraConstraint.containCenter(
                bounds: calculateBounds(currentGameTemplate)),
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
              circles: currentGameTemplate.zones!.map((zone) {
                Player? claimedBy = currentGame.players.firstWhereOrNull(
                    (element) => element.zonesClaimed.contains(zone.zoneId));
                return CircleMarker(
                  point:
                      LatLng(zone.location.latitude, zone.location.longitude),
                  radius: zone.radius.toDouble(),
                  useRadiusInMeter: true,
                  color: claimedBy != null
                      ? getColor(claimedBy.teamColor).withOpacity(0.35)
                      : Colors.grey.withOpacity(0.25),
                  borderStrokeWidth: 3,
                  borderColor: claimedBy != null
                      ? getColor(claimedBy.teamColor)
                      : Colors.grey.withOpacity(0.5),
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
                onMarkerTap: (marker) {
                  if (!interaction) return;
                  _handleMarkerTap(marker);
                },
                markers: _buildMarkers(),
                builder: (context, markers) {
                  int totalPoints = _calculateClusterPoints(markers);
                  int minClusterPoints =
                      unclaimedZones.map((z) => z.points).reduce(min) *
                          markers.length ~/
                          2;
                  int maxClusterPoints =
                      unclaimedZones.map((z) => z.points).reduce(max) *
                          markers.length ~/
                          2;

                  Color clusterColor = _getGradientColor(
                    totalPoints,
                    minClusterPoints,
                    maxClusterPoints,
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
            CurrentLocationLayer(
              style: const LocationMarkerStyle(
                marker: DefaultLocationMarker(
                  child: Icon(
                    Icons.navigation,
                    color: Colors.white,
                  ),
                ),
                markerSize: Size(40, 40),
                accuracyCircleColor: Colors.blue,
              ),
            ),
          ],
        ),
        ...children,
      ],
    );
  }

  void _handleMarkerTap(Marker marker) {
    Zone tappedZone = unclaimedZones
        .firstWhere((element) => ValueKey(element.zoneId) == marker.key);

    if (currentGame.players
        .any((player) => player.zonesClaimed.contains(tappedZone.zoneId))) {
      disabled = false;
      Get.to(() => const CantClaim());
      return;
    }

    if (currentPlayer.sabotagedUntil.isAfter(DateTime.now())) {
      disabled = true;
      Get.to(() => const CantClaim());
      return;
    }

    cGame = currentGame;
    curGame = currentGame;
    curPlayer = currentPlayer;
    currentZone = tappedZone;

    Get.to(() => const ClaimZoneScreen());
  }

  List<Marker> _buildMarkers() {
    // Find min and max points for gradient calculation
    int minPoints = unclaimedZones.map((z) => z.points).reduce(min);
    int maxPoints = unclaimedZones.map((z) => z.points).reduce(max);

    return List<Marker>.generate(
      unclaimedZones.length,
      (index) {
        Zone currentZone = unclaimedZones[index];

        // Calculate marker size based on points
        double markerSize =
            18 + (currentZone.points / maxPoints * 25).clamp(0, 25);

        // Calculate color based on point value position in range
        Color markerColor =
            _getGradientColor(currentZone.points, minPoints, maxPoints);

        return Marker(
          key: ValueKey(currentZone.zoneId),
          width: markerSize,
          height: markerSize,
          point: LatLng(
              currentZone.location.latitude, currentZone.location.longitude),
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
    // Convert point value to position in gradient (0.0 to 1.0)
    double position = (points - minPoints) / (maxPoints - minPoints);
    position = position.clamp(0.0, 1.0);

    // Define gradient colors from low to high points with more granular steps
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

    // Calculate the index in our color array
    int colorIndex = (position * (colors.length - 1)).floor();
    colorIndex = colorIndex.clamp(0, colors.length - 2);

    // Calculate the next color index
    int nextColorIndex = colorIndex + 1;

    // Calculate position between the two colors (0.0 to 1.0)
    double colorPosition = (position * (colors.length - 1)) - colorIndex;
    colorPosition = colorPosition.clamp(0.0, 1.0);

    // Interpolate between the two colors
    return Color.lerp(
      colors[colorIndex],
      colors[nextColorIndex],
      colorPosition,
    )!;
  }

  int _calculateClusterPoints(List<Marker> markers) {
    int points = 0;
    for (var marker in markers) {
      Zone zone = unclaimedZones.firstWhere(
        (z) => ValueKey(z.zoneId) == marker.key,
      );
      points += zone.points;
    }
    return points;
  }

  LatLngBounds calculateBounds(GameTemplate template) {
    double minLat = template.zones!.first.location.latitude;
    double maxLat = template.zones!.first.location.latitude;
    double minLng = template.zones!.first.location.longitude;
    double maxLng = template.zones!.first.location.longitude;

    for (var zone in template.zones!) {
      if (zone.location.latitude < minLat) minLat = zone.location.latitude;
      if (zone.location.latitude > maxLat) maxLat = zone.location.latitude;
      if (zone.location.longitude < minLng) minLng = zone.location.longitude;
      if (zone.location.longitude > maxLng) maxLng = zone.location.longitude;
    }

    double latBuffer = (maxLat - minLat) * 0.2;
    double lngBuffer = (maxLng - minLng) * 0.2;

    return LatLngBounds(
      LatLng(minLat - latBuffer, minLng - lngBuffer),
      LatLng(maxLat + latBuffer, maxLng + lngBuffer),
    );
  }
}
