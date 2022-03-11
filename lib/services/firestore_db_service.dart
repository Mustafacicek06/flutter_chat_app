import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/model/chats_model.dart';
import 'package:flutter_chat_app/model/message.dart';
import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/services/database_base.dart';

class FireStoreDBService implements DBBase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(UserModel userModel) async {
    // document'i okumak
    DocumentSnapshot _readUser =
        await FirebaseFirestore.instance.doc("users/${userModel.userID}").get();

    // okunan kullanıcı daha onceden veri tabanında yoksa

    if (_readUser.data() == null) {
      // böyle ekleyemezsin.
      // UserModel _addingUser = userModel;
      // _addingUser.createdAt = FieldValue.serverTimestamp();

      await _firestore
          .collection("users")
          .doc(userModel.userID)
          .set(userModel.toMap());
    }

    return true;
  }

  // verilerimizi artık Firestore'dan çekmek için ve
  // uygulama içinde kullanmak için işlemler yapyıoruz.
  @override
  Future<UserModel> readUser(String userID) async {
    DocumentSnapshot _readUser =
        await _firestore.collection("users").doc(userID).get();
    Map<String, dynamic> _readUserInfoMap =
        _readUser.data() as Map<String, dynamic>;

    UserModel _readUserObject = UserModel.fromMap(_readUserInfoMap);
    print('okunan user nesnesi : ' + _readUserObject.toString());
    return _readUserObject;
  }

  @override
  Future<bool> updateUserName(String userID, String newUserName) async {
    var users = await _firestore
        .collection("users")
        .where("userName", isEqualTo: newUserName)
        .get();

    // database'de daha önceden böyle bir isim kullanılmış işe başarısız işlem
    if (users.docs.isNotEmpty) {
      return false;
    } else {
      await _firestore
          .collection("users")
          .doc(userID)
          .update({'userName': newUserName});
      return true;
    }
  }

  Future<bool> updateProfilePhoto(String userID, String profilFotoUrl) async {
    // database'de daha önceden böyle bir isim kullanılmış işe başarısız işlem

    await _firestore
        .collection("users")
        .doc(userID)
        .update({'profilUrl': profilFotoUrl});
    return true;
  }

  @override
  Future<List<ChatsModel>> getAllConversations(String userID) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("konusmalar")
        .where("konusma_sahibi", isEqualTo: userID)
        .orderBy('olusturulma_tarihi', descending: true)
        .get();

    List<ChatsModel> allChats = [];

    for (DocumentSnapshot tekKonusma in querySnapshot.docs) {
      ChatsModel _tekKonusma =
          ChatsModel.fromMap(tekKonusma.data() as Map<String, dynamic>);
      debugPrint("okunan konusma tarisi:" +
          _tekKonusma.createdDate!.toDate().toString());
      allChats.add(_tekKonusma);
    }

    return allChats;
  }

  @override
  Stream<List<MyMessageClass>> getMessages(
      String currentUserID, String chattingUserID) {
    var snapShot = _firestore
        .collection("konusmalar")
        .doc(currentUserID + "--" + chattingUserID)
        .collection("message")
        .orderBy("dateMessage", descending: true)
        .limit(1)
        .snapshots();
    // querySnapShot veriyor ve streambuilder ile ekrana bir liste olarak yansıtmadan önce
    // bir şeylere dönüştürmem gerekiyor. O zmaan da widgetlerimin içinde QuerySnapShot gibi
    // firebase nesneleri olacak. Fakat ben UI 'da herhangi bir back-end ' e ait bir şey istemiyorum
    // o yüzden burası düzenlenecek.

    // tüm mesajları gidip alıp tek tek map' e dönüştürme işlemi yaparak
    // QuerySanpShot nesnesinden kurtuluyoruz.
    return snapShot.map((messageList) => messageList.docs
        .map((message) => MyMessageClass.fromMap(message.data()))
        .toList());
  }

  Future<bool> saveMessage(MyMessageClass toBeSavedMessage) async {
    // kaydederken 2 farklı yere yazacağımızdan mesajları o yüzden
    // 2 farklı id gerekmektedir.
    var _messageID = _firestore.collection("konusmalar").doc().id;
    // karşılıklı document oluşturulmalı buradada
    // mustafa--nihal
    // nihal -- mustafa
    // nerden okunup nereden yazılacağını anlamak için
    var _myDocumentID =
        toBeSavedMessage.fromWho + "--" + toBeSavedMessage.toWho;
    var _receiverDocumentID =
        toBeSavedMessage.toWho + "--" + toBeSavedMessage.fromWho;
    var _toBeSavedMessageMapStructure = toBeSavedMessage.toMap();
    await _firestore
        .collection("konusmalar")
        .doc(_myDocumentID)
        .collection("message")
        .doc(_messageID)
        .set(_toBeSavedMessageMapStructure);

    // set data değilde tekrar collection deseydik bilgilere erişmiş olurudk
    // mesaj gönderen için
    await _firestore.collection("konusmalar").doc(_myDocumentID).set({
      "konusma_sahibi": toBeSavedMessage.fromWho,
      "kimle_konusuyor": toBeSavedMessage.toWho,
      "son_yollanan_mesaj": toBeSavedMessage.message,
      "konusma_goruldu": false,
      "olusturulma_tarihi": FieldValue.serverTimestamp(),
    });

    ;
    // fromMe degerini true verdigim için tekrar false olarak güncellemem gerek
    // çünkü sırada karşı tarafın mesaj documentini yazacağız
    _toBeSavedMessageMapStructure.update("fromMe", (value) => false);

    await _firestore
        .collection("konusmalar")
        .doc(_receiverDocumentID)
        .collection("message")
        .doc(_messageID)
        .set(_toBeSavedMessageMapStructure);

    // karşı taraf, mesajı okuyan için
    await _firestore.collection("konusmalar").doc(_receiverDocumentID).set({
      "konusma_sahibi": toBeSavedMessage.toWho,
      "kimle_konusuyor": toBeSavedMessage.fromWho,
      "son_yollanan_mesaj": toBeSavedMessage.message,
      "konusma_goruldu": false,
      "olusturulma_tarihi": FieldValue.serverTimestamp(),
    });

    return true;
  }

  @override
  Future<DateTime> showDate(String userID) async {
    await _firestore
        .collection("server")
        .doc(userID)
        .set({"saat": FieldValue.serverTimestamp()});

    var readMap = await _firestore.collection("server").doc(userID).get();
    Timestamp readDate = readMap.data()!["saat"];

    return readDate.toDate();
  }

  @override
  Future<List<UserModel>> getUserWithPagination(
      UserModel? lastGetUser, int toBeGetElementCount) async {
    QuerySnapshot _querySnapshot;
    List<UserModel> _allUsers = [];
    // userName'e göre A-Z arasında ilerlerken
    // ilk 10 elemanı bize verecek.

    // null ise ilk 10 eleman getiriliyor.
    if (lastGetUser == null) {
      _querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .orderBy("userName")
          .limit(toBeGetElementCount)
          .get();
    } else {
      _querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .orderBy("userName")
          // koyulan kısıttan sonrakileri bana getir anlamındadır.
          .startAfter([lastGetUser.userName])
          .limit(toBeGetElementCount)
          .get();
    }
    for (DocumentSnapshot snap in _querySnapshot.docs) {
      UserModel _tekUser =
          UserModel.fromMap(snap.data() as Map<String, dynamic>);
      _allUsers.add(_tekUser);
    }
    return _allUsers;
  }

  Future<List<MyMessageClass>> getMessageWithPagination(
      String currentUserID,
      String interlocutorUserID,
      MyMessageClass? lastMessage,
      int toGetElementCount) async {
    QuerySnapshot _querySnapshot;
    List<MyMessageClass> _allMessage = [];
    // userName'e göre A-Z arasında ilerlerken
    // ilk 10 elemanı bize verecek.

    // null ise ilk 10 eleman getiriliyor.
    if (lastMessage == null) {
      _querySnapshot = await FirebaseFirestore.instance
          .collection("konusmalar")
          .doc(currentUserID + "--" + interlocutorUserID)
          .collection("message")
          .orderBy("dateMessage", descending: true)
          .limit(toGetElementCount)
          .get();
    } else {
      _querySnapshot = await FirebaseFirestore.instance
          .collection("konusmalar")
          .doc(currentUserID + "--" + interlocutorUserID)
          .collection("message")
          .orderBy("dateMessage", descending: true)
          // koyulan kısıttan sonrakileri bana getir anlamındadır.
          .startAfter([lastMessage.dateMessage])
          .limit(toGetElementCount)
          .get();
    }
    for (DocumentSnapshot snap in _querySnapshot.docs) {
      MyMessageClass _tekUser =
          MyMessageClass.fromMap(snap.data() as Map<String, dynamic>);
      _allMessage.add(_tekUser);
    }
    return _allMessage;
  }
}


  // @override
  // Future<List<UserModel>> getAllUser() async {
  //   QuerySnapshot querySnapshot = await _firestore.collection("users").get();

  //   List<UserModel> allUsers = [];

  //   // firestore'daki tüm kullanıcıları tek tek gezecek.
  //   for (DocumentSnapshot tekUser in querySnapshot.docs) {
  //     UserModel _tekUser =
  //         UserModel.fromMap(tekUser.data() as Map<String, dynamic>);

  //     allUsers.add(_tekUser);
  //   }

  //   // firestore'daki tüm kullanıcıları tek tek gezecek.
  //   // WITH MAP METHOD
  //   // allUsers = querySnapshot.docs
  //   //     .map((tekSatir) => UserModel.fromMap(tekSatir.get("users")))
  //   //     .toList();

  //   return allUsers;
  // }