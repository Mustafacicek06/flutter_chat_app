import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton(
      {required this.onPressed,
      this.butonColor = Colors.purple,
      this.butonIcon,
      required this.butonText,
      this.height,
      this.radius = 16,
      this.textColor = Colors.white,
      Key? key})
      : assert(butonText != null, butonIcon != null),
        super(key: key);

  final String? butonText;
  final Color? butonColor;
  final Color? textColor;
  final double? radius;
  final double? height;
  // ıcon veya image sınıfından olacağından dolayı
  // bir üst sınıfı widget olarak tanımlamak daha mantıklı.
  final Widget? butonIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(butonColor!),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Spreads, Collection-if , Collection-for
          if (butonIcon != null) ...[
            butonIcon!,
            Text(
              butonText!,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
            Opacity(opacity: 0, child: butonIcon!),
          ],
          if (butonIcon == null) ...[
            Container(),
            Text(
              butonText!,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
            Container(),
          ]
        ],
      ),
    );
  }
}
/*
    ESKİ YONTEM
          butonIcon != null ? butonIcon! : Container(),
          Text(
            butonText!,
            style: TextStyle(color: textColor),
          ),
          butonIcon != null
              ? Opacity(opacity: 0, child: butonIcon!)
              : Container(),
*/
