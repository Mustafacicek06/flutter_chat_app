import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/app/tab_items.dart';

class MyCustomButtomNavigation extends StatelessWidget {
  const MyCustomButtomNavigation(
      {Key? key,
      required this.pageBuilder,
      required this.currentTab,
      required this.navigatorKeys,
      required this.onSelectedTab})
      : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectedTab;
  final Map<TabItem, Widget> pageBuilder;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          _navItemCreate(TabItem.kullanicilar),
          _navItemCreate(TabItem.sohbetler),
          _navItemCreate(TabItem.profil)
        ],
        // onSelectedTab'ı burada kullanarak basıldıgındaki değerlerimğizi alırız.
        onTap: (index) {
          onSelectedTab(TabItem.values[index]);
        },
      ),
      tabBuilder: (context, index) {
        final viewItem = TabItem.values[index];
        return CupertinoTabView(
          navigatorKey: navigatorKeys[viewItem],
          builder: (context) {
            return pageBuilder[viewItem]!;
          },
        );
      },
    );
  }

  BottomNavigationBarItem _navItemCreate(TabItem tabItem) {
    final toBeCreatedTab = TabItemData.tumTablar[tabItem];

    return BottomNavigationBarItem(
        icon: Icon(toBeCreatedTab!.icon), label: toBeCreatedTab.title);
  }
}
