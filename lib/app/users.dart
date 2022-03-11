import 'package:flutter/material.dart';
import 'package:flutter_chat_app/app/chat.dart';

import 'package:flutter_chat_app/viewmodel/all_users_view_model.dart';
import 'package:flutter_chat_app/viewmodel/chat_view_model.dart';
import 'package:flutter_chat_app/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // flag control altta yükleniyor durumda mı
  bool _isLoading = false;
  // daha fazla getirilecek veri var mı kontrolü

  // sayfanın sonuna vardığını anlamamız için
  // sayfanın sonunu dinlememiz için
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState

    // built edilmeden önce bizim context'e ihtiyacımız oldugu için hata verdi
    // getUser();

    // bu hatayı addPostFrameCallBack ile buildden hemen sonra bizim methodumuzu
    // çağırarak çözebiliriz.

    // SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
    //   getUser();
    // });

    _scrollController.addListener(_listScrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kullanicilar"),
      ),
      // consumer'de ne ile ilgilendiğimizi de verebiliriz.
      // model ağacımıza enjekte ettiğimiz veriyi temsil ediyor.
      body: Consumer<AllUsersViewModel>(
        builder: (context, model, child) {
          if (model.state == AllUserViewState.busy) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (model.state == AllUserViewState.loaded) {
            return RefreshIndicator(
              onRefresh: model.refresh,
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (model.aalUserList.length == 1) {
                    return _userNotFoundUI();
                  }

                  if (model.hasMoreLoading &&
                      index == model.aalUserList.length) {
                    return _uploadingNewUsers();
                  } else {
                    return _userListElementCreate(index);
                  }
                },
                itemCount: model.hasMoreLoading
                    ? model.aalUserList.length + 1
                    : model.aalUserList.length,
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _userNotFoundUI() {
    final _allUsersViewModel = Provider.of<AllUsersViewModel>(context);
    return RefreshIndicator(
      onRefresh: _allUsersViewModel.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.supervisor_account,
                  color: Theme.of(context).primaryColor,
                ),
                const Text(
                  'Henüz Kullanıcı Yok',
                  style: TextStyle(fontSize: 36),
                )
              ],
            ),
          ),
          height: MediaQuery.of(context).size.height - 150,
        ),
      ),
    );
  }

  Widget _userListElementCreate(int index) {
    UserViewModel _userViewModel =
        Provider.of<UserViewModel>(context, listen: false);
    final _allUsersViewModel =
        Provider.of<AllUsersViewModel>(context, listen: false);
    var _currentUser = _allUsersViewModel.aalUserList[index];
    if (_currentUser.userID == _userViewModel.user!.userID) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider<ChatViewModel>(
            create: (context) => ChatViewModel(
                currentUser: _userViewModel.user!,
                interlocutorUser: _currentUser),
            child: Chat(),
          ),
        ));
      },
      child: Card(
        child: ListTile(
          title: Text(_currentUser.userName!),
          subtitle: Text(_currentUser.email!),
          leading: CircleAvatar(
            backgroundColor: Colors.grey.withAlpha(40),
            backgroundImage: NetworkImage(_currentUser.profilUrl!),
          ),
        ),
      ),
    );
  }

  _uploadingNewUsers() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

/*   Future<void> _userListRefresh() async {
    // methodumuzda varolan listeye ekleme yaptığı için refresh yaptığımızda
    // eski var olan verilerimizi sıfırlamamız gerek. aksi halde üst üste eklenecek
    // verilerimiz.

    _allUsers = [];
    // sıfırlamak lazım bunu da
    _hasMore = true;
    _lastGetUser = null;
    getUser();
  }
 
 */

  void bringMoreUsers() {
    if (_isLoading == false) {
      _isLoading = true;
      final _allUsersViewModel =
          Provider.of<AllUsersViewModel>(context, listen: false);

      _allUsersViewModel.bringMoreUsers();
      _isLoading = false;
    }
  }

  void _listScrollListener() {
    // scroll controlleri sürekli kontrol etmemize gerek yok
    // ya yukarı ya da aşşağı vardıysa kontrol etsek yeterli olur.

    // minScroolExtent listenin en başına geldiğimizde oluşur
    // maxScrollExtent listenin en altına geldiğimizde olusur
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      bringMoreUsers();
    }
  }
}
