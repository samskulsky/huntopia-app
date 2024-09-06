import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scavhuntapp/models/game_template.dart';
import 'package:scavhuntapp/screens/create/claimzone_1.dart';
import 'package:scavhuntapp/screens/create/claimzone_5.dart';
import 'package:scavhuntapp/screens/create/claimzone_additem.dart';
import 'package:scavhuntapp/screens/create/claimzone_addzone.dart';
import 'package:scavhuntapp/screens/create/claimzone_play.dart';
import 'package:scavhuntapp/screens/home_screen.dart';

// TODO: GPT

class ClaimZoneView extends StatefulWidget {
  const ClaimZoneView({super.key});

  @override
  State<ClaimZoneView> createState() => _ClaimZoneViewState();
}

class _ClaimZoneViewState extends State<ClaimZoneView> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _startLocation = LatLng(
    gameTemplate.center!.latitude,
    gameTemplate.center!.longitude,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.trash),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Get.isDarkMode
                        ? const Color(0xFF333333)
                        : const Color(0xFFf4f4f4),
                    title: const Text('Delete Game'),
                    content: const Text(
                        'Are you sure you want to delete this game? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteGameTemplate(gameTemplate.templateId);
                          Navigator.of(context).pop();
                          Get.offAll(() => const HomeScreen());
                        },
                        child: Text('Delete',
                            style: GoogleFonts.spaceGrotesk(
                                color: Colors.red,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (gameTemplate.creatorName == 'AI Game Creator')
            Card(
              child: ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.wandMagicSparkles,
                ),
                title: Text('AI Generated',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    )),
                subtitle: Text(
                  'This game was generated using AI, which is prone to errors. Please review the game details carefully. Check each zone, confirming it is in the correct location and has the correct task. If you need to make changes, you can do so below.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (gameTemplate.creatorName == 'AI Game Creator')
            const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Get.to(() => const ClaimZonePlay());
            },
            label: const Text('Start Game'),
            icon: const FaIcon(FontAwesomeIcons.play),
          ),
          TextButton.icon(
            onPressed: () {
              fromInfoPage = true;
              Get.to(() => const ClaimZone5());
            },
            label: Text('Game Preview',
                style: GoogleFonts.spaceGrotesk(fontSize: 18)),
            icon: const FaIcon(FontAwesomeIcons.eye, size: 18),
          ),
          ListTile(
            visualDensity: const VisualDensity(vertical: -4),
            contentPadding: EdgeInsets.zero,
            title: Text(gameTemplate.gameName,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 24, fontWeight: FontWeight.w900)),
            subtitle: Text(gameTemplate.gameDescription),
            trailing: IconButton(
              icon: const FaIcon(FontAwesomeIcons.penToSquare),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (BuildContext context) {
                    TextEditingController gameNameController =
                        TextEditingController(text: gameTemplate.gameName);
                    TextEditingController gameDescriptionController =
                        TextEditingController(
                            text: gameTemplate.gameDescription);
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Edit Name and Description'),
                        leading: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.xmark),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: gameNameController,
                              decoration: const InputDecoration(
                                labelText: 'Game Name',
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: gameDescriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Game Description',
                              ),
                              maxLines: 3,
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () {
                                setState(() {
                                  gameTemplate.gameName =
                                      gameNameController.text;
                                  gameTemplate.gameDescription =
                                      gameDescriptionController.text;
                                });
                                updateGameTemplate(gameTemplate);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ));
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Start Location',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const Text(
            'Tap to change the starting location for your game. This is where players will begin their adventure.',
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: Get.isDarkMode ? Colors.black26 : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _startLocation,
                zoom: 15.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: {
                Marker(
                  markerId: const MarkerId('startLocation'),
                  position: _startLocation,
                  infoWindow: const InfoWindow(
                    title: 'Starting Location',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              },
              onTap: (LatLng latLng) async {
                final GoogleMapController controller = await _controller.future;
                setState(() {
                  _startLocation = latLng;
                  // Update the marker position
                  // You need to manage the marker state
                });
                gameTemplate.center =
                    GeoPoint(latLng.latitude, latLng.longitude);
                updateGameTemplate(gameTemplate);
              },
              gestureRecognizers: Set()
                ..add(Factory<EagerGestureRecognizer>(
                    () => EagerGestureRecognizer())),
              myLocationButtonEnabled: false,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (BuildContext context) => const ClaimZoneAddItem(),
                ),
              );
            },
            icon: const FaIcon(FontAwesomeIcons.plus),
            label: const Text('Add Item'),
          ),
          const SizedBox(height: 16),
          Text(
            'Zones',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const Text(
            'Add zones to your game. Each zone can have a different number of points and coins.',
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.circlePlus),
            contentPadding: EdgeInsets.zero,
            title: Text('Add Zone',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            subtitle: const Text('Add a new zone to your game.'),
            onTap: () {
              edit = false;
              fromInfoPage = true;
              Get.to(() => const AddZone());
            },
          ),
          if (gameTemplate.zones != null)
            for (var zone in gameTemplate.zones!)
              Card(
                child: ListTile(
                  onTap: () {
                    edit = true;
                    fromInfoPage = true;
                    currentZoneId = zone.zoneId;
                    Get.to(() => const AddZone());
                  },
                  leading: const FaIcon(FontAwesomeIcons.locationDot),
                  title: Text(zone.zoneName,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  subtitle: Text(zone.taskType == 'question'
                      ? 'Answer a question'
                      : zone.taskType == 'selfie'
                          ? 'Take a selfie'
                          : 'Scan a QR code'),
                  trailing: Chip(
                    padding: const EdgeInsets.all(0),
                    backgroundColor: Colors.white,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${zone.points} ',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w700)),
                        const FaIcon(
                          FontAwesomeIcons.trophy,
                          size: 14,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(width: 4),
                        Text('${zone.coins} ',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w700)),
                        const FaIcon(
                          FontAwesomeIcons.coins,
                          size: 14,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 16),
          Text(
            'Coin Shop Items',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const Text(
            'Add items to your coin shop. Players can use coins to buy these items.',
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.circlePlus),
            contentPadding: EdgeInsets.zero,
            title: Text('Add Item',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            subtitle: const Text('Add a new item to your coin shop.'),
            onTap: () {
              Get.to(() => const ClaimZoneAddItem());
            },
          ),
          if (gameTemplate.coinShopItems != null)
            for (var item in gameTemplate.coinShopItems!)
              Card(
                color: item.itemType == 'booster'
                    ? Colors.green.withOpacity(0.5)
                    : item.itemType == 'disabler'
                        ? Colors.red.withOpacity(0.5)
                        : item.itemType == 'coin'
                            ? Colors.blue.withOpacity(0.5)
                            : Colors.purple.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: item.itemType == 'booster'
                        ? Colors.green
                        : item.itemType == 'disabler'
                            ? Colors.red
                            : item.itemType == 'coin'
                                ? Colors.blue
                                : Colors.purple,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    itemEdit = true;
                    currentItemId = item.itemId;
                    Get.to(() => const ClaimZoneAddItem());
                  },
                  leading: item.itemType == 'booster'
                      ? const FaIcon(FontAwesomeIcons.gem, size: 30)
                      : item.itemType == 'disabler'
                          ? const FaIcon(FontAwesomeIcons.ban, size: 30)
                          : item.itemType == 'coin'
                              ? const FaIcon(FontAwesomeIcons.coins, size: 30)
                              : const FaIcon(FontAwesomeIcons.forward,
                                  size: 30),
                  title: Text(item.itemName,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  subtitle: Text(item.itemType == 'booster'
                      ? '${item.multiplier}x point booster for ${item.duration} minutes'
                      : item.itemType == 'disabler'
                          ? 'Disables a team for ${item.duration} minutes'
                          : item.itemType == 'coin'
                              ? 'Exchange ${item.itemPrice} coins for ${item.pointsPerCoin! * item.itemPrice} points'
                              : 'Skip any claim task once'),
                  trailing: Chip(
                    padding: const EdgeInsets.all(0),
                    color: MaterialStateProperty.resolveWith(
                        (states) => Colors.white),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${item.itemPrice} ',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w700)),
                        const FaIcon(
                          FontAwesomeIcons.coins,
                          size: 16,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
