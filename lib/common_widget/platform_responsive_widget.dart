import 'dart:io';

import 'package:flutter/cupertino.dart';

abstract class PlatformResponsiveWidget extends StatelessWidget {
  const PlatformResponsiveWidget({Key? key}) : super(key: key);

  Widget buildAndroidWidget(BuildContext context);
  Widget buildIOSWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return buildIOSWidget(context);
    }
    return buildAndroidWidget(context);
  }
}
