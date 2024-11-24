import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final Color textColor;
  final FontStyle fontStyle;
  final FontWeight fontWeight;
  final double fontSize;
  final bool isBold;
  final TextOverflow overflow;
  final int? maxLines;
  final TextAlign? textAlign;

  const CustomTextWidget({
    Key? key,
    required this.text,
    required this.textColor,
    this.fontStyle = FontStyle.normal,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 14.0,
    this.isBold = false,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign ?? TextAlign.start,
      style: TextStyle(
        color: textColor,
        fontStyle: fontStyle,
        fontWeight: isBold ? FontWeight.bold : fontWeight,
        fontSize: fontSize,
      ),
    );
  }
}

// Usage Example in Flutter Widgets:
// CustomTextWidget(
//   text: 'This is a custom text widget',
//   textColor: AppColors.textPrimary,
//   fontSize: 16.0,
//   isBold: true,
//   overflow: TextOverflow.clip,
//   maxLines: 2,
//   textAlign: TextAlign.center,
// );
