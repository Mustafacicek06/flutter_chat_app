import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userID;
  String? email;
  String? userName;
  String? profilUrl;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? seviye;

  UserModel({
    required this.userID,
    required this.email,
  });

  // firestor set map için

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'email': email,
      'userName': userName ??
          email!.substring(0, email?.indexOf('@')) + _randomSayiUret(),
      'profilUrl': profilUrl ??
          'https://media.fashionnetwork.com/m/0d2f/313d/73c9/143a/6875/d46e/d976/bb81/2b1d/b017/b017.jpg',
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'seviye': seviye ?? 1,
    };
  }

  UserModel.fromMap(Map<String, dynamic> map)
      : userID = map['userID'],
        email = map['email'],
        userName = map['userName'],
        profilUrl = map['profilUrl'],
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = (map['updatedAt'] as Timestamp).toDate(),
        seviye = map['seviye'];
  @override
  String toString() {
    return 'User{userID: $userID, email: $email, username: $userName, profilUrl: $profilUrl, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  UserModel.idveResim({required this.userID, required this.profilUrl});

  String _randomSayiUret() {
    int rastgeleSayi = Random().nextInt(999999);
    return rastgeleSayi.toString();
  }

  getUserWithPagination(UserModel? lastGetUser, int toBeGetUserCount) {}
}
