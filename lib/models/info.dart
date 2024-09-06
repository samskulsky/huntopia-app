import 'package:cloud_firestore/cloud_firestore.dart';

class Info {
  String title;
  String text;

  Info({
    required this.title,
    required this.text,
  });

  Info.fromMap(Map<String, dynamic> data)
      : title = data['title'],
        text = data['text'];

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'text': text,
    };
  }
}

Future<Info> getGameInfo(String game) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference info = firestore.collection('info');
  return info.doc(game).get().then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      return Info.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    } else {
      return Info(title: '', text: '');
    }
  }).catchError((error) {
    return Info(title: '', text: '');
  });
}
