import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';

class SomethingWentWrong extends StatelessWidget {
  const SomethingWentWrong({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomTextWidget(
          text: 'Something went wrong in app',
          textColor: AppColors.error,
          fontSize: 18.0,
          isBold: true,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}