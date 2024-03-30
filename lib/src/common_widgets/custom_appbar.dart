import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/constants/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.action,
    this.title,
    this.isCenter = false,
    this.backgroundColor = primaryColor,
    this.shape,
    this.iconColor = whiteColor,
  });

  final List<Widget>? action;
  final Widget? title;
  final bool isCenter;
  final Color backgroundColor;
  final ShapeBorder? shape;
  final Color iconColor;

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      centerTitle: isCenter,
      backgroundColor: backgroundColor,
      shape: shape,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          size: 35,
          color: iconColor,
        ),
        onPressed: () {
          Get.back();
        },
      ),
      actions: action,
    );
  }
}
