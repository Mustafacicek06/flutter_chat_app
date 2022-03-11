import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsModel {
  final String chatOwner;
  final String interlocutor;

  final Timestamp? createdDate;
  final String lastSendMessage;
  final Timestamp? seenDate;
  String? interlocutorUsername;
  String? interlocutorProfilUrl;
  DateTime? lastReadTime;
  // şuanki zmaandan okunma zamanını çıkartınca
  // 7 gün önce okundu gibi bir yazı göstereceğiz
  // bunu da timeago ile yapacağız
  String? timeDifferenceRead;

  ChatsModel({
    required this.chatOwner,
    required this.interlocutor,
    required this.createdDate,
    required this.lastSendMessage,
    required this.seenDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'konusma_sahibi': chatOwner,
      'kimle_konusuyor': interlocutor,
      'son_yollanan_mesaj': lastSendMessage,
      'olusturulma_tarihi': createdDate ?? FieldValue.serverTimestamp(),
      'gorulme_tarihi': seenDate ?? FieldValue.serverTimestamp(),
    };
  }

  ChatsModel.fromMap(Map<String, dynamic> map)
      : chatOwner = map['konusma_sahibi'],
        interlocutor = map['kimle_konusuyor'],
        lastSendMessage = map['son_yollanan_mesaj'],
        createdDate = map['olusturulma_tarihi'],
        seenDate = map['gorulme_tarihi'];

  @override
  String toString() {
    return 'ChatsModel{konusma_sahibi : $chatOwner, kimle_konusuyor : $interlocutor, son_yollanan_mesaj : $lastSendMessage , olusturulma_tarihi : $createdDate , gorulme_tarihi : $seenDate}';
  }
}
