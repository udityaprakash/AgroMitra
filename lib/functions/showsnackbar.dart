import 'package:agromitra/constant/color.dart';
import 'package:agromitra/functions/autotranslator.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';

void showSnackbarAutoTranslated(BuildContext context, String message) {
    // Clear any existing Snackbar before showing a new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoTranslator()
                    .buildTranslatedText(context, message, textColor: AppColors.textSecondary, isBold: false),
        // content: CustomTextWidget(
        //   text: message,
        //   textColor: AppColors.textSecondary,
        // ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void customShowSnackbar(BuildContext context, String message) {
    // Clear any existing Snackbar before showing a new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // content: AutoTranslator()
        //             .buildTranslatedText(context, message, textColor: AppColors.textSecondary, isBold: false),
        content: CustomTextWidget(
          text: message,
          textColor: AppColors.textSecondary,
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }