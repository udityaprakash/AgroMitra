  import 'package:flutter/material.dart';
import 'package:agromitra/constant/color.dart';
import 'package:agromitra/utils/ui/custom-text.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: CustomTextWidget(
          text: "Home Screen",
          textColor: Colors.white,
          fontSize: 20.0,
          isBold: true,
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Center(
        child: CustomTextWidget(
          text: "Welcome to the Home Screen!",
          textColor: AppColors.textPrimary,
          fontSize: 18.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomTextWidget(
                text: "Floating Action Button Pressed!",
                textColor: Colors.white,
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
