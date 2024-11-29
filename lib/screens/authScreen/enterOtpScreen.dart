import 'dart:async';
import 'dart:developer';
import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/custom-input-field.dart';
import 'package:flutter/material.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EnterOtpScreen extends StatefulWidget {
  final String email;
  final String destinationScreen;

  EnterOtpScreen({required this.email, required this.destinationScreen});

  @override
  _EnterOtpScreenState createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool isLoading = false;
  int _secondsRemaining = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpControllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 30;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showSnackbar(BuildContext context, String message) {
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

  String _getOtp() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _verifyOtp() async {
    final otp = _getOtp();
    if (otp.length < 6) {
      _showSnackbar(context, AppLocalizations.of(context)!.invalidOtp);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      log(widget.destinationScreen);


      if (widget.destinationScreen == '/setNewPassword') {
          final fetchData = FetchData(
            url: UrlProvider.resetPasswordSendOtp,
            headers: {'Content-Type': 'application/json'},
            body: {"email":widget.email, "otp": otp.toString()},
          );

          final response = await fetchData.post();
          log('resetPasswordSendOtp Response: $response');
          if (response['success'] == true) {
            Navigator.pushNamed(context, '/setNewPassword');

          }else{
            _showSnackbar(context, response['msg']);

          }
      }else{

      log('OTP: $otp');
      final fetchData = FetchData(
        url: UrlProvider.sendOTP + widget.email,
        headers: {'Content-Type': 'application/json'},
        body: {"otp": otp.toString()},
      );
      final response = await fetchData.post();
      log('OTP Verification Response: $response');
      if (response['success'] == true) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/login');
      }else{
      _showSnackbar(context, response['msg']);

      }
      }
    } catch (e) {
      log("Error: $e");
      _showSnackbar(context,
          AppLocalizations.of(context)!.anerroroccurredduringotpverification);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Heading
            Column(
              children: [
                Center(
                  child: CustomTextWidget(
                    text: AppLocalizations.of(context)!.enterOtp,
                    textColor: AppColors.primary,
                    fontSize: 24.0,
                    isBold: true,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Email Info
                Center(
                  child: CustomTextWidget(
                    text:
                        "${AppLocalizations.of(context)!.otpSentTo} ${widget.email}",
                    textColor: AppColors.textHint,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 40.0),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: Focus(
                        onKey: (node, event) {
                          if (event is RawKeyDownEvent &&
                              event.logicalKey.keyLabel == 'Backspace') {
                            if (_otpControllers[index].text.isEmpty &&
                                index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          }
                          return KeyEventResult.ignored;
                        },
                        child: CustomTextField(
                          hintText: "",
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 20.0),
                          maxLength: 1,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      text: _secondsRemaining > 0
                          ? "${AppLocalizations.of(context)!.resendOtpIn} $_secondsRemaining s"
                          : AppLocalizations.of(context)!.resendOtpAvailable,
                      textColor: AppColors.textHint,
                      fontSize: 14.0,
                    ),
                    TextButton(
                      onPressed: _secondsRemaining > 0
                          ? null
                          : () async {
                              final fetchData = FetchData(
                                url: UrlProvider.sendOTP + widget.email,
                                headers: {'Content-Type': 'application/json'},
                              );
                              final response = await fetchData.get();
                              log('OTP Send Response: $response');
                              _startTimer();
                              _showSnackbar(
                                  context,
                                  AppLocalizations.of(context)!
                                      .otpResentSuccessfully);
                            },
                      child: CustomTextWidget(
                        text: AppLocalizations.of(context)!.resendOtp,
                        textColor: _secondsRemaining > 0
                            ? AppColors.textHint
                            : AppColors.primary,
                        fontSize: 14.0,
                        isBold: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            
            Container(
              height: 60,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : CustomButton(
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                      text: AppLocalizations.of(context)!.verifyOtp,
                      onPressed: _verifyOtp,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
