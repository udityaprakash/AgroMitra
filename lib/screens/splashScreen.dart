import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-input-field.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Timer(const Duration(seconds: 3), () {
    //   Navigator.pushReplacementNamed(context, '/homepageredirector');
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.appLogoBackground,
        body: Center(
            child: Container(
              height: 500,
              child: Column(
                children: [
                  Image.asset("assets/images/app_logo/appLogoPng.png"),
                  const SizedBox(height: 20),
                  CustomTextWidget(
                    text: AppLocalizations.of(context)!.hello, 
                    textColor: AppColors.primary,
                    fontSize: 30,
                    isBold: true),
                ],

              ),
            )));
  }
}
