import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster_2/flutter_map_marker_cluster.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    Key? key,
    required this.currentGame,
    required this.currentGameTemplate,
    required this.currentPlayer,
    required this.unclaimedZones,
    required this.mapController,
    this.interaction = true,
    this.children = const [],
  }) : super(key: key);

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
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
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
                      ? getColor(claimedBy.teamColor).withOpacity(0.75)
                      : Colors.grey.withOpacity(0.5),
                  borderStrokeWidth: 2,
                  borderColor: claimedBy != null
                      ? getColor(claimedBy.teamColor)
                      : Colors.grey,
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
                  return _buildClusterMarker(markers);
                },
              ),
            ),
            CurrentLocationLayer(),
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
    return List<Marker>.generate(
      unclaimedZones.length,
      (index) {
        Zone currentZone = unclaimedZones[index];
        return Marker(
          key: ValueKey(currentZone.zoneId),
          width: 18 + (currentZone.points / 7 * 2) > 35
              ? 35
              : 18 + (currentZone.points / 7 * 2),
          height: 18 + (currentZone.points / 7 * 2) > 35
              ? 35
              : 18 + (currentZone.points / 7 * 2),
          point: LatLng(
              currentZone.location.latitude, currentZone.location.longitude),
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Text(
              currentZone.points.toStringAsFixed(0),
              style: GoogleFonts.spaceGrotesk(
                fontSize: _calculateFontSize(currentZone.points),
                fontWeight: FontWeight.w900,
                color: _getPointColor(currentZone.points),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClusterMarker(List<Marker> markers) {
    int points = 0;
    List<Zone> zones = unclaimedZones
        .where((element) =>
            markers.any((marker) => ValueKey(element.zoneId) == marker.key))
        .toList();
    for (var zone in zones) {
      points += zone.points;
    }
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.black),
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
  }

  double _calculateFontSize(int points) {
    if (points >= 100) return 20;
    return 10 + (points / 8 * 2) > 27 ? 27 : 10 + (points / 8 * 2);
  }

  Color _getPointColor(int points) {
    if (points <= 5) return Colors.red;
    if (points <= 10) return Colors.deepOrange;
    if (points <= 15) return Colors.orange;
    if (points <= 20) return Colors.amber;
    if (points <= 25) return Colors.yellow;
    if (points <= 30) return Colors.lime;
    if (points <= 40) return Colors.lightGreen;
    return Colors.green;
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
