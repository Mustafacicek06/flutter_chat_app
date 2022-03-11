import 'package:flutter/material.dart';
import 'package:flutter_chat_app/app/chat_page.dart';
import 'package:flutter_chat_app/app/my_custom_buttom_navi.dart';
import 'package:flutter_chat_app/app/profil.dart';
import 'package:flutter_chat_app/app/tab_items.dart';
import 'package:flutter_chat_app/app/users.dart';
import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/viewmodel/all_users_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  UserModel? userModel;
  HomePage({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // bottom başlangıçta kullanicilar ile başlayacak
  TabItem _currentTab = TabItem.kullanicilar;

  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.kullanicilar: GlobalKey<NavigatorState>(),
    TabItem.sohbetler: GlobalKey<NavigatorState>(),
    TabItem.profil: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, Widget> allPages() {
    return {
      TabItem.kullanicilar: ChangeNotifierProvider(
          create: (context) => AllUsersViewModel(), child: UsersPage()),
      TabItem.sohbetler: const ChatPage(),
      TabItem.profil: const ProfilPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    // pop olamaz diyebilirsin bu mehtod ile
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[_currentTab]!.currentState!.maybePop(),
      child: MyCustomButtomNavigation(
          navigatorKeys: navigatorKeys,
          pageBuilder: allPages(),
          currentTab: _currentTab,
          onSelectedTab: (secilenTab) {
            if (secilenTab == _currentTab) {
              navigatorKeys[secilenTab]!
                  .currentState!
                  .popUntil((route) => route.isFirst);
            } else {
// secili kalmaması için yeni seçtiğimiz tabı güncellememzi gerekir.
              setState(() {
                _currentTab = secilenTab;
              });
            }

            print('Seçilen Tab item : ' + secilenTab.toString());
          }),
    );
  }
}
// Future<bool> _cikisYap(BuildContext context) async {
//     final _userViewModel = Provider.of<UserViewModel>(context, listen: false);

//     bool result = await _userViewModel.signOut();

//     return result;
//   }