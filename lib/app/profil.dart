import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/common_widget/platform_responsive_alert_dialog.dart';
import 'package:flutter_chat_app/common_widget/social_login_button.dart';
import 'package:flutter_chat_app/viewmodel/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // textFormField'in içinde alacağımız data'ları kullanabilmek için
  // controller geçip field'a kullanabiliyoruz.
  File? _profilePhoto;

  late TextEditingController _controllerUserName;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controllerUserName = TextEditingController(text: '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _controllerUserName.dispose();
  }

  Future _kameradanFotoCek() async {
    var _image =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    setState(() {
      if (_image != null) {
        _profilePhoto = File(_image.path);
        Navigator.of(context).pop();
      } else {
        // showing a alert with error
        PlatformResponsiveAlertDialog(
            baslik: 'Hata',
            icerik: 'Resim Yüklenirken hata oluştu. Lütfen tekrar deneyiniz.',
            anaButonYazisi: 'Tamam');
      }
    });
  }

  Future _galeridenFotoSec() async {
    final _image =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    setState(() {
      if (_image != null) {
        _profilePhoto = File(_image.path);
        Navigator.of(context).pop();
      } else {
        // showing a alert with error
        PlatformResponsiveAlertDialog(
            baslik: 'Hata',
            icerik: 'Resim Yüklenirken hata oluştu. Lütfen tekrar deneyiniz.',
            anaButonYazisi: 'Tamam');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel _userViewModel =
        Provider.of<UserViewModel>(context, listen: false);
    debugPrint('user degerleri : ' + _userViewModel.user.toString());
    _controllerUserName.text = _userViewModel.user!.userName.toString();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Profil"),
        actions: [
          TextButton(
              onPressed: () => _cikisIcinOnayIste(context),
              child: const Text(
                'Çıkış',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ))
        ],
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          height: 160,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera),
                                title: const Text('Kameradan Çek'),
                                onTap: () {
                                  _kameradanFotoCek();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.image),
                                title: const Text('Galeriden Seç'),
                                onTap: () {
                                  _galeridenFotoSec();
                                },
                              )
                            ],
                          ),
                        );
                      });
                },
                child: CircleAvatar(
                  radius: 85,
                  backgroundColor: Colors.grey.shade400,
                  backgroundImage: _profilePhoto == null
                      ? NetworkImage((_userViewModel.user!.profilUrl)!)
                      : Image.file(
                          _profilePhoto!,
                          fit: BoxFit.cover,
                        ).image,
                ),
              ),
            ),
            // readOnly'yi emailini değiştiremesin diye yaptım
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: _userViewModel.user!.email,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Emailiniz',
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _controllerUserName,
                readOnly: false,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  hintText: 'Kullanıcı Adı',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SocialLoginButton(
                  onPressed: () {
                    _userNameGuncelle(context);
                    _profilePhotoGuncelle(context);
                  },
                  butonText: 'Değişiklikleri Kaydet'),
            )
          ],
        ),
      )),
    );
  }

  Future<bool> _cikisYap(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);

    bool result = await _userViewModel.signOut();

    return result;
  }

  Future _cikisIcinOnayIste(BuildContext context) async {
    final result = await PlatformResponsiveAlertDialog(
      baslik: "Emin Misiniz ?",
      icerik: "Çıkmak istediğinizden emin msiniz?",
      anaButonYazisi: "Evet",
      iptalButonYazisi: "Vazgeç",
    ).myShowMethod(context);
    if (result == true) {
      _cikisYap(context);
    }
  }

  void _userNameGuncelle(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    if (_userViewModel.user!.userName != _controllerUserName.text) {
      var updateResult = await _userViewModel.updateUserName(
          _userViewModel.user!.userID, _controllerUserName.text);
      if (updateResult) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            content: const Text(
                'Kullanıcı Adınız başarılı bir şekilde değiştirildi.')));
      } else {
        _controllerUserName.text = _userViewModel.user!.userName.toString();
        PlatformResponsiveAlertDialog(
          anaButonYazisi: "Tamam",
          baslik: "Hata",
          icerik:
              "Kullanıcı adı zaten kullanımda. Farklı bir kullanıcı adı giriniz.",
        ).myShowMethod(context);
      }
    }
  }

  void _profilePhotoGuncelle(BuildContext context) async {
    final _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    if (_profilePhoto != null) {
      var url = await _userViewModel.uploadFile(
          _userViewModel.user!.userID, "profil_foto", _profilePhoto);
      debugPrint('download url : ' + url);

      if (url != _userViewModel.user!.profilUrl) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            content: const Text('Profil Fotoğrafı Güncellendi.')));
      }
    }
  }
}
