import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/message.dart';
import 'package:flutter_chat_app/viewmodel/chat_view_model.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ScrollController _scrollController = ScrollController();
  var _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _chatViewModel = Provider.of<ChatViewModel>(context);

    // mesajları 2 farklı yerde tutmamız gerekiyor
    // aksi halde taraflardan biri mesajlarını silerse diğerininde
    // mesajları silinmiş olacak bu istenmeyen bir durum olur bizim için.

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 45,
        actions: [
          CircleAvatar(
            radius: 5,
            backgroundImage:
                NetworkImage(_chatViewModel.interlocutorUser.profilUrl!),
          ),
        ],
      ),
      body: _chatViewModel.state == ChatViewState.busy
          ? _uploadingNewUsers()
          : Center(
              child: Column(
                children: [
                  _buildMessageList(),
                  _buildNewMessageEnter(),
                ],
              ),
            ),
    );
  }

  Widget _buildMessageList() {
    return Consumer<ChatViewModel>(builder: (context, model, child) {
      return Expanded(
        child: ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: model.hasMoreLoading
              ? model.messageList.length + 1
              : model.messageList.length,
          itemBuilder: (context, index) {
            if (model.messageList.length == index && model.hasMoreLoading) {
              return _uploadingNewUsers();
            } else {
              return _createSpeechBubble(model.messageList[index]);
            }
          },
        ),
      );
    });
  }

  Widget _buildNewMessageEnter() {
    final _chatViewModel = Provider.of<ChatViewModel>(context);

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
        child: Row(
          children: [
            Expanded(
                child: TextField(
              controller: _messageController,
              cursorColor: Colors.blueGrey,
              style: const TextStyle(fontSize: 16.0, color: Colors.black),
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Mesaj Yazın',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none)),
            )),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: FloatingActionButton(
                  child: const Icon(
                    Icons.navigation,
                    size: 35,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    // boş mesaj yollanmaması için bir kontrol yapalım
                    if (_messageController.text.trim().isNotEmpty) {
                      MyMessageClass _toBeSavedMessage = MyMessageClass(
                          fromWho: _chatViewModel.currentUser.userID,
                          toWho: _chatViewModel.interlocutorUser.userID,
                          fromMe: true,
                          message: _messageController.text);
                      var result =
                          await _chatViewModel.saveMessage(_toBeSavedMessage);
                      if (result) {
                        _messageController.clear();
                        _scrollController.animateTo(0.0,
                            duration: const Duration(microseconds: 10),
                            curve: Curves.easeOut);
                      }
                    }
                  },
                  elevation: 0,
                  backgroundColor: Colors.blue.shade300),
            )
          ],
        ),
      ),
    );
  }

  Widget _createSpeechBubble(MyMessageClass currentMessage) {
    Color _fromMessageColor = Colors.grey.shade300;
    Color _toMessageColor = Theme.of(context).primaryColor.withOpacity(0.5);
    final _chatViewModel = Provider.of<ChatViewModel>(context);
    var _isMyMessage = currentMessage.fromMe;

    if (_isMyMessage) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _toMessageColor),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(4),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(currentMessage.message),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  "${currentMessage.dateMessage?.toDate().hour}:${currentMessage.dateMessage?.toDate().minute}",
                  style: const TextStyle(color: Colors.black45),
                  textAlign: TextAlign.end,
                )
              ]),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      NetworkImage(_chatViewModel.interlocutorUser.profilUrl!),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _fromMessageColor),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(4),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currentMessage.message,
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            "${currentMessage.dateMessage!.toDate().hour}:${currentMessage.dateMessage!.toDate().minute}",
                            style: const TextStyle(color: Colors.black45),
                            textAlign: TextAlign.end,
                          )
                        ]),
                  ),
                )
              ],
            )
          ],
        ),
      );
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      fetchOldMessage();
    }
  }

  void fetchOldMessage() async {
    final _chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    if (_isLoading == false) {
      _isLoading = true;

      _chatViewModel.fetchMoreMessage();
      _isLoading = false;
    }
  }

  _uploadingNewUsers() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
