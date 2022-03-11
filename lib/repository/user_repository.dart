import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/locator.dart';
import 'package:flutter_chat_app/model/chats_model.dart';
import 'package:flutter_chat_app/model/message.dart';
import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/services/auth_base.dart';
import 'package:flutter_chat_app/services/fake_auth_service.dart';
import 'package:flutter_chat_app/services/firebase_auth_service.dart';
import 'package:flutter_chat_app/services/firebase_storage_service.dart';
import 'package:flutter_chat_app/services/firestore_db_service.dart';
import 'package:timeago/timeago.dart' as timeago;

// test modda fakeAuthServiceyi çağır
// release modda firebaseAuthServiceyi çağır
// Test aşamalarının kontrolünü'de sağlamış olduk
enum AppMode { debugmode, releasemode }

class UserRepository implements AuthBase {
  // firebase ' e mi gideyim fake e mi gideyim ?

  final FirebaseAuthService _firebaseAuthService =
      locator<FirebaseAuthService>();
  final FakeAuthService _fakeAuthService = locator<FakeAuthService>();

  final FireStoreDBService _fireStoreDBService = locator<FireStoreDBService>();
  final FirebaseStorageService _firebaseStorageService =
      locator<FirebaseStorageService>();

  List<UserModel> allUserList = [];

  AppMode appMode = AppMode.releasemode;
  @override
  Future<UserModel?> currentUser() async {
    if (appMode == AppMode.debugmode) {
      return await _fakeAuthService.currentUser();
    } else {
      UserModel _user = await _firebaseAuthService.currentUser();
      if (_user != null) {
        return await _fireStoreDBService.readUser(_user.userID);
      }
      return null;
    }
  }

  @override
  Future<UserModel?> signInAnonymously() async {
    if (appMode == AppMode.debugmode) {
      return await _fakeAuthService.signInAnonymously();
    } else {
      return await _firebaseAuthService.signInAnonymously();
    }
  }

  @override
  Future<bool> signOut() async {
    if (appMode == AppMode.debugmode) {
      return await _fakeAuthService.signOut();
    } else {
      return await _firebaseAuthService.signOut();
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    if (appMode == AppMode.debugmode) {
      return await _fakeAuthService.signInWithGoogle();
    } else {
      UserModel _user = await _firebaseAuthService.signInWithGoogle();

      await _fireStoreDBService.saveUser(_user);
      return await _fireStoreDBService.readUser(_user.userID);
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    if (appMode == AppMode.debugmode) {
      return await _fakeAuthService.signInWithFacebook();
    } else {
      UserModel _user = await _firebaseAuthService.signInWithFacebook();
      await _fireStoreDBService.saveUser(_user);
      return await _fireStoreDBService.readUser(_user.userID);
    }
  }

  @override
  Future<UserModel> createUserWithEmailandPassword(
      String eMail, String sifre) async {
    if (appMode == AppMode.debugmode) {
      return await _fakeAuthService.createUserWithEmailandPassword(
          eMail, sifre);
    } else {
      UserModel _user = await _firebaseAuthService
          .createUserWithEmailandPassword(eMail, sifre);
      bool _result = await _fireStoreDBService.saveUser(_user);
      if (_result) {
        return await _fireStoreDBService.readUser(_user.userID);
      } else {
        return _user;
      }
    }
  }

  @override
  Future<UserModel> signInWithEmailandPassword(
      String eMail, String sifre) async {
    if (appMode == AppMode.debugmode) {
      return await _fakeAuthService.signInWithEmailandPassword(eMail, sifre);
    } else {
      UserModel? _userModel =
          await _firebaseAuthService.signInWithEmailandPassword(eMail, sifre);
      return await _fireStoreDBService.readUser(_userModel.userID);
    }
  }

  Future<bool> updateUserName(String userID, String newUserName) async {
    if (appMode == AppMode.debugmode) {
      return false;
    } else {
      return await _fireStoreDBService.updateUserName(userID, newUserName);
    }
  }

  Future<String> uploadFile(
      String userID, String fileType, File? profilePhoto) async {
    if (appMode == AppMode.debugmode) {
      return 'file_download_link';
    } else {
      var profilFotoUrl = await _firebaseStorageService.uploadFile(
          userID, fileType, profilePhoto!);
      await _fireStoreDBService.updateProfilePhoto(userID, profilFotoUrl);
      return profilFotoUrl;
    }
  }

  Stream<List<MyMessageClass>> getMessages(
      String currentUserID, String chattingUserID) {
    if (appMode == AppMode.debugmode) {
      return const Stream.empty();
    } else {
      return _fireStoreDBService.getMessages(currentUserID, chattingUserID);
    }
  }

  Future<bool> saveMessage(MyMessageClass toBeSavedMessage) async {
    if (appMode == AppMode.debugmode) {
      return true;
    } else {
      return _fireStoreDBService.saveMessage(toBeSavedMessage);
    }
  }

  Future<List<ChatsModel>> getAllConversations(String userID) async {
    if (appMode == AppMode.debugmode) {
      return [];
    } else {
      DateTime _time = await _fireStoreDBService.showDate(userID);

      var chatList = await _fireStoreDBService.getAllConversations(userID);

      for (var currentChat in chatList) {
        // konuşulana eriştik
        var userInUserList = userFindInList(currentChat.interlocutor);
        debugPrint("user FİND LİST ");

        if (userInUserList != null) {
          debugPrint("VERILER LOCAL CACHEDEN OKUNDU");
          currentChat.interlocutorUsername = userInUserList.userName!;

          currentChat.interlocutorProfilUrl = userInUserList.profilUrl!;
        } else {
          debugPrint("VERILER VERİ TABANINDAN OKUNDU");

          debugPrint(
              "aranılan user daha onceden getirilmemiş, o yüzden veritabanından bu değeri okumalıyız");
          var _userReadFromDb =
              await _fireStoreDBService.readUser(currentChat.interlocutor);
          currentChat.interlocutorUsername = _userReadFromDb.userName!;
          currentChat.interlocutorProfilUrl = _userReadFromDb.profilUrl!;
        }
        timeagoCalculate(currentChat, _time);
      }
      return chatList;
    }
  }

  UserModel? userFindInList(String userID) {
    for (int i = 0; i < allUserList.length; i++) {
      if (allUserList[i].userID == userID) {
        return allUserList[i];
      }
    }
    return null;
  }

  void timeagoCalculate(ChatsModel currentChat, DateTime time) {
    currentChat.lastReadTime = time;

    timeago.setLocaleMessages("tr", timeago.TrMessages());

    var _duration = time.difference(currentChat.createdDate!.toDate());
    currentChat.timeDifferenceRead =
        timeago.format(time.subtract(_duration), locale: "tr");
  }

  Future<List<UserModel>> getUserWithPagination(
      UserModel? lastGetUser, int toBeGetUserCount) async {
    if (appMode == AppMode.debugmode) {
      return [];
    } else {
      // kullanıcı listesi yenilenmediği zaman sohbetlerde kullanıcı listesinin
      // gösterilmediği bi kısmıdaki user ile mesajlaştıysak o user local database'de
      // henüz olmadığı için firestore'a gidip veriyi alacak
      // bunu engellemek için kullanıcı listesine yeni user eklendikçe yani aşşağı doğru
      // scroll edildikçe buradaki userlist'i de bilgilendirmiş olacağız.
      List<UserModel> _userTempList = await _fireStoreDBService
          .getUserWithPagination(lastGetUser, toBeGetUserCount);
      allUserList.addAll(_userTempList);
      return _userTempList;
    }
  }

  Future<List<MyMessageClass>> getMessageWithPagination(
      String currentUserID,
      String interlocutorUserID,
      MyMessageClass? lastMessage,
      int toGetElementCount) async {
    if (appMode == AppMode.debugmode) {
      return [];
    } else {
      return await _fireStoreDBService.getMessageWithPagination(
          currentUserID, interlocutorUserID, lastMessage, toGetElementCount);
    }
  }
}
