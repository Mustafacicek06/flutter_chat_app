import 'package:flutter/material.dart';
import 'package:flutter_chat_app/app/sign_in/email_sign_in_and_login.dart';
import 'package:flutter_chat_app/common_widget/social_login_button.dart';
import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/viewmodel/user_model.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatelessWidget {
  /* 
  void _misafirGirisi(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);

    // UserCredential userCredential =
    //     await FirebaseAuth.instance.signInAnonymously();
    // firebase user artık bunun içinde
    UserModel? _userModel = await _userViewModel.signInAnonymously();
    // ALDIK

    print('Oturum açan user id: ' + _userModel!.userID);
    //userCredential.user;
  }
 */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Container(
        decoration: const BoxDecoration(
            image: const DecorationImage(
                fit: BoxFit.fitHeight,
                image: NetworkImage(
                    "https://cdn.wallpapersafari.com/55/73/ghY4rc.jpg",
                    scale: 1.0))),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.max,
            //crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "ChatApp Aile'sine katılmak için üye ol. Haydi chat zamanı.",
                style: GoogleFonts.lato(
                    fontStyle: FontStyle.italic,
                    fontSize: 21,
                    color: Colors.white.withBlue(230)),
                textAlign: TextAlign.right,
              ),
              const SizedBox(
                height: 175,
              ),
              SocialLoginButton(
                butonText: 'Gmail ile Giriş Yap',
                textColor: Colors.black87,
                onPressed: () => _googleWithSignIn(context),
                butonIcon: Image.asset('images/google-logo.png'),
                butonColor: Colors.white,
              ),
              SocialLoginButton(
                butonText: 'Facebook ile Giriş Yap',
                textColor: Colors.white,
                height: 40,
                radius: 40,
                onPressed: () => _facebookWithSignIn(context),
                butonIcon: Image.asset('images/facebook-logo.png'),
                butonColor: Color(0xFF334D92),
              ),
              SocialLoginButton(
                onPressed: () => _emailAndPasswordSign(context),
                butonIcon: const Icon(
                  Icons.email,
                  size: 32,
                  color: Colors.white,
                ),
                butonText: 'Email ve Şifre ile Giriş Yap',
              ),
              const SizedBox(
                height: 85,
              ),
            ]),
      ),
    );
  }

  void _emailAndPasswordSign(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => EmailAndLoginSignPage(),
    ));
  }

  void _googleWithSignIn(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);

    // UserCredential userCredential =
    //     await FirebaseAuth.instance.signInAnonymously();
    // firebase user artık bunun içinde
    UserModel? _userModel = await _userViewModel.signInWithGoogle();
    // ALDIK
    print('Oturum açan user id: ' + _userModel.userID);

    //userCredential.user;
  }

  void _facebookWithSignIn(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);

    // UserCredential userCredential =
    //     await FirebaseAuth.instance.signInAnonymously();
    // firebase user artık bunun içinde
    UserModel? _userModel = await _userViewModel.signInWithFacebook();
    // ALDIK
    print('Oturum açan user id: ' + _userModel.userID);

    //userCredential.user;
  }
}
