import 'package:flutter/material.dart';
import 'package:flutter_chat_app/locator.dart';
import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/repository/user_repository.dart';

// Bu modelimin sağlayacağı verideki değişiklikleri
// UI'a aktarırken ne gibi state değişiklikleri
// nasıl durumlar olabilir onları ele alacağız.

enum AllUserViewState { idle, loaded, busy }

// home_page.dart'taki UsersPage'ten widget tree ye
// bu modelimizi koyabiliriz.
class AllUsersViewModel with ChangeNotifier {
  AllUserViewState _state = AllUserViewState.idle;
  // öncelikle sayfa benden ne gibi veriler isteyebilir onu
  // düşünüp yazalım.

  late List<UserModel> _allUser;
  UserModel? _lastGetUser;
  final UserRepository _userRepository = locator<UserRepository>();

  static const _pageGetUserCount = 10;
  bool _hasMore = true;
  bool get hasMoreLoading => _hasMore;

  List<UserModel> get aalUserList => _allUser;
  AllUserViewState get state => _state;

  // state'lerin değişimlerini dinlememiz gerek.
  set state(AllUserViewState value) {
    _state = value;
    notifyListeners();
  }

  AllUsersViewModel() {
    _allUser = [];
    _lastGetUser = null;
    getUserPagination(_lastGetUser, false);
  }

  // bu değişiklikleri güncellemek istediğimiz methodu yazalım
  // refresh ve sayfalama için
  // brinNewUsers true yapılır.
  // ilk açılış için brinNeUsers için false deger atanır.
  getUserPagination(UserModel? lastGetUser, bool bringNewUsers) async {
    if (_allUser.isNotEmpty) {
      _lastGetUser = _allUser.last;
      debugPrint('en son getirilen username : ' + _lastGetUser!.userName!);
    }

    if (bringNewUsers) {
    } else {
      state = AllUserViewState.busy;
    }
    var newList = await _userRepository.getUserWithPagination(
        _lastGetUser, _pageGetUserCount);

    if (newList.length < _pageGetUserCount) {
      _hasMore = false;
    }

    for (var user in newList) {
      debugPrint("Getirilen username: " + user.userName!);
    }

    // ekranda gorunen tum kullanıcılara ekliyoruz
    _allUser.addAll(newList);
    state = AllUserViewState.loaded;
    //_hasMore = false;
  }

  void bringMoreUsers() {
    debugPrint('bringMoresUsers tetiklendi - allUsersviewModel');
    if (_hasMore) {
      getUserPagination(_lastGetUser, true);
    } else {
      debugPrint("daha fazla eleman yok o yüzden çağırılmadı.");
    }
  }

  Future<void> refresh() {
    _hasMore = true;
    _lastGetUser = null;
    _allUser = [];
    // yeni eleman getiriliyormuş gibi true geçtim.
    return getUserPagination(_lastGetUser, true);
  }
}
