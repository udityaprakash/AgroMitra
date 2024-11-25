import 'package:flutter/material.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-input-field.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization class

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/app_logo/appLogoImage.png', height: 50),
                      SizedBox(width: 8),
                      CustomTextWidget(
                        text: AppLocalizations.of(context)!.agromitra, // Localized text
                        textColor: AppColors.primary,
                        fontSize: 32.0,
                        isBold: true,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 80.0),

                  // Email TextField
                  CustomTextField(
                    hintText: AppLocalizations.of(context)!.enterEmail, // Localized hint text
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emailRequired; // Localized validation
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return AppLocalizations.of(context)!.invalidEmail; // Localized validation
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Password TextField
                  CustomTextField(
                    hintText: AppLocalizations.of(context)!.enterPassword, // Localized hint text
                    controller: passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.passwordRequired; // Localized validation
                      }
                      if (value.length < 6) {
                        return AppLocalizations.of(context)!.passwordTooShort; // Localized validation
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password action
                      },
                      child: CustomTextWidget(
                        text: AppLocalizations.of(context)!.forgotPassword, // Localized text
                        textColor: AppColors.primary,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Sign In Button
                  CustomButton(
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                    text: AppLocalizations.of(context)!.signIn, // Localized text
                    onPressed: () {
                      // Handle sign in action
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Or Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.textHint,
                          thickness: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      CustomTextWidget(
                        text: AppLocalizations.of(context)!.or, // Localized text
                        textColor: AppColors.textHint,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Divider(
                          color: AppColors.textHint,
                          thickness: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Continue with Google Button
                  CustomButton(
                    backgroundColor: AppColors.white,
                    textColor: AppColors.primary,
                    text: AppLocalizations.of(context)!.continueWithGoogle, // Localized text
                    onPressed: () {
                      // Handle Google Sign-In
                    },
                    prefixIcon: Image.asset('assets/images/app_images/googleLogo.png', height: 26),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextWidget(
                        text: AppLocalizations.of(context)!.dontHaveAccount, // Localized text
                        textColor: AppColors.textHint,
                        fontSize: 14.0,
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to Register Screen
                        },
                        child: CustomTextWidget(
                          text: AppLocalizations.of(context)!.register, // Localized text
                          textColor: AppColors.primary,
                          fontSize: 14.0,
                          isBold: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
