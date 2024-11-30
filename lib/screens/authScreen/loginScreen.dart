import 'dart:convert';
import 'dart:developer';
import 'package:agromitra/utils/data/InternetMsgCodeDecoder.dart';
import 'package:agromitra/utils/data/deviceStorage.dart';
import 'package:http/http.dart' as http;
import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:flutter/material.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-input-field.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void _showSnackbar(BuildContext context, String message) {
    // Clear any existing Snackbar before showing a new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomTextWidget(
          text: message,
          textColor: AppColors.textSecondary,
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/app_logo/appLogoImage.png',
                          height: 50,
                        ),
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
                    const SizedBox(height: 80.0),

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
                    const SizedBox(height: 8.0),

                    // Forgot Password Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgotPassword');
                        },
                        child: CustomTextWidget(
                          text: AppLocalizations.of(context)!.forgotPassword,
                          textColor: AppColors.primary,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Sign In Button
                    Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(vertical: 16.0),
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : CustomButton(
                              backgroundColor: AppColors.primary,
                              textColor: AppColors.background,
                              text: AppLocalizations.of(context)!.signIn,
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  setState(() {
                                    isLoading = true; // Show loader
                                  });

                                  try {
                                    final lang =
                                        await StorageManager.readData('Lang');
                                    log(lang);
                                    final fetchData = FetchData(
                                      url: UrlProvider.loginUrl,
                                      headers: {
                                        'Content-Type': 'application/json'
                                      },
                                      body: {
                                        "email": emailController.text,
                                        "password": passwordController.text,
                                        "language": lang.toString(),
                                      },
                                    );
                                    final response = await fetchData.post();
                                    log('POST Response: ${response}');

                                    // Show the response message
                                    _showSnackbar(
                                        context,
                                        getMessageByCode(
                                            context, response['msgCode']));
                                    if (response['success'] == true) {
                                      if (response['verified'] == false ) {
                                        final fetchData = FetchData(
                                      url: UrlProvider.sendOTP + emailController.text,
                                      headers: {
                                        'Content-Type': 'application/json'
                                      }
                                    );
                                    final response = await fetchData.get();
                                    log('OTP send Response: $response');

                                      Navigator.pushNamed(
                                        context,
                                        "/enterOtp",
                                        arguments: {'email': emailController.text, 'destinationScreen': '/login'},
                                      ); 
                                        return;
                                      }
                                      await StorageManager.saveData(
                                        'token',
                                        response['token'],
                                      );

                                      Navigator.pushReplacementNamed(
                                          context, '/homescreen');
                                    }
                                  } catch (e) {
                                    log("Error: $e");
                                    _showSnackbar(
                                      context,
                                      AppLocalizations.of(context)!
                                          .anerroroccurredduringsignin,
                                    );
                                  } finally {
                                    setState(() {
                                      isLoading = false; // Hide loader
                                    });
                                  }
                                } else {
                                  log("Form is invalid");
                                }
                              },
                            ),
                    ),

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
                      prefixIcon: Image.asset(
                        'assets/images/app_images/googleLogo.png',
                        height: 26,
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Don't have an account? Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextWidget(
                          text: AppLocalizations.of(context)!.dontHaveAccount,
                          textColor: AppColors.textHint,
                          fontSize: 14.0,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: CustomTextWidget(
                            text: AppLocalizations.of(context)!.register,
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
