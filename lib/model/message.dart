import 'package:cloud_firestore/cloud_firestore.dart';

class MyMessageClass {
  final String fromWho;
  final String toWho;
  final bool fromMe;
  final String message;
  final Timestamp? dateMessage;

  MyMessageClass(
      {required this.fromWho,
      required this.toWho,
      required this.fromMe,
      required this.message,
      this.dateMessage});

  Map<String, dynamic> toMap() {
    return {
      'fromWho': fromWho,
      'toWho': toWho,
      'fromMe': fromMe,
      'message': message,
      'dateMessage': dateMessage ?? FieldValue.serverTimestamp(),
    };
  }

  MyMessageClass.fromMap(Map<String, dynamic> map)
      : fromWho = map['fromWho'],
        toWho = map['toWho'],
        fromMe = map['fromMe'],
        message = map['message'],
        dateMessage = map['dateMessage'];

  @override
  String toString() {
    return 'MyMessageClass{fromWho: $fromWho, toWho: $toWho, fromMe: $fromMe, message: $message, dateMessage: $dateMessage}';
  }
}
