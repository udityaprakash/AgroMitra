import 'dart:developer';

import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/internet-connectivity.dart';
import 'package:agromitra/screens/authScreen/somethingWentWrong.dart';
import 'package:agromitra/screens/splashScreen.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomRoute {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) {
      final connectivityProvider = Provider.of<ConnectivityProvider>(context);

      if (!connectivityProvider.isOnline) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ScaffoldMessenger.of(context).mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomTextWidget(
                  text: AppLocalizations.of(context)!.nointernet,
                  textColor: AppColors.textHint),
                duration: Duration(days: 1), // Show indefinitely until dismissed
              ),
            );
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ScaffoldMessenger.of(context).mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
        });
      }

      switch (settings.name) {
        case "/":
          return SplashScreen();
      }
      log("Settings name: " + (settings.name).toString());
      return SomethingWentWrong();
    });
  }
}
