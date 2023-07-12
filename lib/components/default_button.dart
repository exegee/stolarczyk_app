import 'package:flutter/material.dart';
import 'package:stolarczyk_app/constants.dart';
import 'package:stolarczyk_app/size_config.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({super.key, this.text, required this.onPress});

  final String? text;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(300),
      height: getProportionateScreenHeight(50),
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          foregroundColor: Colors.white,
          backgroundColor: kPrimaryColor,
        ),
        onPressed: onPress as void Function(),
        child: Text(
          text!,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(18),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
