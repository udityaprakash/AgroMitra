import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final double? width;
  final String text;
  final VoidCallback onPressed;
  final Widget? prefixIcon; // Leading icon
  final Widget? postfixIcon; // Trailing icon

  const CustomButton({
    Key? key,
    required this.backgroundColor,
    required this.textColor,
    this.width,
    required this.text,
    required this.onPressed,
    this.prefixIcon, // Added this for prefix
    this.postfixIcon, // Added this for postfix
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              const SizedBox(width: 8.0), // Spacing between icon and text
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16.0,
                fontFamily: 'Parkinsans',
              ),
            ),
            if (postfixIcon != null) ...[
              const SizedBox(width: 8.0), // Spacing between text and icon
              postfixIcon!,
            ],
          ],
        ),
      ),
    );
  }
}

// Usage Example in Flutter Widgets:
// CustomButton(
//   backgroundColor: AppColors.primary,
//   textColor: AppColors.textSecondary,
//   text: 'Sign In',
//   prefixIcon: Icon(Icons.login, color: Colors.white),
//   postfixIcon: Icon(Icons.arrow_forward, color: Colors.white),
//   onPressed: () {
//     print('Button Clicked');
//   },
// );
