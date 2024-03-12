import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({
    super.key,
  });

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  final _formfield = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscured = false;

  void toggleObscured() {
    setState(() {
      obscured = !obscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          style: const TextStyle(color: whiteColor),
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontFamily: 'EBGaramond',
              fontSize: 18,
            ),
            prefixIcon: Icon(Icons.email_outlined),
            prefixIconColor: whiteColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(40.0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: whiteColor),
              borderRadius: BorderRadius.all(
                Radius.circular(50),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: passwordController,
          style: const TextStyle(color: whiteColor),
          obscureText: obscured,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontFamily: 'EBGaramond',
              fontSize: 18,
            ),
            prefixIcon: const Icon(Icons.lock_outline),
            prefixIconColor: whiteColor,
            suffixIcon: IconButton(
              icon: Icon(
                obscured
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
              ),
              onPressed: toggleObscured,
            ),
            suffixIconColor: whiteColor,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(40.0)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: whiteColor),
              borderRadius: BorderRadius.all(
                Radius.circular(50),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: confirmPasswordController,
          style: const TextStyle(color: whiteColor),
          obscureText: obscured,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontFamily: 'EBGaramond',
              fontSize: 18,
            ),
            prefixIcon: const Icon(Icons.lock_outline),
            prefixIconColor: whiteColor,
            suffixIcon: IconButton(
              icon: Icon(
                obscured
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
              ),
              onPressed: toggleObscured,
            ),
            suffixIconColor: whiteColor,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(40.0)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: whiteColor),
              borderRadius: BorderRadius.all(
                Radius.circular(50),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
