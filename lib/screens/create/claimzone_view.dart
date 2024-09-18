import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
        title: Text('Game Details', style: baseTextStyle),
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
                    backgroundColor: Colors.black,
                    title: Text('Delete Game', style: baseTextStyle),
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
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlassCard(
              title: '',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.to(() => const ClaimZonePlay());
                      },
                      icon: const FaIcon(FontAwesomeIcons.play,
                          color: Colors.white),
                      label: Text(
                        'Start Game',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        fromInfoPage = true;
                        Get.to(() => const ClaimZone5());
                      },
                      icon: const FaIcon(FontAwesomeIcons.eye,
                          color: Colors.white),
                      label: Text(
                        'Game Preview',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildGlassCard(
              title: '',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  gameTemplate.gameName,
                  style: baseTextStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  gameTemplate.gameDescription,
                  style: baseTextStyle.copyWith(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                trailing: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.penToSquare,
                      color: Colors.white),
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
                            title: Text('Edit Name and Description',
                                style: baseTextStyle),
                            leading: IconButton(
                              icon: const FaIcon(FontAwesomeIcons.xmark),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          backgroundColor: Colors.black,
                          body: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: gameNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Game Name',
                                    labelStyle: baseTextStyle.copyWith(
                                        color: Colors.white70),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white70),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  style: baseTextStyle.copyWith(
                                      color: Colors.white),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: gameDescriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'Game Description',
                                    labelStyle: baseTextStyle.copyWith(
                                        color: Colors.white70),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white70),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  style: baseTextStyle.copyWith(
                                      color: Colors.white),
                                  maxLines: 3,
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
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
                                    child: Text(
                                      'Save',
                                      style: baseTextStyle.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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
            ),
            _buildGlassCard(
              title: 'Start Location',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tap to change the starting location for your game. This is where players will begin their adventure.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FlutterMap(
                        options: MapOptions(
                          initialZoom: 15,
                          initialCenter: _startLocation,
                          onTap: (tapPosition, latLng) {
                            setState(() {
                              _startLocation = latLng;
                            });
                            gameTemplate.center =
                                GeoPoint(latLng.latitude, latLng.longitude);
                            updateGameTemplate(gameTemplate);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: 'com.samdev.scavhuntapp',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _startLocation,
                                width: 60,
                                height: 60,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      width: 45,
                                      height: 45,
                                    ),
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ],
              ),
            ),
            _buildGlassCard(
              title: 'Zones',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add zones to your game. Each zone can have a different number of points and coins.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        edit = false;
                        Get.to(() => const AddZone());
                      },
                      icon: const FaIcon(FontAwesomeIcons.plus,
                          color: Colors.white),
                      label: Text(
                        'Add Zone',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (gameTemplate.zones != null)
                    Column(
                      children: gameTemplate.zones!.map((zone) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            edit = true;
                            fromInfoPage = true;
                            currentZoneId = zone.zoneId;
                            Get.to(() => const AddZone());
                          },
                          leading: const FaIcon(FontAwesomeIcons.locationDot,
                              color: Colors.white),
                          title: Text(
                            zone.zoneName,
                            style: baseTextStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            zone.taskType == 'question'
                                ? 'Answer a question'
                                : zone.taskType == 'selfie'
                                    ? 'Take a selfie'
                                    : 'Scan a QR code',
                            style:
                                baseTextStyle.copyWith(color: Colors.white70),
                          ),
                          trailing: _buildZoneInfoChip(zone),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            _buildGlassCard(
              title: 'Coin Shop Items',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add items to your coin shop. Players can use coins to buy these items.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        itemEdit = false;
                        Get.to(() => const ClaimZoneAddItem());
                      },
                      icon: const FaIcon(FontAwesomeIcons.plus,
                          color: Colors.white),
                      label: Text(
                        'Add Item',
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (gameTemplate.coinShopItems != null)
                    Column(
                      children: gameTemplate.coinShopItems!.map((item) {
                        Color itemColor;
                        IconData iconData;
                        if (item.itemType == 'booster') {
                          itemColor = Colors.green;
                          iconData = FontAwesomeIcons.gem;
                        } else if (item.itemType == 'disabler') {
                          itemColor = Colors.red;
                          iconData = FontAwesomeIcons.ban;
                        } else if (item.itemType == 'coin') {
                          itemColor = Colors.blue;
                          iconData = FontAwesomeIcons.coins;
                        } else {
                          itemColor = Colors.purple;
                          iconData = FontAwesomeIcons.forward;
                        }
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            itemEdit = true;
                            currentItemId = item.itemId;
                            Get.to(() => const ClaimZoneAddItem());
                          },
                          leading: FaIcon(
                            iconData,
                            size: 30,
                            color: itemColor,
                          ),
                          title: Text(
                            item.itemName,
                            style: baseTextStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            item.itemType == 'booster'
                                ? '${item.multiplier}x point booster for ${item.duration} minutes'
                                : item.itemType == 'disabler'
                                    ? 'Disables a team for ${item.duration} minutes'
                                    : item.itemType == 'coin'
                                        ? 'Exchange ${item.itemPrice} coins for ${item.pointsPerCoin! * item.itemPrice} points'
                                        : 'Skip any claim task once',
                            style:
                                baseTextStyle.copyWith(color: Colors.white70),
                          ),
                          trailing: _buildItemInfoChip(item),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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
          const SizedBox(width: 4),
          Text(
            '${item.pointsPerCoin! * item.itemPrice} ',
            style: baseTextStyle.copyWith(
              fontSize: 16,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const FaIcon(
            FontAwesomeIcons.trophy,
            size: 14,
            color: Colors.orange,
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

  Widget _buildGlassCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05)
          ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: baseTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                if (title.isNotEmpty) const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
