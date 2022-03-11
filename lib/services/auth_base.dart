import 'package:flutter_chat_app/model/user.dart';

abstract class AuthBase {
  Future<UserModel?> currentUser();
  Future<UserModel?> signInAnonymously();
  Future<bool> signOut();
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithFacebook();
  Future<UserModel> signInWithEmailandPassword(String eMail, String sifre);
  Future<UserModel?> createUserWithEmailandPassword(String eMail, String sifre);
}
