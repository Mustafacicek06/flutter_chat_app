import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/services/auth_base.dart';
import 'dart:async';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService implements AuthBase {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<UserModel> currentUser() async {
    User? user = await _firebaseAuth.currentUser;
    print('firebase user : ' + user.toString());
    return _userFromFirebase(user);
    //   try {
    // } catch (e) {
    //   print('HATA CURRENT USER ' + e.toString());
    //   return null;
    // }
  }

  UserModel _userFromFirebase(User? user) {
    // if (user == null) {
    //   return null;
    // } else {
    //
    // }
    return UserModel(userID: user!.uid, email: user.email!);
  }

  @override
  Future<UserModel?> signInAnonymously() async {
    try {
      UserCredential result = await _firebaseAuth.signInAnonymously();
      return _userFromFirebase(result.user!);
    } catch (e) {
      print('Signin Anonymously hata ' + e.toString());
      return null;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      final _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();

      //await FacebookAuth.instance.logOut();

      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      print('Sign out hata : ' + e.toString());
      return false;
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    User? _user = userCredential.user;
    return _userFromFirebase(_user);
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    Map? _userData;
    // if null , not login not data
    final result =
        await FacebookAuth.i.login(permissions: ['public_profile', 'email']);

    if (result.status == LoginStatus.success) {
      final requestData = await FacebookAuth.i.getUserData(
        fields: "email, name",
      );

      _userData = requestData;
    } else if (result.status == LoginStatus.failed) {
      print('Firebase Auth service oturum açma hata : ' + result.message!);
    } else if (result.status == LoginStatus.cancelled) {
      print('Firebase Auth service oturum açma iptal edildi : ' +
          result.message!);
    }

    throw UnimplementedError;
  }

  @override
  Future<UserModel> createUserWithEmailandPassword(
      String eMail, String sifre) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: eMail, password: sifre);
    return _userFromFirebase(result.user!);
  }

  @override
  Future<UserModel> signInWithEmailandPassword(
      String eMail, String sifre) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: eMail, password: sifre);
    return _userFromFirebase(result.user!);
  }
}
// null safety unsupported
// final _facebookLogin = FacebookLogin();
    // FacebookLoginResult _faceResult =
    //     await _facebookLogin.logIn(['public_profile', 'email']);

    // switch (_faceResult.status) {
    //   case FacebookLoginStatus.error:
    //     print('Hata cikti : ' + _faceResult.errorMessage);
    //     break;

    //   case FacebookLoginStatus.loggedIn:
    //     if (_faceResult.accessToken != null) {
    //       UserCredential userCredential = await _firebaseAuth
    //           .signInWithCredential(FacebookAuthProvider.credential(
    //               _faceResult.accessToken.token));
    //       User? _user = userCredential.user;
    //       return _userFromFirebase(_user);
    //     }

    //     break;

    //   case FacebookLoginStatus.cancelledByUser:
    //     print('Kullanıcı girişi iptal etti.');
    //     break;
    // }