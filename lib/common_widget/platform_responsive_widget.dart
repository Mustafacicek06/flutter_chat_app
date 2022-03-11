import 'dart:io';

import 'package:flutter/cupertino.dart';

abstract class PlatformResponsiveWidget extends StatelessWidget {
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
