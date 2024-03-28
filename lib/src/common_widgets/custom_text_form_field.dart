import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.obscured = false,
    required this.textController,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    this.suffixIcon,
  });

  final TextEditingController textController;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool obscured;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      obscureText: obscured,
      style: const TextStyle(color: whiteColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontFamily: 'EBGaramond',
          fontSize: 18,
        ),
        prefixIcon: Icon(prefixIcon),
        prefixIconColor: whiteColor,
        suffixIcon: suffixIcon,
        suffixIconColor: whiteColor,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
      ),
      validator: validator,
    );
  }
}
