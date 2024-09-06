import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:scavhuntapp/screens/home_screen.dart';
import 'package:scavhuntapp/screens/setup/setup.dart';

class AppUser {
  String uid;
  String phoneNumber;
  String displayName;
  String firstName;
  String lastName;
  String? email;
  String? photoURL;
  String? fcmToken;
  String? apnsToken;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> friends;
  List<String> friendRequests;
  List<String> sentFriendRequests;
  String role;

  AppUser({
    required this.uid,
    required this.phoneNumber,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.photoURL,
    required this.fcmToken,
    required this.apnsToken,
    required this.createdAt,
    required this.updatedAt,
    required this.friends,
    required this.friendRequests,
    required this.sentFriendRequests,
    required this.role,
  });

  AppUser.fromMap(Map<String, dynamic> data)
      : uid = data['uid'],
        phoneNumber = data['phoneNumber'],
        displayName = data['displayName'],
        firstName = data['firstName'],
        lastName = data['lastName'],
        email = data['email'],
        photoURL = data['photoURL'],
        fcmToken = data['fcmToken'],
        apnsToken = data['apnsToken'],
        createdAt = data['createdAt'].toDate(),
        updatedAt = data['updatedAt'].toDate(),
        friends = List<String>.from(data['friends']),
        friendRequests = List<String>.from(data['friendRequests']),
        sentFriendRequests = List<String>.from(data['sentFriendRequests']),
        role = data['role'];

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'photoURL': photoURL,
      'fcmToken': fcmToken,
      'apnsToken': apnsToken,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'friends': friends,
      'friendRequests': friendRequests,
      'sentFriendRequests': sentFriendRequests,
      'role': role,
    };
  }
}

Future<void> setupFlow(String uid) async {
  bool exists = await userExists(uid);

  if (!exists) {
    Get.offAll(() => const SetupPage());
  } else {
    Get.offAll(() => const HomeScreen());
  }
}

Future<bool> userExists(String uid) async {
  if (uid.isEmpty) return false;
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc.exists;
}

Stream<AppUser?> appUserStream(String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snapshot) => AppUser.fromMap(snapshot.data()!));
}

Future<AppUser> getUser(String uid) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return AppUser.fromMap(doc.data() as Map<String, dynamic>);
}

Future<bool> createAppUser(AppUser appUser) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(appUser.uid)
        .set(appUser.toMap());
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> updateAppUser(AppUser appUser) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(appUser.uid)
        .update(appUser.toMap());
    return true;
  } catch (e) {
    return false;
  }
}
