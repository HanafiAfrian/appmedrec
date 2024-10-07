import 'package:flutter/material.dart';
import '../theme.dart';

class WidgetIlustration extends StatelessWidget {
  final Widget? child;
  final String? image;
  final String? title;
  final String? subtitle1;
  const WidgetIlustration(
      {super.key, this.child, this.image, this.title, this.subtitle1});

  get regulerTextStyle => null;

  get greyLightColor => null;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          image!,
          width: 250,
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          title!,
          style: regulerTextStyle.copyWith(fontSize: 25),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 16,
        ),
        Column(
          children: [
            Text(
              subtitle1!,
              style: regulerTextStyle.copyWith(
                  fontSize: 18, color: greyLightColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            child ?? const SizedBox(),
          ],
        ),
      ],
    );
  }
}
