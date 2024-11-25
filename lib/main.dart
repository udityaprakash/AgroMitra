import 'dart:io';

import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/internet-connectivity.dart';
import 'package:agromitra/functions/languageProvider.dart';
import 'package:agromitra/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
                ChangeNotifierProvider(create: (context) => LanguageProvider()),
              ],
              child: const MyApp(),
            ),
          ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          locale: context.watch<LanguageProvider>().selectedLocale, // Locale is now dynamically set using LanguageProvider
          initialRoute: '/',
          onGenerateRoute: CustomRoute.allRoutes,
          theme: ThemeData(
            fontFamily: 'Parkinsans',
            scaffoldBackgroundColor: AppColors.background,
            textTheme: ThemeData.dark().textTheme,
          ),
        );
      },
    );
  }
}
