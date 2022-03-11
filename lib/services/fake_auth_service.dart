import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/services/auth_base.dart';

class FakeAuthService implements AuthBase {
  String userID = '123123213';
  @override
  Future<UserModel> currentUser() async {
    return await Future.value(
        UserModel(userID: userID, email: 'fakeuser@fake.com'));
  }

  @override
  Future<UserModel> signInAnonymously() async {
    return await Future.delayed(const Duration(seconds: 2),
        () => UserModel(userID: userID, email: 'fakeuser@fake.com'));
  }

  @override
  Future<bool> signOut() {
    // ignore: todo
    // TODO: implement signOut

    return Future.value(true);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    return await Future.delayed(
        const Duration(seconds: 2),
        () => UserModel(
            userID: 'google_user_id_213', email: 'fakeuser@fake.com'));
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    return await Future.delayed(
        const Duration(seconds: 2),
        () => UserModel(
            userID: 'facebook_user_id_1234', email: 'fakeuser@fake.com'));
  }

  @override
  Future<UserModel> createUserWithEmailandPassword(
      String eMail, String sifre) async {
    return await Future.delayed(
        const Duration(seconds: 2),
        () => UserModel(
            userID: 'created_user_id_!23123', email: 'fakeuser@fake.com'));
  }

  @override
  Future<UserModel> signInWithEmailandPassword(
      String eMail, String sifre) async {
    return await Future.delayed(const Duration(seconds: 2),
        () => UserModel(userID: 'sign_in_user', email: 'fakeuser@fake.com'));
  }
}
