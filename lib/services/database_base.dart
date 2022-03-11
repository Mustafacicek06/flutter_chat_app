import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/model/chats_model.dart';
import 'package:flutter_chat_app/model/message.dart';
import 'package:flutter_chat_app/model/user.dart';

abstract class DBBase {
  Future<bool> saveUser(UserModel userModel);
  Future<UserModel> readUser(String userID);
  Future<bool> updateUserName(String userID, String newUserName);
  Future<bool> updateProfilePhoto(String userID, String profilFotoUrl);

  Future<List<UserModel>> getUserWithPagination(
      UserModel lastGetUser, int toBeGetElementCount);
  Future<List<ChatsModel>> getAllConversations(String userID);
  Stream<List<MyMessageClass>> getMessages(
      String currentUserID, String chattingUserID);

  Future<DateTime> showDate(String userID);
}
