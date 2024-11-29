import 'dart:developer';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/custom-input-field.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailScreen extends StatefulWidget {
  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void _sendOtp() async {
    final email = _emailController.text;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

    try {
      final fetchData = FetchData(
        url: UrlProvider.forgotPasswordUrl,
        headers: {'Content-Type': 'application/json'},
        body: {'email': _emailController.text},
      );
      final response = await fetchData.post();
      log('Response for password reseting: $response');
      if (response['success'] == true) {
        Navigator.pushNamed(
          context,
          "/enterOtp",
          arguments: {
            'email': _emailController.text,
            'destinationScreen': '/setNewPassword'
          },
        );
      } else {
        _showSnackbar(context, response['msg']);
      }
    } catch (e) {
      log("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }



    } else {
      return;
    }

  }

  void _showSnackbar(BuildContext context, String message) {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  padding: const EdgeInsets.only(top: 100.0, bottom: 100),
                  child: Column(
                    children: [
                      CustomTextWidget(
                        text: AppLocalizations.of(context)!.enterEmail,
                        textColor: AppColors.primary,
                        fontSize: 24.0,
                        isBold: true,
                      ),
                      const SizedBox(height: 20.0),
                      CustomTextField(
                        hintText: AppLocalizations.of(context)!.enterEmail,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
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
                      const SizedBox(height: 24.0),
                    ],
                  )),
              Container(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: isLoading
                    ? CircularProgressIndicator(color: AppColors.primary)
                    : CustomButton(
                        backgroundColor: AppColors.primary,
                        textColor: Colors.white,
                        text: AppLocalizations.of(context)!.sendotp,
                        onPressed: _sendOtp,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
