import 'package:flutter/material.dart';
import 'package:flutter_chat_app/app/home_page.dart';
import 'package:flutter_chat_app/app/sign_in/sign_in_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_app/viewmodel/user_model.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _userViewModel = Provider.of<UserViewModel>(context);

    if (_userViewModel.state == ViewState.idle) {
      if (_userViewModel.user == null) {
        return SignInPage();
      } else {
        return HomePage(userModel: _userViewModel.user);
      }
    } else {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
