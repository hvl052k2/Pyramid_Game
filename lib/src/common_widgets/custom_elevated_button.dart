import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/sizes.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.textContent,
    this.disableBackCorlor,
    this.disableForeCorlor,
  });

  final Function()? onPressed;
  final bool isLoading;
  final String textContent;
  final Color? disableBackCorlor;
  final Color? disableForeCorlor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: disableBackCorlor,
        disabledForegroundColor: disableForeCorlor,
        foregroundColor: whiteColor,
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(
          vertical: buttonHeight,
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(
              backgroundColor: primaryColor,
              color: whiteColor,
            )
          : Text(
              textContent,
              style: const TextStyle(
                fontFamily: 'EBGaramond',
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
    );
  }
}
