import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/locator.dart';
import 'package:flutter_chat_app/model/message.dart';
import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/repository/user_repository.dart';

enum ChatViewState { idle, loaded, busy }

class ChatViewModel with ChangeNotifier {
  late List<MyMessageClass> _allMessage;
  ChatViewState _state = ChatViewState.idle;
  static const sayfaBasinaGonderiSayisi = 10;
  final _userRepository = locator<UserRepository>();
  final UserModel currentUser;
  final UserModel interlocutorUser;
  MyMessageClass? _lastMessage;
  MyMessageClass? _firstAddingListMessage;
  bool _hasMore = true;
  bool _newMessageListener = false;
  StreamSubscription? _streamSubscription;

  bool get hasMoreLoading => _hasMore;

  ChatViewModel({required this.currentUser, required this.interlocutorUser}) {
    _allMessage = [];
    getMessageWithPagination(false);
  }

  List<MyMessageClass> get messageList => _allMessage;
  ChatViewState get state => _state;

  // state'lerin değişimlerini dinlememiz gerek.
  set state(ChatViewState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint("chat view model dispose edildi.");
    // mesaja girip geri gelip tekrar girince hata veriyor. üzerinde kalan
    // streamSbuscription yüzünden olabilir bu yüzden iptal ettim.
    _streamSubscription?.cancel();
    super.dispose();
  }

  void getMessageWithPagination(bool fetchingNewMessages) async {
    if (_allMessage.isNotEmpty) {
      _lastMessage = _allMessage.last;
    }
    if (!fetchingNewMessages) {
      state = ChatViewState.busy;
    }

    var getMessage = await _userRepository.getMessageWithPagination(
        currentUser.userID,
        interlocutorUser.userID,
        _lastMessage, // WARNING
        sayfaBasinaGonderiSayisi);
    _allMessage.addAll(getMessage);

    if (getMessage.length < sayfaBasinaGonderiSayisi) {
      _hasMore = false;
    }

    /* for (var message in getMessage) {
      debugPrint("getirilen mesajlar : " + message.message);
    } */

    _allMessage.addAll(getMessage);
    if (_allMessage.isNotEmpty) {
      _firstAddingListMessage = _allMessage.first;
    }

    state = ChatViewState.loaded;
    if (_newMessageListener == false) {
      _newMessageListener = true;

      newMessageListenerMethod();
    }
  }

  Future<bool> saveMessage(MyMessageClass toBeSavedMessage) async {
    return await _userRepository.saveMessage(toBeSavedMessage);
  }

  void fetchMoreMessage() {
    debugPrint('bringMoresUsers tetiklendi - allUsersviewModel');
    if (_hasMore) {
      getMessageWithPagination(true);
    } else {
      debugPrint("daha fazla eleman yok o yüzden çağırılmadı.");
    }
  }
  // buradaki listener ilk mesaj eklendiğinde bi çalışıyor
  // bi de Timestamp gidip zamanı getirdiğinde çalışıyor
  // yani 1 tane gönderilen mesaj bi zamanı null olarak çalışıyor
  // bi de timestamp getirildiğinde çalışıyor
  // çözüm 1. yöntem date kontrolu yap null olanı ekleme : performans kaybı olur

  void newMessageListenerMethod() {
    debugPrint('Yeni Mesajlar için listener atandı');
    _streamSubscription = _userRepository
        .getMessages(currentUser.userID, interlocutorUser.userID)
        .listen((realTimeData) {
      // listenin sonuna degil başına eklememiz lazım
      // tersten goster dedigim için 0 verirsek listenin sonuna ekler
      if (realTimeData.isNotEmpty) {
        if (realTimeData[0].dateMessage != null) {
          if (_firstAddingListMessage == null) {
            _allMessage.insert(0, realTimeData[0]);
          } else if (_firstAddingListMessage
                  ?.dateMessage?.microsecondsSinceEpoch !=
              realTimeData[0].dateMessage?.microsecondsSinceEpoch) {
            _allMessage.insert(0, realTimeData[0]);
          }
        }
        // atadık ama anlık olarak mesajlarımızın haberi olması için
        // state'i de değiştirmek zorundayız.
        state = ChatViewState.loaded;
      }
    });
  }
}
