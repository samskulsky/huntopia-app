import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../models/game_template.dart';
import '../../utils/theme_data.dart';
import '../../utils/toastification_helper.dart';
import 'claimzone_1.dart';
import 'claimzone_view.dart';
import 'package:scavhuntapp/widgets/gradient_background.dart';

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
        title: Text(
          itemEdit ? 'Edit Item' : 'Add Item',
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
          if (itemEdit)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.trash, color: Colors.white70),
              onPressed: () {
                gameTemplate.coinShopItems!
                    .removeWhere((element) => element.itemId == currentItemId);
                updateGameTemplate(gameTemplate);
                Navigator.pop(context);
                setState(() {});
                ToastificationHelper.showSuccessToast(
                    context, 'Item deleted successfully!');
              },
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
            Text(
              'Item Name',
              style: baseTextStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: itemNameController,
              decoration: InputDecoration(
                hintText: 'Enter item name',
                hintStyle: baseTextStyle.copyWith(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade400),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: baseTextStyle.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text(
              'Item Type',
              style: baseTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
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
                  _buildItemTypeOption(
                    icon: FontAwesomeIcons.gem,
                    iconColor: Colors.green,
                    title: 'Point Booster',
                    subtitle:
                        'When players buy this item, they will receive a point multiplier for a set amount of time.',
                    value: 'booster',
                    isFirst: true,
                  ),
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  _buildItemTypeOption(
                    icon: FontAwesomeIcons.ban,
                    iconColor: Colors.red,
                    title: 'Disabler',
                    subtitle:
                        'When players buy this item, they will be able to disable another team\'s claiming ability for a set amount of time.',
                    value: 'disabler',
                  ),
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  _buildItemTypeOption(
                    icon: FontAwesomeIcons.coins,
                    iconColor: Colors.blue,
                    title: 'Point Exchanger',
                    subtitle: 'Players can exchange coins for points.',
                    value: 'coin',
                  ),
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  _buildItemTypeOption(
                    icon: FontAwesomeIcons.forward,
                    iconColor: Colors.purple,
                    title: 'Task Skipper',
                    subtitle:
                        'Players can skip a task for a set amount of coins.',
                    value: 'skip',
                    isLast: true,
                  ),
                ],
              ),
            ),
            if (itemType != 'skip') ...[
              const SizedBox(height: 32),
              Text(
                'Item Details',
                style: baseTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (itemType == 'booster') ...[
                      _buildSliderOption(
                        title: 'Multiplier',
                        value: pointMultiplier,
                        min: 1.1,
                        max: 3.0,
                        color: Colors.green,
                        suffix: 'x',
                        onChanged: (value) {
                          setState(() {
                            pointMultiplier =
                                double.parse(value.toStringAsFixed(1));
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSliderOption(
                        title: 'Duration',
                        value: boosterTime,
                        min: 5,
                        max: 60,
                        color: Colors.green,
                        suffix: ' minutes',
                        onChanged: (value) {
                          setState(() {
                            boosterTime = value;
                          });
                        },
                      ),
                    ] else if (itemType == 'disabler') ...[
                      _buildSliderOption(
                        title: 'Duration',
                        value: disablerTime,
                        min: 5,
                        max: 60,
                        color: Colors.red,
                        suffix: ' minutes',
                        onChanged: (value) {
                          setState(() {
                            disablerTime = value;
                          });
                        },
                      ),
                    ] else if (itemType == 'coin') ...[
                      _buildSliderOption(
                        title: 'Points per Coin',
                        value: pointsPerCoin,
                        min: 1,
                        max: 20,
                        color: Colors.blue,
                        suffix: ' points',
                        onChanged: (value) {
                          setState(() {
                            pointsPerCoin = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            Text(
              'Price',
              style: baseTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set the number of coins required to purchase this item.',
                    style: baseTextStyle.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  _buildSliderOption(
                    title: 'Cost',
                    value: coinPrice,
                    min: 1,
                    max: 100,
                    color: Colors.amber,
                    suffix: ' coins',
                    onChanged: (value) {
                      setState(() {
                        coinPrice = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
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
                onPressed: saveItem,
                child: Text(
                  'Save Item',
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
  }

  Widget _buildItemTypeOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () => setState(() => itemType = value),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: baseTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: baseTextStyle.copyWith(
              color: Colors.white70,
              height: 1.3,
            ),
          ),
          trailing: Radio(
            value: value,
            groupValue: itemType,
            onChanged: (value) => setState(() => itemType = value.toString()),
            activeColor: iconColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSliderOption({
    required String title,
    required double value,
    required double min,
    required double max,
    required Color color,
    required String suffix,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: baseTextStyle.copyWith(
                color: Colors.white70,
              ),
            ),
            Text(
              value.toStringAsFixed(title.contains('Multiplier') ? 1 : 0) +
                  suffix,
              style: baseTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void saveItem() {
    if (itemNameController.text.isEmpty) {
      ToastificationHelper.showErrorToast(
          context, 'To save the coin shop item, please complete all fields.');
      return;
    }
    gameTemplate.coinShopItems ??= [];
    if (itemEdit) {
      CoinShopItem? item = gameTemplate.coinShopItems!
          .firstWhereOrNull((element) => element.itemId == currentItemId);
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
        pointsPerCoin: itemType == 'coin' ? pointsPerCoin.round() : 0,
      );
      gameTemplate.coinShopItems!.add(item);
    }
    updateGameTemplate(gameTemplate);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Get.to(() => const ClaimZoneView());
  }
}
