import 'package:flutter/material.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-input-field.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add GlobalKey

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form( // Wrap in Form
                key: _formKey,
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
                          text: AppLocalizations.of(context)!.agromitra,
                          textColor: AppColors.primary,
                          fontSize: 32.0,
                          isBold: true,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40.0),

                    // Full Name TextField
                    CustomTextField(
                      hintText: AppLocalizations.of(context)!.enterFullName,
                      controller: fullNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.fullNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Email TextField
                    CustomTextField(
                      hintText: AppLocalizations.of(context)!.enterEmail,
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.emailRequired;
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return AppLocalizations.of(context)!.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Password TextField
                    CustomTextField(
                      hintText: AppLocalizations.of(context)!.enterPassword,
                      controller: passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.passwordRequired;
                        }
                        if (value.length < 6) {
                          return AppLocalizations.of(context)!.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Re-enter Password TextField
                    CustomTextField(
                      hintText: AppLocalizations.of(context)!.reEnterPassword,
                      controller: rePasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.reEnterPasswordRequired;
                        }
                        if (value != passwordController.text) {
                          return AppLocalizations.of(context)!.passwordMismatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),

                    // Register Button
                    CustomButton(
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                      text: AppLocalizations.of(context)!.register,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Handle registration logic here
                          print("Form is valid");
                        } else {
                          print("Form is invalid");
                        }
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
                          text: AppLocalizations.of(context)!.or,
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
                      text: AppLocalizations.of(context)!.continueWithGoogle,
                      onPressed: () {
                        // Handle Google Sign-In
                      },
                      prefixIcon: Image.asset('assets/images/app_images/googleLogo.png', height: 26),
                    ),
                    const SizedBox(height: 24.0),

                    // Already have an account? Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextWidget(
                          text: AppLocalizations.of(context)!.alreadyHaveAccount,
                          textColor: AppColors.textHint,
                          fontSize: 14.0,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: CustomTextWidget(
                            text: AppLocalizations.of(context)!.login,
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
      ),
    );
  }
}
