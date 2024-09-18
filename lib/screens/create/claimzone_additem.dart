import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

import '../../models/game_template.dart';
import '../../utils/theme_data.dart';
import '../../utils/toastification_helper.dart';
import 'claimzone_1.dart';
import 'claimzone_view.dart';
import 'claimzone_additem.dart';

class ClaimZoneAddItem extends StatefulWidget {
  const ClaimZoneAddItem({super.key});

  @override
  State<ClaimZoneAddItem> createState() => _ClaimZoneAddItemState();
}

bool itemEdit = false;
String currentItemId = '';

class _ClaimZoneAddItemState extends State<ClaimZoneAddItem> {
  TextEditingController itemNameController = TextEditingController();
  String itemType = 'booster';
  double pointMultiplier = 1.5;
  double boosterTime = 15;
  double disablerTime = 15;
  double pointsPerCoin = 1;
  double coinPrice = 5;

  @override
  void initState() {
    super.initState();
    if (itemEdit) {
      CoinShopItem? item = gameTemplate.coinShopItems!
          .firstWhereOrNull((element) => element.itemId == currentItemId);
      if (item != null) {
        itemNameController.text = item.itemName;
        itemType = item.itemType;
        pointMultiplier = item.multiplier?.toDouble() ?? 1.5;
        boosterTime = item.duration?.toDouble() ?? 15;
        disablerTime = item.duration?.toDouble() ?? 15;
        pointsPerCoin = item.pointsPerCoin?.toDouble() ?? 1;
        coinPrice = item.itemPrice.toDouble();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    itemEdit = false;
    itemNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemEdit ? 'Edit Coin Shop Item' : 'Add Coin Shop Item',
            style: baseTextStyle),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (itemEdit)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.trash, color: Colors.white),
              onPressed: () {
                gameTemplate.coinShopItems!
                    .removeWhere((element) => element.itemId == currentItemId);
                updateGameTemplate(gameTemplate);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Get.to(() => const ClaimZoneView());
              },
            ),
        ],
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlassCard(
              title: 'Preset Items',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      side: BorderSide.none,
                      label: Text('1.5x Boost',
                          style: baseTextStyle.copyWith(fontSize: 18)),
                      backgroundColor: Colors.green,
                      onPressed: () {
                        setState(() {
                          itemType = 'booster';
                          pointMultiplier = 1.5;
                          boosterTime = 15;
                          itemNameController.text = 'Point Dash 1.5x';
                          coinPrice = 20;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      side: BorderSide.none,
                      label: Text('2x Boost',
                          style: baseTextStyle.copyWith(fontSize: 18)),
                      backgroundColor: Colors.green,
                      onPressed: () {
                        setState(() {
                          itemType = 'booster';
                          pointMultiplier = 2;
                          boosterTime = 15;
                          itemNameController.text = 'Point Dash 2x';
                          coinPrice = 30;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      side: BorderSide.none,
                      label: Text('15m Sabotage',
                          style: baseTextStyle.copyWith(fontSize: 18)),
                      backgroundColor: Colors.red,
                      onPressed: () {
                        setState(() {
                          itemType = 'disabler';
                          disablerTime = 15;
                          itemNameController.text = '15 Min Sabotage';
                          coinPrice = 25;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      side: BorderSide.none,
                      label: Text('30m Sabotage',
                          style: baseTextStyle.copyWith(fontSize: 18)),
                      backgroundColor: Colors.red,
                      onPressed: () {
                        setState(() {
                          itemType = 'disabler';
                          disablerTime = 30;
                          itemNameController.text = '30 Min Sabotage';
                          coinPrice = 40;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      side: BorderSide.none,
                      label: Text('Coin ATM',
                          style: baseTextStyle.copyWith(fontSize: 18)),
                      backgroundColor: Colors.blue,
                      onPressed: () {
                        setState(() {
                          itemType = 'coin';
                          pointsPerCoin = 1;
                          itemNameController.text = '1-for-1 Coin ATM';
                          coinPrice = 5;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      side: BorderSide.none,
                      label: Text('Task Skip',
                          style: baseTextStyle.copyWith(fontSize: 18)),
                      backgroundColor: Colors.purple,
                      onPressed: () {
                        setState(() {
                          itemType = 'skip';
                          coinPrice = 10;
                          itemNameController.text = 'Task Skip';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildGlassCard(
              title: 'Item Name',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write the name of the item.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: itemNameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      labelStyle: baseTextStyle.copyWith(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: baseTextStyle.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            _buildGlassCard(
              title: 'Item Type',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select the type of the item.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.gem,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      'Point Booster',
                      style: baseTextStyle.copyWith(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'When players buy this item, they will receive a point multiplier for a set amount of time.',
                      style: baseTextStyle.copyWith(
                          fontSize: 16, color: Colors.white70),
                    ),
                    trailing: Radio(
                      value: 'booster',
                      groupValue: itemType,
                      onChanged: (value) {
                        setState(() {
                          itemType = value.toString();
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    onTap: () {
                      setState(() {
                        itemType = 'booster';
                      });
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.ban,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      'Disabler',
                      style: baseTextStyle.copyWith(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'When players buy this item, they will be able to disable another team\'s claiming ability for a set amount of time.',
                      style: baseTextStyle.copyWith(
                          fontSize: 16, color: Colors.white70),
                    ),
                    trailing: Radio(
                      value: 'disabler',
                      groupValue: itemType,
                      onChanged: (value) {
                        setState(() {
                          itemType = value.toString();
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    onTap: () {
                      setState(() {
                        itemType = 'disabler';
                      });
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.coins,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      'Point Exchanger',
                      style: baseTextStyle.copyWith(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Players can exchange coins for points.',
                      style: baseTextStyle.copyWith(
                          fontSize: 16, color: Colors.white70),
                    ),
                    trailing: Radio(
                      value: 'coin',
                      groupValue: itemType,
                      onChanged: (value) {
                        setState(() {
                          itemType = value.toString();
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    onTap: () {
                      setState(() {
                        itemType = 'coin';
                      });
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.purple,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.forward,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      'Task Skipper',
                      style: baseTextStyle.copyWith(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Players can skip a task for a set amount of coins.',
                      style: baseTextStyle.copyWith(
                          fontSize: 16, color: Colors.white70),
                    ),
                    trailing: Radio(
                      value: 'skip',
                      groupValue: itemType,
                      onChanged: (value) {
                        setState(() {
                          itemType = value.toString();
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    onTap: () {
                      setState(() {
                        itemType = 'skip';
                      });
                    },
                  ),
                ],
              ),
            ),
            if (itemType != 'skip')
              _buildGlassCard(
                title: 'Item Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (itemType == 'booster') ...[
                      Text(
                        '${pointMultiplier.toStringAsFixed(1)}x multiplier',
                        style: baseTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Slider(
                        value: pointMultiplier,
                        onChanged: (value) {
                          setState(() {
                            pointMultiplier =
                                double.parse(value.toStringAsFixed(1));
                          });
                        },
                        min: 1.1,
                        max: 3,
                        activeColor: Colors.green,
                        inactiveColor: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${boosterTime.toStringAsFixed(0)} minutes',
                        style: baseTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Slider(
                        value: boosterTime,
                        onChanged: (value) {
                          setState(() {
                            boosterTime = value;
                          });
                        },
                        min: 5,
                        max: 60,
                        activeColor: Colors.green,
                        inactiveColor: Colors.white70,
                      ),
                    ] else if (itemType == 'disabler') ...[
                      Text(
                        '${disablerTime.toStringAsFixed(0)} minutes',
                        style: baseTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Slider(
                        value: disablerTime,
                        onChanged: (value) {
                          setState(() {
                            disablerTime = value;
                          });
                        },
                        min: 5,
                        max: 60,
                        activeColor: Colors.green,
                        inactiveColor: Colors.white70,
                      ),
                    ] else if (itemType == 'coin') ...[
                      Text(
                        '${pointsPerCoin.toStringAsFixed(0)} points per coin',
                        style: baseTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Slider(
                        value: pointsPerCoin,
                        onChanged: (value) {
                          setState(() {
                            pointsPerCoin = value;
                          });
                        },
                        min: 1,
                        max: 20,
                        activeColor: Colors.green,
                        inactiveColor: Colors.white70,
                      ),
                    ],
                  ],
                ),
              ),
            _buildGlassCard(
              title: 'Price',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set the number of coins required to purchase this item.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${coinPrice.round()} coins',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Slider(
                    value: coinPrice,
                    onChanged: (value) {
                      setState(() {
                        coinPrice = value;
                      });
                    },
                    min: 1,
                    max: 100,
                    activeColor: Colors.green,
                    inactiveColor: Colors.white70,
                  ),
                ],
              ),
            ),
            _buildGlassCard(
              title: '',
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (itemNameController.text.isEmpty) {
                      ToastificationHelper.showErrorToast(context,
                          'To save the coin shop item, please complete all fields.');
                      return;
                    }
                    gameTemplate.coinShopItems ??= [];
                    if (itemEdit) {
                      CoinShopItem? item = gameTemplate.coinShopItems!
                          .firstWhereOrNull(
                              (element) => element.itemId == currentItemId);
                      if (item != null) {
                        item.itemName = itemNameController.text;
                        item.itemType = itemType;
                        item.multiplier = pointMultiplier;
                        item.duration = itemType == 'booster'
                            ? boosterTime.round()
                            : itemType == 'disabler'
                                ? disablerTime.round()
                                : 0;
                        item.itemPrice = coinPrice.round();
                        item.pointsPerCoin = pointsPerCoin.round();
                      }
                    } else {
                      CoinShopItem item = CoinShopItem(
                        itemId: const Uuid().v4(),
                        itemName: itemNameController.text,
                        itemDescription: '',
                        itemType: itemType,
                        itemPrice: coinPrice.round(),
                        multiplier: pointMultiplier,
                        duration: itemType == 'booster'
                            ? boosterTime.round()
                            : itemType == 'disabler'
                                ? disablerTime.round()
                                : 0,
                        pointsPerCoin:
                            itemType == 'coin' ? pointsPerCoin.round() : 0,
                      );
                      gameTemplate.coinShopItems!.add(item);
                    }
                    updateGameTemplate(gameTemplate);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Get.to(() => const ClaimZoneView());
                  },
                  child: Text(
                    'Save Item',
                    style: baseTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
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
