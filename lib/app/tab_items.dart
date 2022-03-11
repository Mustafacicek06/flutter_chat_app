import 'package:flutter/material.dart';

enum TabItem { kullanicilar, sohbetler, profil }

class TabItemData {
  final String title;
  final IconData icon;

  TabItemData(this.title, this.icon);

  static Map<TabItem, TabItemData> tumTablar = {
    TabItem.kullanicilar:
        TabItemData("Kullanıcılar", Icons.supervised_user_circle),
    TabItem.sohbetler: TabItemData("Sohbetler", Icons.chat),
    TabItem.profil: TabItemData("Profil", Icons.person),
  };
}
