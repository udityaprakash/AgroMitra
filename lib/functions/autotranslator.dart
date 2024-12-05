import 'dart:developer';

import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/languageProvider.dart';
import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:translator/translator.dart';

class AutoTranslator {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translateToAppLanguage(String text) async {
    final String storedLang = await StorageManager.readData('Lang');

    final translation =
        await _translator.translate(text, from: 'en', to: storedLang);

    return translation.text;
  }

  Widget buildTranslatedText(BuildContext context, String inputText,
      {textColor = AppColors.textPrimary, fontSize = 16.0, fontWeight = FontWeight.w400, textAlign = TextAlign.center, isBold = true, overflow = TextOverflow.clip}) {
    return FutureBuilder<String>(
      future: translateToAppLanguage(inputText),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CustomTextWidget(text: '--', textColor: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
            textAlign: textAlign,
            isBold: isBold,
            overflow: overflow );
          // Text('----------');
        }

        if (snapshot.hasError) {
          log('Error: ${snapshot.error}');
          return CustomTextWidget(text: '--', textColor: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
            textAlign: textAlign,
            isBold: isBold,
            overflow: overflow );
        }

        if (snapshot.hasData) {
          return CustomTextWidget(
            text: '${snapshot.data}',
            textColor: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
            textAlign: textAlign,
            isBold: isBold,
            overflow: overflow 
            );
          // Text('${snapshot.data}');
        }
        return CustomTextWidget(text: '--', textColor: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
            textAlign: textAlign,
            isBold: isBold,
            overflow: overflow );
      },
    );
  }
}
