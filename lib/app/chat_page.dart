import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/app/chat.dart';
import 'package:flutter_chat_app/model/chats_model.dart';
import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/viewmodel/chat_view_model.dart';
import 'package:flutter_chat_app/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konuşmalar'),
      ),
      body: FutureBuilder<List<ChatsModel>>(
        future: _userViewModel.getAllConversations(_userViewModel.user!.userID),
        builder: (context, chatList) {
          if (!chatList.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var allChat = chatList.data;
            if (allChat != null) {
              return RefreshIndicator(
                onRefresh: _chatListRefresh,
                child: ListView.builder(
                  itemCount: allChat.length,
                  itemBuilder: (context, index) {
                    var currentChat = allChat[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider(
                                      create: (context) => ChatViewModel(
                                          currentUser: _userViewModel.user!,
                                          interlocutorUser: UserModel.idveResim(
                                              userID: currentChat.interlocutor,
                                              profilUrl: currentChat
                                                  .interlocutorProfilUrl)),
                                      child: Chat(),
                                    )));
                      },
                      child: ListTile(
                        title: Text(currentChat.lastSendMessage),
                        subtitle: Text("${currentChat.interlocutorUsername}  " +
                            currentChat.timeDifferenceRead!),
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.withAlpha(40),
                          backgroundImage:
                              NetworkImage(currentChat.interlocutorProfilUrl!),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return RefreshIndicator(
                onRefresh: _chatListRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_sharp,
                            color: Theme.of(context).primaryColor,
                            size: 120,
                          ),
                          const Text(
                            "Henüz Konuşma Yok",
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
          }
        },
      ),
    );
  }

  // 1 milyon mesaj olsa bile firestore bana 3 konuşma varsa 3 ünü getireceği için
  // 3 birim faturalandırılmış olacağım. aksi halde 1 milyonu da tek tek okumam
  // gerekir ve batardım muhtemelen.
  void bringMyChats() async {
    final _userViewModel = Provider.of<UserViewModel>(context);

    var _myChats = await FirebaseFirestore.instance
        .collection("konusmalar")
        .where("konusma_sahibi", isEqualTo: _userViewModel.user!.userID)
        .orderBy('olusturulma_tarihi', descending: true)
        .get();

    debugPrint("my chat geçti . ");
    for (var chat in _myChats.docs) {
      debugPrint('konusma : ' + chat.data().toString());
    }
  }

  Future<void> _chatListRefresh() async {
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));
  }
}
