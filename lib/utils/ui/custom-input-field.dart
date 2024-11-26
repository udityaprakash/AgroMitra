import 'package:agromitra/constant/color.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final int? maxLength;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding; // New: Custom content padding

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.onChanged,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.contentPadding, // New: Accept content padding
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      focusNode: widget.focusNode,
      cursorColor: AppColors.primary,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontFamily: 'Parkinsans',
        fontSize: 16.0,
        decoration: TextDecoration.none,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontFamily: 'Parkinsans',
          fontSize: 14.0,
        ),
        counterText: "",
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textHint,
                ),
                onPressed: _toggleObscureText,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: AppColors.textHint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: AppColors.textHint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 20.0, // Default padding if not provided
            ),
        filled: true,
        fillColor: AppColors.background,
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
