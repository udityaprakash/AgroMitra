import 'dart:developer';

import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:agromitra/utils/ui/custom-input-field.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  ResetPasswordScreen({required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key for validation
  bool isLoading = false;

  // Password reset function
  void _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmPasswordController.text;

      setState(() {
        isLoading = true;
      });

      final fetchData = FetchData(
            url: UrlProvider.setNewPasswordUrl,
            headers: {'Content-Type': 'application/json'},
            body: {"email":widget.email, "password": newPassword},
          );

          final response = await fetchData.post();
          log('resetPasswordSendOtp Response: $response');
          if (response['success'] == true) {
            _showSnackbar(context, AppLocalizations.of(context)!.passwordUpdatedSuccessfully);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);

          }else{
            _showSnackbar(context, response['msg']);

          }




      setState(() {
        isLoading = false;
      });
    }
  }

  // Show snackbar with custom message
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
          key: _formKey,  // Attach the form key
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.only(top: 100.0),
                child: Column(
                  children: [
                    CustomTextWidget(
                      text: AppLocalizations.of(context)!.resetPassword,
                      textColor: AppColors.primary,
                      fontSize: 24.0,
                      isBold: true,
                    ),
                CustomTextField(
                  hintText: AppLocalizations.of(context)!.newPassword,
                  controller: _newPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppLocalizations.of(context)!.passwordTooShort;
                    }
                    return null;  // Password validation passed
                  },
                ),
                const SizedBox(height: 16.0),

                // Confirm Password Field with Validation
                CustomTextField(
                  hintText: AppLocalizations.of(context)!.confirmPassword,
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.reEnterPasswordRequired;
                    }
                    if (value != _newPasswordController.text) {
                      return AppLocalizations.of(context)!.passwordMismatch;
                    }
                    return null;  // Password match validation passed
                  },
                ),
                const SizedBox(height: 24.0),


                  ],
                ),
              ),

              // New Password Field with Validation

              // Loading indicator or Reset Password Button
              Container(
                padding: EdgeInsets.only(bottom: 70.0),
                child: isLoading
                    ? CircularProgressIndicator(color: AppColors.primary)
                    : CustomButton(
                        backgroundColor: AppColors.primary,
                        textColor: Colors.white,
                        text: AppLocalizations.of(context)!.resetPassword,
                        onPressed: _resetPassword,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}