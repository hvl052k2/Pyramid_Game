import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';

class RichTextWidget extends StatelessWidget {
  const RichTextWidget({
    super.key,
    required this.order,
    required this.content,
  });

  final String order;
  final String content;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: order,
            style: const TextStyle(
              fontFamily: 'EBGaramond',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
          TextSpan(
            text: content,
            style: const TextStyle(
              fontFamily: 'EBGaramond',
              fontSize: 18,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
