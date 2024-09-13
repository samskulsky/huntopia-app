import 'package:cloud_firestore/cloud_firestore.dart';

class GameTemplate {
  String templateId;
  String creatorUid;
  String creatorName;
  String gameName;
  String gameDescription;
  String gameType; // claimthezone, scavengerhunt, or challengerace
  DateTime createdAt;
  DateTime lastUpdated;

  // for ClaimRush games only
  GeoPoint? center;
  List<Zone>? zones;
  List<CoinShopItem>? coinShopItems = [];

  // for SCAVENGER HUNT games only
  List<ScavengerHuntItem>? scavengerHuntItems = [];

  // for StarSprint games only
  List<ChallengeRaceItem>? challengeRaceItems = [];

  GameTemplate({
    required this.templateId,
    required this.creatorUid,
    required this.creatorName,
    required this.gameName,
    required this.gameDescription,
    required this.gameType,
    required this.createdAt,
    required this.lastUpdated,
    this.center,
    this.zones,
    this.coinShopItems,
    this.scavengerHuntItems,
    this.challengeRaceItems,
  });

  Map toMap() {
    Map<String, dynamic> data = {
      'templateId': templateId,
      'creatorUid': creatorUid,
      'creatorName': creatorName,
      'gameName': gameName,
      'gameDescription': gameDescription,
      'gameType': gameType,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
    };

    if (gameType == 'claimthezone') {
      data['center'] = center;
      data['zones'] =
          zones != null ? zones!.map((zone) => zone.toMap()).toList() : [];
      data['coinShopItems'] = coinShopItems != null
          ? coinShopItems!.map((item) => item.toMap()).toList()
          : [];
    } else if (gameType == 'scavengerhunt') {
      data['scavengerHuntItems'] = scavengerHuntItems != null
          ? scavengerHuntItems!.map((item) => item.toMap()).toList()
          : [];
    } else if (gameType == 'challengerace') {
      data['challengeRaceItems'] = challengeRaceItems != null
          ? challengeRaceItems!.map((item) => item.toMap()).toList()
          : [];
    }

    return data;
  }

  factory GameTemplate.fromMap(Map<String, dynamic> map) {
    return GameTemplate(
      templateId: map['templateId'],
      creatorUid: map['creatorUid'],
      creatorName: map['creatorName'],
      gameName: map['gameName'],
      gameDescription: map['gameDescription'],
      gameType: map['gameType'],
      createdAt: map['createdAt'].toDate(),
      lastUpdated: map['lastUpdated'].toDate(),
      center: map['center'],
      zones: map['zones'] != null
          ? List<Zone>.from(map['zones'].map((zone) => Zone.fromMap(zone)))
          : [],
      coinShopItems: map['coinShopItems'] != null
          ? List<CoinShopItem>.from(
              map['coinShopItems'].map((item) => CoinShopItem.fromMap(item)))
          : [],
      scavengerHuntItems: map['scavengerHuntItems'] != null
          ? List<ScavengerHuntItem>.from(map['scavengerHuntItems']
              .map((item) => ScavengerHuntItem.fromMap(item)))
          : [],
      challengeRaceItems: map['challengeRaceItems'] != null
          ? List<ChallengeRaceItem>.from(map['challengeRaceItems']
              .map((item) => ChallengeRaceItem.fromMap(item)))
          : [],
    );
  }

  Map<String, dynamic> toMapString() {
    // all dates are converted to strings
    return {
      'templateId': templateId,
      'creatorUid': creatorUid,
      'creatorName': creatorName,
      'gameName': gameName,
      'gameDescription': gameDescription,
      'gameType': gameType,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'center': center,
      'zones': zones != null ? zones!.map((x) => x.toMap()).toList() : [],
      'coinShopItems': coinShopItems != null
          ? coinShopItems!.map((x) => x.toMap()).toList()
          : [],
      'scavengerHuntItems': scavengerHuntItems != null
          ? scavengerHuntItems!.map((x) => x.toMap()).toList()
          : [],
      'challengeRaceItems': challengeRaceItems != null
          ? challengeRaceItems!.map((x) => x.toMap()).toList()
          : [],
    };
  }
}

Stream<List<GameTemplate>> getUserGameTemplates(String uid) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference gameTemplates = firestore.collection('gameTemplates');
  return gameTemplates.where('creatorUid', isEqualTo: uid).snapshots().map(
      (snapshot) => snapshot.docs
          .map(
              (doc) => GameTemplate.fromMap(doc.data() as Map<String, dynamic>))
          .toList());
}

Future<bool> saveGameTemplate(GameTemplate gameTemplate) async {
  gameTemplate.lastUpdated = DateTime.now();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference gameTemplates = firestore.collection('gameTemplates');
  await gameTemplates.doc(gameTemplate.templateId).set(gameTemplate.toMap());
  return true;
}

Future<bool> updateGameTemplate(GameTemplate gameTemplate) async {
  gameTemplate.lastUpdated = DateTime.now();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference gameTemplates = firestore.collection('gameTemplates');
  await gameTemplates
      .doc(gameTemplate.templateId)
      .update(Map<String, dynamic>.from(gameTemplate.toMap()));
  return true;
}

Future<bool> deleteGameTemplate(String templateId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference gameTemplates = firestore.collection('gameTemplates');
  await gameTemplates.doc(templateId).delete();
  return true;
}

class ChallengeRaceItem {
  String itemId;
  String itemName;
  String itemDescription;
  String itemPhotoURL;
  int stars;
  int vetoPenaltyMinutes;
  String extraStarChallenge;

  ChallengeRaceItem({
    required this.itemId,
    required this.itemName,
    required this.itemDescription,
    required this.itemPhotoURL,
    required this.stars,
    required this.vetoPenaltyMinutes,
    required this.extraStarChallenge,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemPhotoURL': itemPhotoURL,
      'stars': stars,
      'vetoPenaltyMinutes': vetoPenaltyMinutes,
      'extraStarChallenge': extraStarChallenge,
    };
  }

  factory ChallengeRaceItem.fromMap(Map<String, dynamic> map) {
    return ChallengeRaceItem(
      itemId: map['itemId'],
      itemName: map['itemName'],
      itemDescription: map['itemDescription'],
      itemPhotoURL: map['itemPhotoURL'],
      stars: map['stars'],
      vetoPenaltyMinutes: map['vetoPenaltyMinutes'],
      extraStarChallenge: map['extraStarChallenge'],
    );
  }
}

class ScavengerHuntItem {
  String itemId;
  String itemName;
  String itemDescription;
  String itemPhotoURL;
  int points;

  ScavengerHuntItem({
    required this.itemId,
    required this.itemName,
    required this.itemDescription,
    required this.itemPhotoURL,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemPhotoURL': itemPhotoURL,
      'points': points,
    };
  }

  factory ScavengerHuntItem.fromMap(Map<String, dynamic> map) {
    return ScavengerHuntItem(
      itemId: map['itemId'],
      itemName: map['itemName'],
      itemDescription: map['itemDescription'],
      itemPhotoURL: map['itemPhotoURL'],
      points: map['points'],
    );
  }
}

class CoinShopItem {
  String itemId;
  String itemName;
  String itemDescription;
  int itemPrice;
  int? pointsPerCoin;
  String itemType; // multiplier, disabler, balanceswap
  num? multiplier;
  int? duration;

  CoinShopItem({
    required this.itemId,
    required this.itemName,
    required this.itemDescription,
    required this.itemPrice,
    required this.pointsPerCoin,
    required this.itemType,
    this.multiplier,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemPrice': itemPrice,
      'pointsPerCoin': pointsPerCoin,
      'itemType': itemType,
      'multiplier': multiplier,
      'duration': duration,
    };
  }

  factory CoinShopItem.fromJson(Map<String, dynamic> map) {
    return CoinShopItem(
      itemId: map['itemId'],
      itemName: map['itemName'],
      itemDescription: map['itemDescription'],
      itemPrice: map['itemPrice'],
      pointsPerCoin: map['pointsPerCoin'],
      itemType: map['itemType'],
      multiplier: map['multiplier'],
      duration: map['duration'],
    );
  }

  factory CoinShopItem.fromMap(Map<String, dynamic> map) {
    return CoinShopItem(
      itemId: map['itemId'],
      itemName: map['itemName'],
      itemDescription: map['itemDescription'],
      itemPrice: map['itemPrice'],
      pointsPerCoin: map['pointsPerCoin'],
      itemType: map['itemType'],
      multiplier: map['multiplier'],
      duration: map['duration'],
    );
  }
}

class Zone {
  String zoneId;
  String zoneName;
  GeoPoint location;
  int radius;
  String? clue;
  String? answer;
  String? photoURL;
  String? qrCode;
  String taskType; // takephoto, scanqr, or answerquestion
  int points;
  int originalPoints;
  int coins;

  Zone({
    required this.zoneId,
    required this.zoneName,
    required this.location,
    required this.radius,
    required this.taskType,
    required this.points,
    required this.coins,
    this.clue,
    this.answer,
    this.photoURL,
    this.qrCode,
    required this.originalPoints,
  });

  Map<String, dynamic> toMap() {
    return {
      'zoneId': zoneId,
      'zoneName': zoneName,
      'location': location,
      'radius': radius,
      'clue': clue,
      'answer': answer,
      'photoURL': photoURL,
      'qrCode': qrCode,
      'taskType': taskType,
      'points': points,
      'coins': coins,
      'originalPoints': originalPoints,
    };
  }

  factory Zone.fromMap(Map<String, dynamic> map) {
    return Zone(
      zoneId: map['zoneId'],
      zoneName: map['zoneName'],
      location: map['location'],
      radius: map['radius'],
      clue: map['clue'],
      answer: map['answer'],
      photoURL: map['photoURL'],
      qrCode: map['qrCode'],
      taskType: map['taskType'],
      points: map['points'],
      coins: map['coins'],
      originalPoints: map['originalPoints'],
    );
  }
}
