import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/common_widget/platform_responsive_alert_dialog.dart';
import 'package:flutter_chat_app/common_widget/social_login_button.dart';
import 'package:flutter_chat_app/model/user.dart';
import 'package:flutter_chat_app/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

enum FormType { register, login }

class EmailAndLoginSignPage extends StatefulWidget {
  const EmailAndLoginSignPage({Key? key}) : super(key: key);

  @override
  State<EmailAndLoginSignPage> createState() => _EmailSignInAndLoginState();
}

class _EmailSignInAndLoginState extends State<EmailAndLoginSignPage> {
  @override
  // ignore: override_on_non_overriding_member
  String _email = '', _sifre = '';
  String _butonText = '', _linkText = '';
  var _formType = FormType.login;

  final emailEditinController = TextEditingController();
  final textEditinController = TextEditingController();
  void _formSubmit() async {
    debugPrint('email' + _email + 'sifre' + _sifre);

    // ChangeNotifierProvider ile tree'ye yerleştirdiğimiz userViewModel
    // kullanımı için burada çağırıyoruz.
    // sign in kontrolu yapılıyor
    //  Kayıt ol durumunda ise hesap oluşturulması için
    // Giriş yapma durumunda ise giriş yapması için butonumuzu ayarlarıyoruz.
    final _userModel = Provider.of<UserViewModel>(context, listen: false);
    if (_formType == FormType.login) {
      try {
        UserModel? _signInUser =
            await _userModel.signInWithEmailandPassword(_email, _sifre);
        debugPrint('oturum açan user id : ' + _signInUser.userID);
        // user giriş yaptıktan sonra homepage'e geri dönüp
        // dialog penceresini kapatmak için
        // buradaki built'imiz bitmeden homepage'i build etmeye çalıştığı için
        // böyle bi önlem aldım.
        Future.delayed(
          const Duration(milliseconds: 10),
          () => Navigator.of(context).pop(),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          debugPrint(
              "Widget oturum açma hata yakalandı : " + e.code.toString());
          PlatformResponsiveAlertDialog(
            anaButonYazisi: "Tamam",
            baslik: "Oturum Açma Hata",
            icerik:
                "Bu kullanıcı sistemde bulunmamaktadır. Lütfen kullanıcı oluşturunuz.",
          ).myShowMethod(context);
        } else if (e.code == 'wrong-password') {
          debugPrint(
              "Widget oturum açma hata yakalandı : " + e.code.toString());
          PlatformResponsiveAlertDialog(
            anaButonYazisi: "Tamam",
            baslik: "Oturum Açma Hata",
            icerik: "Kullanıcı adı veya Şifre hatalı.",
          ).myShowMethod(context);
        }
      }
    } else {
      try {
        UserModel? _createUser =
            await _userModel.createUserWithEmailandPassword(_email, _sifre);
        debugPrint('oturum açan user id : ' + _createUser!.userID);
        // user giriş yaptıktan sonra homepage'e geri dönüp
        // dialog penceresini kapatmak için
        // buradaki built'imiz bitmeden homepage'i build etmeye çalıştığı için
        // böyle bi önlem aldım.
        Future.delayed(
          const Duration(milliseconds: 10),
          // giriş  sayfasına kadar pop yap
          () => Navigator.of(context).popUntil(ModalRoute.withName("/")),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-passowrd') {
          debugPrint('Widget user oluşturma hatası : ' + e.code.toString());
          PlatformResponsiveAlertDialog(
            anaButonYazisi: "Tamam",
            baslik: "Kullanıcı Oluşturma HATA",
            icerik: 'En az 8 karakterden Oluşmalı.\n'
                'Harflerin yanı sıra, rakam ve “?, @, !, #, %, +, -, *, %” gibi özel karakterler içermeli.\n'
                'Büyük ve küçük harfler bir arada kullanılmalı.',
          ).myShowMethod(context);
        } else if (e.code == 'email-already-in-use') {
          debugPrint('Widget user oluşturma hatası : ' + e.code.toString());

          PlatformResponsiveAlertDialog(
            anaButonYazisi: "Tamam",
            baslik: "Kullanıcı Oluşturma HATA",
            icerik: 'Bu Email adresi zaten kullanımda',
          ).myShowMethod(context);
        } else {
          PlatformResponsiveAlertDialog(
            anaButonYazisi: "Tamam",
            baslik: "Kullanıcı Oluşturma HATA",
            icerik:
                'Geçersiz Email adresi. Lütfen doğru bir email adresi giriniz.',
          ).myShowMethod(context);

          debugPrint('Widget user oluşturma hatası : ' + e.code.toString());
        }
      }
    }
  }

  void _degistir() {
    setState(() {
      _formType =
          _formType == FormType.login ? FormType.register : FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    _butonText = _formType == FormType.login ? "Giriş Yap" : "Kayıt Ol";
    _linkText = _formType == FormType.login ? "Hesap Oluşturun" : "Giriş Yapın";
    final _userModel = Provider.of<UserViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş / Kayıt'),
      ),
      // elemanlar sığmazsa yukarı aşşağı oynaması için
      // singleChildScrollView
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            child: Column(
          children: [
            TextFormField(
              controller: emailEditinController,
              onChanged: (text) {
                _email = text;
              },
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  errorText: _userModel.emailErrorMessage != null
                      ? _userModel.emailErrorMessage
                      : null,
                  prefixIcon: const Icon(Icons.mail),
                  hintText: 'Email',
                  labelText: 'Email',
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              obscureText: true,
              controller: textEditinController,
              onChanged: (text) {
                _sifre = text;
              },
              decoration: InputDecoration(
                  errorText: _userModel.passwordErrorMessage != null
                      ? _userModel.passwordErrorMessage
                      : null,
                  prefixIcon: const Icon(Icons.password),
                  hintText: 'Şifre',
                  labelText: 'Şifre',
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(
              height: 8,
            ),
            SocialLoginButton(
              onPressed: () => _formSubmit(),
              butonText: _butonText,
              butonColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(onPressed: () => _degistir(), child: Text(_linkText))
          ],
        )),
      )),
    );
  }
}
