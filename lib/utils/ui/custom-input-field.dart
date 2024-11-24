import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.validator,
    this.obscureText = false,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _toggleObscureText,
                  )
                : null,
            border: OutlineInputBorder(),
          ),
          validator: widget.validator,
        ),
        if (widget.validator != null)
          Builder(
            builder: (context) {
              final errorText = widget.validator!(widget.controller.text);
              return errorText != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorText,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.0,
                        ),
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
      ],
    );
  }
}

// Usage Example in Flutter Widgets:
// CustomTextField(
//   hintText: 'Enter your password',
//   controller: TextEditingController(),
//   obscureText: true,
//   validator: (value) {
//     if (value == null || value.isEmpty) {
//       return 'This field cannot be empty';
//     }
//     return null;
//   },
// );
