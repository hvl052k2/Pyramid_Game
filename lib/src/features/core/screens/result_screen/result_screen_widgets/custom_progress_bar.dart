import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';

class CustomProgressbar extends StatelessWidget {
  const CustomProgressbar(
      {super.key,
      required this.width,
      required this.height,
      required this.numVote});

  final double width;
  final double height;
  final int numVote;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "$numVote",
            style: const TextStyle(
              color: whiteColor,
              fontFamily: 'EBGaramond',
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          )
        ],
      ),
    );
  }
}
