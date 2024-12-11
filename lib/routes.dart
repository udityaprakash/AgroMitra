import 'dart:developer';

import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/internet-connectivity.dart';
import 'package:agromitra/screens/agrilabs.dart';
import 'package:agromitra/screens/authScreen/emailScreenforgetPassword.dart';
import 'package:agromitra/screens/authScreen/enterOtpScreen.dart';
import 'package:agromitra/screens/authScreen/loginScreen.dart';
import 'package:agromitra/screens/authScreen/selectLangScreen.dart';
import 'package:agromitra/screens/authScreen/setNewPassword.dart';
import 'package:agromitra/screens/authScreen/signupScreen.dart';
import 'package:agromitra/screens/authScreen/somethingWentWrong.dart';
import 'package:agromitra/screens/chatAi.dart';
import 'package:agromitra/screens/featureScreens/appfeatures.dart';
import 'package:agromitra/screens/homescreen.dart';
import 'package:agromitra/screens/homescreenScreens/FertilizerCalculator.dart';
import 'package:agromitra/screens/homescreenScreens/analysingdata.dart';
import 'package:agromitra/screens/homescreenScreens/captureSoilImage.dart';
import 'package:agromitra/screens/homescreenScreens/detailed_crop_posts.dart';
import 'package:agromitra/screens/homescreenScreens/sevendayforecast.dart';
import 'package:agromitra/screens/homescreenScreens/soil_analysed_report.dart';
import 'package:agromitra/screens/homescreenScreens/soilgridmaps.dart';
import 'package:agromitra/screens/mainScreen.dart';
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
        case "/selectLanguage":
          return LanguageSelection(); 
        case "/introScreen":
          return IntroScreen();   
        case "/login":
          return LoginScreen();
        case "/signup":
          return SignupScreen();
        case "/enterOtp":
          final args = settings.arguments as Map<String, dynamic>;
          return EnterOtpScreen(email: args['email'], destinationScreen: args['destinationScreen']);  
        case "/forgotPassword":
          return EmailScreen();
        case "/setNewPassword":
          final args = settings.arguments as Map<String, dynamic>;
          return ResetPasswordScreen(email:args['email']);
        case "/mainScreen":
          return MainScreen();
        case "/homescreen":
          return HomeScreen();
        case "/soilgridmap":
          final args = settings.arguments as Map<String, dynamic>;
          return SoilGridMap(lat: args['lat'], lon: args['lon'], lang: args['lang']);  
        case "/captureSoilImage":
          return CaptureSoilImage();
        case "/soilanalyis":
          final args = settings.arguments as Map<String, dynamic>;
          return SoilAnalysisScreen(images: args['images']);
        case "/detailedCropPosts":
          final args = settings.arguments as Map<String, dynamic>;
          return CropPostsScreen(
            cropName: args['crop_name']
            );
        case "/soilAnalyzedReport":
          final args = settings.arguments as Map<String, dynamic>;
          return SoilDataAnalyzed(soilData: args['soilData']);
        case "/chat":
          return ChatScreen();
        case "/fertiliserCalculator":
          return StateAndCropSelector();  
        case "/weatherForecast":
        final args = settings.arguments as Map<String, dynamic>;
          return WeatherForecastScreen( latitude: args['lat'], longitude: args['lon']);

        case "/agriLabs":
        final args = settings.arguments as Map<String, dynamic>;
          return FetchIdsAndCenters(districtName: args['districtName'], stateName: args['stateName']); 


      }
      log("Settings name: " + (settings.name).toString());
      return SomethingWentWrong();
    });
  }
}