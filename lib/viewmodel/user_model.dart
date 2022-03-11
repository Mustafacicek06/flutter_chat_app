import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/locator.dart';
import 'package:flutter_chat_app/model/chats_model.dart';
import 'package:flutter_chat_app/model/message.dart';
import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/repository/user_repository.dart';
import 'package:flutter_chat_app/services/auth_base.dart';

enum ViewState { Idle, Busy }

class UserViewModel with ChangeNotifier implements AuthBase {
  ViewState _state = ViewState.Idle;

  final UserRepository _userRepository = locator<UserRepository>();

  UserModel? _user;

  UserModel? get user => _user;

  ViewState get state => _state;

  String emailErrorMessage = '';
  String passwordErrorMessage = '';

  // o anki user'ın verisi state
  set state(ViewState value) {
    _state = value;
    // degisimleri dinliyoruz.
    notifyListeners();
  }

  UserViewModel() {
    currentUser();
  }

  @override
  Future<UserModel?> currentUser() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.currentUser();
      if (_user != null) {
        return _user;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Viewmodeldeki currentUser da hata ' + e.toString());
      return null;
    }
    // her iki durumda'da burası çalışacak.
     finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<UserModel?> signInAnonymously() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInAnonymously();
      return _user;
    } catch (e) {
      debugPrint('Viewmodeldeki currentUser da hata ' + e.toString());
      return null;
    }
    // her iki durumda'da burası çalışacak.
     finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      state = ViewState.Busy;
      bool result = await _userRepository.signOut();
      _user = null;
      return result;
    } catch (e) {
      debugPrint('Viewmodeldeki signOut da hata ' + e.toString());
      return false;
    }
    // her iki durumda'da burası çalışacak.
     finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithGoogle();
      return _user!;
    } catch (e) {
      debugPrint('Viewmodeldeki signInWithGoogle da hata ' + e.toString());
      throw UnimplementedError();
    }
    // her iki durumda'da burası çalışacak.
     finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithFacebook();
      return _user!;
    } catch (e) {
      debugPrint('Viewmodeldeki signInWithFacebook da hata ' + e.toString());
      throw NullThrownError();
    }
    // her iki durumda'da burası çalışacak.
     finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<UserModel?> createUserWithEmailandPassword(
      String eMail, String sifre) async {
    if (_emailSifreKontrol(eMail, sifre)) {
      try {
        state = ViewState.Busy;
        _user =
            await _userRepository.createUserWithEmailandPassword(eMail, sifre);

        return _user!;
      } finally {
        state = ViewState.Idle;
      }
    } else {
      return null;
    }
  }

  @override
  Future<UserModel> signInWithEmailandPassword(
      String eMail, String sifre) async {
    try {
      if (_emailSifreKontrol(eMail, sifre)) {
        state = ViewState.Busy;
        _user = await _userRepository.signInWithEmailandPassword(eMail, sifre);
        return _user!;
      } else {
        debugPrint('hata signInWithMail in userview model');
        return user!;
      }
    } finally {
      state = ViewState.Idle;
    }

    // her iki durumda'da burası çalışacak.
  }

  bool _emailSifreKontrol(String email, String sifre) {
    bool result = true;
    if (sifre.length < 6) {
      passwordErrorMessage = "En az 6 karakter olmalı";
      result = false;
    } else {
      passwordErrorMessage = '';
    }
    if (!email.contains('@')) {
      emailErrorMessage = "Geçersiz E-mail adresi";
      result = true;
    } else {
      emailErrorMessage = '';
    }

    return result;
  }

  Future<bool> updateUserName(String userID, String newUserName) async {
    var result = await _userRepository.updateUserName(userID, newUserName);
    if (result) {
      _user!.userName = newUserName;
    }

    return result;
  }

  Future<String> uploadFile(
      String userID, String fileType, File? profilePhoto) async {
    var downloadLink =
        await _userRepository.uploadFile(userID, fileType, profilePhoto);

    return downloadLink;
  }

  Stream<List<MyMessageClass>> getMessages(
      String currentUserID, String chattingUserID) {
    return _userRepository.getMessages(currentUserID, chattingUserID);
  }

  Future<List<ChatsModel>> getAllConversations(String userID) async {
    return await _userRepository.getAllConversations(userID);
  }

  Future<List<UserModel>> getUserWithPagination(
      UserModel? lastGetUser, int toBeGetUserCount) async {
    return await _userRepository.getUserWithPagination(
        lastGetUser, toBeGetUserCount);
  }
}
