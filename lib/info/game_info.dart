import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scavhuntapp/models/info.dart';

import '../utils/theme_data.dart';

class GameInfo extends StatefulWidget {
  const GameInfo({super.key});

  @override
  State<GameInfo> createState() => _GameInfoState();
}

String gameType = 'claimthezone';

class _GameInfoState extends State<GameInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Game Details'),
      ),
      body: FutureBuilder<Info>(
        future: getGameInfo(gameType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none ||
              snapshot.data == null) {
            return const Center(
              child: SpinKitFadingCube(color: Colors.green, size: 30.0),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                snapshot.data!.text.replaceAll('\\n', '\n'),
                style: baseTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
