import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scavhuntapp/models/game_template.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

import '../../utils/theme_data.dart';
import 'claimzone_1.dart';
import 'claimzone_view.dart';

// TODO: GPT THIS FILE

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
        pointsPerCoin = item.multiplier?.toDouble() ?? 1;
        coinPrice = item.itemPrice.toDouble();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    itemEdit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemEdit ? 'Edit Coin Shop Item' : 'Add Coin Shop Item'),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (itemEdit)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.trash),
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Preset Items',
              style: baseTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Get.isDarkMode ? Colors.white54 : Colors.black54)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionChip(
                  label: Text('1.5x Boost',
                      style: baseTextStyle.copyWith(fontSize: 18)),
                  backgroundColor: Colors.green,
                  side: BorderSide.none,
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
                  label: Text('2x Boost',
                      style: baseTextStyle.copyWith(fontSize: 18)),
                  backgroundColor: Colors.green,
                  side: BorderSide.none,
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
                  label: Text('15m Sabotage',
                      style: baseTextStyle.copyWith(fontSize: 18)),
                  backgroundColor: Colors.red,
                  side: BorderSide.none,
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
                  label: Text('30m Sabotage',
                      style: baseTextStyle.copyWith(fontSize: 18)),
                  backgroundColor: Colors.red,
                  side: BorderSide.none,
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
                  label: Text('Coin ATM',
                      style: baseTextStyle.copyWith(fontSize: 18)),
                  backgroundColor: Colors.green,
                  side: BorderSide.none,
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
                  label: Text('Task Skip',
                      style: baseTextStyle.copyWith(fontSize: 18)),
                  backgroundColor: Colors.purple,
                  side: BorderSide.none,
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
          const SizedBox(height: 32),
          TextFormField(
            controller: itemNameController,
            decoration: const InputDecoration(
              labelText: 'Item Name',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          Text('Item Type',
              style: baseTextStyle.copyWith(
                  fontSize: 22, fontWeight: FontWeight.w700)),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Point Booster',
                  style: baseTextStyle.copyWith(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  'When players buy this item, they will receive a point multiplier for a set amount of time.',
                  style: baseTextStyle.copyWith(
                      fontSize: 16,
                      color: Get.isDarkMode ? Colors.white54 : Colors.black54),
                ),
              ],
            ),
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
            trailing: Radio(
              value: 'booster',
              groupValue: itemType,
              onChanged: (value) {
                setState(() {
                  itemType = value.toString();
                });
              },
            ),
            onTap: () {
              setState(() {
                itemType = 'booster';
              });
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disabler',
                  style: baseTextStyle.copyWith(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  'When players buy this item, they will be able to disable another team\'s claiming ability for a set amount of time.',
                  style: baseTextStyle.copyWith(
                      fontSize: 16,
                      color: Get.isDarkMode ? Colors.white54 : Colors.black54),
                ),
              ],
            ),
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
            trailing: Radio(
              value: 'disabler',
              groupValue: itemType,
              onChanged: (value) {
                setState(() {
                  itemType = value.toString();
                });
              },
            ),
            onTap: () {
              setState(() {
                itemType = 'disabler';
              });
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Point Exchanger',
                  style: baseTextStyle.copyWith(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Players can exchange coins for points.',
                  style: baseTextStyle.copyWith(
                      fontSize: 16,
                      color: Get.isDarkMode ? Colors.white54 : Colors.black54),
                ),
              ],
            ),
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
            trailing: Radio(
              value: 'coin',
              groupValue: itemType,
              onChanged: (value) {
                setState(() {
                  itemType = value.toString();
                });
              },
            ),
            onTap: () {
              setState(() {
                itemType = 'coin';
              });
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Skipper',
                  style: baseTextStyle.copyWith(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Players can skip a task for a set amount of coins.',
                  style: baseTextStyle.copyWith(
                      fontSize: 16,
                      color: Get.isDarkMode ? Colors.white54 : Colors.black54),
                ),
              ],
            ),
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
            trailing: Radio(
              value: 'skip',
              groupValue: itemType,
              onChanged: (value) {
                setState(() {
                  itemType = value.toString();
                });
              },
            ),
            onTap: () {
              setState(() {
                itemType = 'skip';
              });
            },
          ),
          const SizedBox(height: 16),
          if (itemType != 'skip') const Divider(),
          if (itemType != 'skip') const SizedBox(height: 16),
          if (itemType != 'skip')
            Text(
              'Item Details',
              style: baseTextStyle.copyWith(
                  fontSize: 22, fontWeight: FontWeight.w700),
            ),
          if (itemType != 'skip') const SizedBox(height: 8),
          if (itemType == 'booster')
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    '${pointMultiplier.toStringAsFixed(1)}x multiplier',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Slider(
                  value: pointMultiplier,
                  onChanged: (value) {
                    setState(() {
                      pointMultiplier = value;
                      pointMultiplier =
                          double.parse(pointMultiplier.toStringAsFixed(1));
                    });
                  },
                  min: 1.1,
                  max: 3,
                ),
                const SizedBox(height: 16),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    '${boosterTime.toStringAsFixed(0)} minutes',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Slider(
                  value: boosterTime,
                  onChanged: (value) {
                    setState(() {
                      boosterTime = value;
                      boosterTime.round();
                    });
                  },
                  min: 5,
                  max: 60,
                ),
              ],
            ),
          if (itemType == 'disabler')
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    '${disablerTime.toStringAsFixed(0)} minutes',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Slider(
                  value: disablerTime,
                  onChanged: (value) {
                    setState(() {
                      disablerTime = value;
                      disablerTime.round();
                    });
                  },
                  min: 5,
                  max: 60,
                ),
              ],
            ),
          if (itemType == 'coin')
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    '${pointsPerCoin.toStringAsFixed(0)} points per coin',
                    style: baseTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Slider(
                  value: pointsPerCoin,
                  onChanged: (value) {
                    setState(() {
                      pointsPerCoin = value;
                      pointsPerCoin.round();
                    });
                  },
                  min: 1,
                  max: 20,
                ),
              ],
            ),
          if (itemType != 'skip') const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Coin Price',
            style: baseTextStyle.copyWith(
                fontSize: 22, fontWeight: FontWeight.w700),
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
                coinPrice.round();
              });
            },
            min: 1,
            max: 100,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (itemNameController.text.isEmpty) {
                toastification.show(
                  style: ToastificationStyle.fillColored,
                  applyBlurEffect: true,
                  context: context,
                  type: ToastificationType.error,
                  title: const Text(
                      'To save the coin shop item, please complete all fields.'),
                  autoCloseDuration: const Duration(seconds: 10),
                );
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
                  pointsPerCoin: pointsPerCoin.round(),
                );
                gameTemplate.coinShopItems!.add(item);
              }
              updateGameTemplate(gameTemplate);
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              Get.to(() => const ClaimZoneView());
            },
            child: const Text('Save Item'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
