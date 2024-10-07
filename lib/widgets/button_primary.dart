import 'package:flutter/material.dart';

class ButtonPrimary extends StatelessWidget {
  final String? text;
  final Function()? onTap;

  const ButtonPrimary({super.key, this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 100,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            // primary: greenColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        child: Text(text!),
      ),
    );
  }
}
