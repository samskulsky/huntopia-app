import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:scavhuntapp/models/game_template.dart';

class Game {
  String gameId;
  String hostUid;
  String hostName;
  int durationMinutes;
  int maxTeams;
  DateTime created;
  DateTime startTime;
  DateTime endTime;
  List<Player> players;
  String gameType;
  String gameStatus;
  double allPlayerPointMultiplier;
  List<LogMessage> logMessages;
  GameTemplate game;

  Game({
    required this.gameId,
    required this.hostUid,
    required this.hostName,
    required this.durationMinutes,
    required this.maxTeams,
    required this.created,
    required this.startTime,
    required this.endTime,
    required this.players,
    required this.gameType,
    required this.gameStatus,
    required this.allPlayerPointMultiplier,
    required this.logMessages,
    required this.game,
  });

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'hostUid': hostUid,
      'hostName': hostName,
      'durationMinutes': durationMinutes,
      'maxTeams': maxTeams,
      'created': created,
      'startTime': startTime,
      'endTime': endTime,
      'players': players.map((x) => x.toMap()).toList(),
      'gameType': gameType,
      'gameStatus': gameStatus,
      'allPlayerPointMultiplier': allPlayerPointMultiplier,
      'logMessages': logMessages.map((x) => x.toMap()).toList(),
      'game': game.toMap(),
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      gameId: map['gameId'],
      hostUid: map['hostUid'],
      hostName: map['hostName'],
      durationMinutes: map['durationMinutes'],
      maxTeams: map['maxTeams'],
      created: map['created'].toDate(),
      startTime: map['startTime'].toDate(),
      endTime: map['endTime'].toDate(),
      players: List<Player>.from(map['players'].map((x) => Player.fromMap(x))),
      gameType: map['gameType'],
      gameStatus: map['gameStatus'],
      allPlayerPointMultiplier: map['allPlayerPointMultiplier'],
      logMessages: List<LogMessage>.from(
          map['logMessages'].map((x) => LogMessage.fromMap(x))),
      game: GameTemplate.fromMap(map['game']),
    );
  }

  Map<String, String> toMapString() {
    return {
      'gameId': gameId,
      'hostUid': hostUid,
      'hostName': hostName,
      'durationMinutes': durationMinutes.toString(),
      'maxTeams': maxTeams.toString(),
      'created': created.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'players': players.map((x) => x.toMapString()).toString(),
      'gameType': gameType,
      'gameStatus': gameStatus,
      'allPlayerPointMultiplier': allPlayerPointMultiplier.toString(),
      'logMessages': logMessages.map((x) => x.toMapString()).toString(),
      'game': game.toMapString().toString(),
    };
  }
}

Future<bool> createGame(Game game) async {
  try {
    await FirebaseFirestore.instance
        .collection('games')
        .doc(game.gameId)
        .set(game.toMap());
    return true;
  } catch (e) {
    log(e.toString());
    return false;
  }
}

Future<bool> canClaimZone(String gameId, Player player, String zoneId) {
  return getGame(gameId).then((game) {
    if (game == null) return false;
    if (game.gameStatus == 'ended') return false;
    if (game.gameStatus == 'started' &&
        game.startTime.isBefore(DateTime.now()) &&
        game.endTime.isAfter(DateTime.now())) {
      if (player.sabotagedUntil.isAfter(DateTime.now())) return false;
      if (player.pointBoostUntil.isAfter(DateTime.now())) return true;
      return false;
    }
    // check if it has already been claimed
    for (var player in game.players) {
      if (player.zonesClaimed.contains(zoneId)) return false;
    }
    return true;
  });
}

Future<bool> updateGame(Game game) async {
  game.game.lastUpdated = DateTime.now();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference games = firestore.collection('games');
  await games.doc(game.gameId).update(Map<String, dynamic>.from(game.toMap()));
  return true;
}

Future<bool> deleteGame(String gameId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference games = firestore.collection('games');
  await games.doc(gameId).delete();
  return true;
}

Future<Game?> getGame(String gameId) async {
  final doc =
      await FirebaseFirestore.instance.collection('games').doc(gameId).get();
  if (doc.exists) {
    return Game.fromMap(doc.data() as Map<String, dynamic>);
  } else {
    return null;
  }
}

Future<bool> gameExists(String gameId) async {
  if (gameId.isEmpty) return false;
  final doc =
      await FirebaseFirestore.instance.collection('games').doc(gameId).get();
  return doc.exists;
}

Future<bool> joinGame(String gameId, Player player) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference games = firestore.collection('games');
  DocumentReference game = games.doc(gameId);
  await game.update({
    'players': FieldValue.arrayUnion([player.toMap()])
  });
  return true;
}

Stream<Game> gameStream(String gameId) {
  return FirebaseFirestore.instance
      .collection('games')
      .doc(gameId)
      .snapshots()
      .map((snapshot) => Game.fromMap(snapshot.data()!));
}

class Player {
  String playerId;
  String teamName;
  String teamColor;
  int points;
  int coinBalance;
  DateTime sabotagedUntil;
  DateTime pointBoostUntil;
  DateTime sabotagedAt;
  DateTime pointBoostAt;
  double pointMultiplier;
  List<String> zonesClaimed;
  int skips;
  String fcmToken;
  GeoPoint? location;

  Player({
    required this.playerId,
    required this.teamName,
    required this.teamColor,
    required this.points,
    required this.coinBalance,
    required this.sabotagedUntil,
    required this.pointBoostUntil,
    required this.sabotagedAt,
    required this.pointBoostAt,
    required this.pointMultiplier,
    required this.zonesClaimed,
    required this.skips,
    required this.fcmToken,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'teamName': teamName,
      'teamColor': teamColor,
      'points': points,
      'coinBalance': coinBalance,
      'sabotagedUntil': sabotagedUntil,
      'pointBoostUntil': pointBoostUntil,
      'sabotagedAt': sabotagedAt,
      'pointBoostAt': pointBoostAt,
      'pointMultiplier': pointMultiplier,
      'zonesClaimed': zonesClaimed,
      'skips': skips,
      'fcmToken': fcmToken,
      'location': location,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      playerId: map['playerId'],
      teamName: map['teamName'],
      teamColor: map['teamColor'],
      points: map['points'],
      coinBalance: map['coinBalance'],
      sabotagedUntil: map['sabotagedUntil'].toDate(),
      pointBoostUntil: map['pointBoostUntil'].toDate(),
      sabotagedAt: map['sabotagedAt'].toDate(),
      pointBoostAt: map['pointBoostAt'].toDate(),
      pointMultiplier: double.parse(map['pointMultiplier'].toString()),
      zonesClaimed: List<String>.from(map['zonesClaimed']),
      skips: map['skips'],
      fcmToken: map['fcmToken'],
      location: map['location'],
    );
  }

  Map<String, dynamic> toMapString() {
    return {
      'playerId': playerId,
      'teamName': teamName,
      'teamColor': teamColor,
      'points': points,
      'coinBalance': coinBalance,
      'sabotagedUntil': sabotagedUntil.toIso8601String(),
      'pointBoostUntil': pointBoostUntil.toIso8601String(),
      'sabotagedAt': sabotagedAt.toIso8601String(),
      'pointBoostAt': pointBoostAt.toIso8601String(),
      'pointMultiplier': pointMultiplier,
      'zonesClaimed': zonesClaimed,
      'skips': skips,
      'fcmToken': fcmToken,
      'location': location,
    };
  }
}

Future<bool> updateLocation(
    String gameId, String playerId, GeoPoint location) async {
  return getGame(gameId).then((game) {
    if (game == null) return false;
    for (var player in game.players) {
      if (player.playerId == playerId) {
        player.location = location;
        updateGame(game);
        return true;
      }
    }
    return false;
  });
}

class LogMessage {
  String message;
  DateTime timestamp;
  String uid;
  String displayName;
  String imageUrl;

  LogMessage({
    required this.message,
    required this.timestamp,
    required this.uid,
    required this.displayName,
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'timestamp': timestamp,
      'uid': uid,
      'displayName': displayName,
      'imageUrl': imageUrl,
    };
  }

  factory LogMessage.fromMap(Map<String, dynamic> map) {
    return LogMessage(
      message: map['message'],
      timestamp: map['timestamp'].toDate(),
      uid: map['uid'],
      displayName: map['displayName'],
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMapString() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'uid': uid,
      'displayName': displayName,
      'imageUrl': imageUrl,
    };
  }
}
