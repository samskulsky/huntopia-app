import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:scavhuntapp/models/game_template.dart';
import 'package:scavhuntapp/screens/create/claimzone_1.dart';
import 'package:scavhuntapp/screens/create/claimzone_5.dart';
import 'package:scavhuntapp/screens/create/claimzone_additem.dart';
import 'package:scavhuntapp/screens/create/claimzone_addzone.dart';
import 'package:scavhuntapp/screens/create/claimzone_play.dart';
import 'package:scavhuntapp/screens/home_screen.dart';
import 'package:scavhuntapp/widgets/gradient_background.dart';

import '../../utils/theme_data.dart';

class ClaimZoneView extends StatefulWidget {
  const ClaimZoneView({super.key});

  @override
  State<ClaimZoneView> createState() => _ClaimZoneViewState();
}

class _ClaimZoneViewState extends State<ClaimZoneView> {
  LatLng _startLocation = LatLng(
    gameTemplate.center!.latitude,
    gameTemplate.center!.longitude,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Game Details',
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
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.trash, color: Colors.white70),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Get.to(() => const ClaimZonePlay()),
                      icon: const FaIcon(FontAwesomeIcons.play),
                      label: Text(
                        'Start Game',
                        style: baseTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  width: 56,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                    ),
                    onPressed: () {
                      fromInfoPage = true;
                      Get.to(() => const ClaimZone5());
                    },
                    child: const FaIcon(
                      FontAwesomeIcons.eye,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gameTemplate.gameName,
                        style: baseTextStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gameTemplate.gameDescription,
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.penToSquare,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _showEditDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Starting Location',
                  style: baseTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showLocationPicker(context),
                  icon: const FaIcon(FontAwesomeIcons.locationDot, size: 16),
                  label: const Text('Change Location'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.globe,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                title: Text(
                  'Center Coordinates',
                  style: baseTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Lat: ${gameTemplate.center!.latitude.toStringAsFixed(4)}\nLng: ${gameTemplate.center!.longitude.toStringAsFixed(4)}',
                  style: baseTextStyle.copyWith(
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Game Zones',
                  style: baseTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    edit = false;
                    fromInfoPage = true;
                    Get.to(() => const AddZone());
                  },
                  icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                  label: const Text('Add Zone'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  ...gameTemplate.zones!
                      .map((zone) => Column(
                            children: [
                              _buildZoneItem(zone),
                              if (zone != gameTemplate.zones!.last)
                                Divider(
                                  color: Colors.white.withOpacity(0.1),
                                  height: 1,
                                ),
                            ],
                          ))
                      .toList(),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Coin Shop',
                  style: baseTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    itemEdit = false;
                    fromInfoPage = true;
                    Get.to(() => const ClaimZoneAddItem());
                  },
                  icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (gameTemplate.coinShopItems != null &&
                gameTemplate.coinShopItems!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    ...gameTemplate.coinShopItems!
                        .map((item) => Column(
                              children: [
                                _buildShopItem(item),
                                if (item != gameTemplate.coinShopItems!.last)
                                  Divider(
                                    color: Colors.white.withOpacity(0.1),
                                    height: 1,
                                  ),
                              ],
                            ))
                        .toList(),
                  ],
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneItem(Zone zone) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      onTap: () {
        edit = true;
        currentZoneId = zone.zoneId;
        fromInfoPage = true;
        Get.to(() => const AddZone());
      },
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: FaIcon(
            _getTaskIcon(zone.taskType),
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      title: Text(
        zone.zoneName,
        style: baseTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _getTaskDescription(zone.taskType),
        style: baseTextStyle.copyWith(
          fontSize: 14,
          color: Colors.white70,
          height: 1.3,
        ),
      ),
      trailing: _buildZoneInfoChip(zone),
    );
  }

  Widget _buildShopItem(CoinShopItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      onTap: () {
        itemEdit = true;
        currentItemId = item.itemId;
        fromInfoPage = true;
        Get.to(() => const ClaimZoneAddItem());
      },
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: FaIcon(
            _getItemIcon(item.itemType),
            color: _getItemColor(item.itemType),
            size: 16,
          ),
        ),
      ),
      title: Text(
        item.itemName,
        style: baseTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _getItemDescription(item),
        style: baseTextStyle.copyWith(
          fontSize: 14,
          color: Colors.white70,
          height: 1.3,
        ),
      ),
      trailing: _buildItemInfoChip(item),
    );
  }

  IconData _getItemIcon(String itemType) {
    switch (itemType) {
      case 'booster':
        return FontAwesomeIcons.gem;
      case 'disabler':
        return FontAwesomeIcons.ban;
      case 'coin':
        return FontAwesomeIcons.coins;
      default:
        return FontAwesomeIcons.forward;
    }
  }

  Color _getItemColor(String itemType) {
    switch (itemType) {
      case 'booster':
        return Colors.green;
      case 'disabler':
        return Colors.red;
      case 'coin':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  String _getItemDescription(CoinShopItem item) {
    switch (item.itemType) {
      case 'booster':
        return '${item.multiplier}x point booster for ${item.duration} minutes';
      case 'disabler':
        return 'Disables a team for ${item.duration} minutes';
      case 'coin':
        return 'Exchange ${item.itemPrice} coins for ${item.pointsPerCoin! * item.itemPrice} points';
      default:
        return 'Skip any claim task once';
    }
  }

  Widget _buildItemInfoChip(CoinShopItem item) {
    return Chip(
      side: BorderSide.none,
      backgroundColor: Colors.white.withOpacity(0.1),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${item.itemPrice} ',
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          const FaIcon(
            FontAwesomeIcons.coins,
            size: 14,
            color: Colors.yellow,
          ),
        ],
      ),
    );
  }

  Widget _buildZoneInfoChip(Zone zone) {
    return Chip(
      padding: const EdgeInsets.all(0),
      backgroundColor: Colors.white,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${zone.points} ',
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.deepOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
          const FaIcon(
            FontAwesomeIcons.trophy,
            size: 14,
            color: Colors.deepOrange,
          ),
          const SizedBox(width: 4),
          Text(
            '${zone.coins} ',
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
          const FaIcon(
            FontAwesomeIcons.coins,
            size: 14,
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text('Delete Game',
              style: baseTextStyle.copyWith(color: Colors.white70)),
          content: Text(
            'Are you sure you want to delete this game? This action cannot be undone.',
            style: baseTextStyle.copyWith(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: baseTextStyle.copyWith(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                deleteGameTemplate(gameTemplate.templateId);
                Navigator.of(context).pop();
                Get.offAll(() => const HomeScreen());
              },
              child: Text('Delete',
                  style: baseTextStyle.copyWith(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController gameNameController =
        TextEditingController(text: gameTemplate.gameName);
    TextEditingController gameDescriptionController =
        TextEditingController(text: gameTemplate.gameDescription);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Edit Game',
              style: baseTextStyle.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          backgroundColor: Colors.black,
          body: GradientBackground(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Game Name',
                  style: baseTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: gameNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter game name',
                    hintStyle: baseTextStyle.copyWith(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green.shade400),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: baseTextStyle.copyWith(color: Colors.white),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),
                Text(
                  'Game Description',
                  style: baseTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: gameDescriptionController,
                  decoration: InputDecoration(
                    hintText: 'Enter game description',
                    hintStyle: baseTextStyle.copyWith(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green.shade400),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: baseTextStyle.copyWith(color: Colors.white),
                  maxLines: 3,
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
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
                      setState(() {
                        gameTemplate.gameName = gameNameController.text;
                        gameTemplate.gameDescription =
                            gameDescriptionController.text;
                      });
                      updateGameTemplate(gameTemplate);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Save Changes',
                      style: baseTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLocationPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Change Location',
            style: baseTextStyle.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        backgroundColor: Colors.black,
        body: _LocationPickerContent(
          initialLocation: LatLng(
            gameTemplate.center!.latitude,
            gameTemplate.center!.longitude,
          ),
          onLocationSelected: (location) {
            setState(() {
              gameTemplate.center =
                  GeoPoint(location.latitude, location.longitude);
            });
            updateGameTemplate(gameTemplate);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  IconData _getTaskIcon(String taskType) {
    switch (taskType) {
      case 'question':
        return FontAwesomeIcons.question;
      case 'selfie':
        return FontAwesomeIcons.camera;
      case 'qrcode':
        return FontAwesomeIcons.qrcode;
      default:
        return FontAwesomeIcons.locationDot;
    }
  }

  String _getTaskDescription(String taskType) {
    switch (taskType) {
      case 'question':
        return 'Answer a question';
      case 'selfie':
        return 'Take a selfie';
      case 'qrcode':
        return 'Scan a QR code';
      default:
        return 'Unknown task';
    }
  }
}

class _LocationPickerContent extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationSelected;

  const _LocationPickerContent({
    required this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<_LocationPickerContent> createState() => _LocationPickerContentState();
}

class _LocationPickerContentState extends State<_LocationPickerContent> {
  late MapController mapController;
  Marker? selectedMarker;
  late LatLng currentLocation;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    currentLocation = widget.initialLocation;
    selectedMarker = _createMarker(currentLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: currentLocation,
                  initialZoom: 15.0,
                  onTap: _onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.samdev.scavhuntapp',
                  ),
                  if (selectedMarker != null)
                    MarkerLayer(markers: [selectedMarker!]),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
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
                  onPressed: () => widget.onLocationSelected(currentLocation),
                  child: Text(
                    'Save Location',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onMapTap(TapPosition position, LatLng location) {
    setState(() {
      currentLocation = location;
      selectedMarker = _createMarker(location);
    });
  }

  Marker _createMarker(LatLng position) {
    return Marker(
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
  }
}
