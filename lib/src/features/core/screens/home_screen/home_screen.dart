import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/constants/sizes.dart';
import 'package:pyramid_game/src/features/core/controllers/home_controller.dart';
import 'package:pyramid_game/src/features/core/screens/home_screen/home_screen_widgets/navbar.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        drawerEnableOpenDragGesture: false,
        drawer: const NavBar(),
        appBar: AppBar(
          shape: const Border(bottom: BorderSide(color: whiteColor, width: 1)),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: whiteColor),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          backgroundColor: primaryColor,
        ),
        body: ListView(
          padding: const EdgeInsets.all(30),
          children: [
            Image(
              image: const AssetImage(pyramidLogo),
              height: size.height * 0.3,
            ),
            Text(
              "START".tr,
              style: const TextStyle(
                fontSize: 50,
                color: whiteColor,
                fontFamily: 'EBGaramond',
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: whiteColor, width: 1),
                borderRadius: BorderRadius.circular(20),
                color: whiteColor,
              ),
              child: Text(
                'YOUR GAME'.tr,
                style: const TextStyle(
                  fontSize: 50,
                  color: primaryColor,
                  fontFamily: 'EBGaramond',
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            const Icon(Icons.keyboard_double_arrow_down,
                size: 80, color: whiteColor),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  homeController.showJoinRoomDialog(
                    context,
                    "Enter room code".tr,
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: whiteColor,
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: buttonHeight,
                  ),
                ),
                child: Text(
                  'JOIN A ROOM'.tr,
                  style: const TextStyle(
                    fontFamily: 'EBGaramond',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  homeController.showCreateRoomDialog(
                    context,
                    "Set up your room.".tr,
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: whiteColor,
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: buttonHeight,
                  ),
                ),
                child: Text(
                  'CREATE A ROOM'.tr,
                  style: const TextStyle(
                    fontFamily: 'EBGaramond',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
