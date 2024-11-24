import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final double? width;
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.backgroundColor,
    required this.textColor,
    this.width,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}

// Usage Example in Flutter Widgets:
// CustomButton(
//   backgroundColor: AppColors.primary,
//   textColor: AppColors.textSecondary,
//   text: 'Click Me',
//   onPressed: () {
//     print('Button Clicked');
//   },
// );
