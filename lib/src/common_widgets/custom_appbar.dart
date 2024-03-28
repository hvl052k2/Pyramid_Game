import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/constants/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.action,
    this.title,
    this.isCenter = false,
  });

  final List<Widget>? action;
  final Widget? title;
  final bool isCenter;

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      centerTitle: isCenter,
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          size: 35,
          color: whiteColor,
        ),
        onPressed: () {
          Get.back();
        },
      ),
      actions: action,
    );
  }
}
