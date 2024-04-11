import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/common_widgets/custom_appbar.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String selectedLanguage;

  void toggleLanguage(String value) {
    box.write('language', value);
  }

  @override
  void initState() {
    // if (Get.deviceLocale!.languageCode == "vi") {
    //   selectedLanguage = "Vietnamese";
    // } else {
    //   selectedLanguage = "English";
    // }
    if (box.read('language') != null) {
      selectedLanguage = box.read('language');
    } else {
      selectedLanguage = "English";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: CustomAppBar(
          shape:
              const Border(bottom: BorderSide(color: primaryColor, width: 1)),
          iconColor: primaryColor,
          backgroundColor: whiteColor,
          isCenter: true,
          title: Text(
            "SETTINGS".tr,
            style: const TextStyle(
              color: primaryColor,
              fontFamily: 'EBGaramond',
              fontWeight: FontWeight.w700,
              fontSize: 30,
              letterSpacing: 5,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.language,
                  size: 35,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Language".tr,
                      style: const TextStyle(
                        color: primaryColor,
                        fontFamily: 'EBGaramond',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      selectedLanguage.tr,
                      style: const TextStyle(
                        color: primaryColor,
                        fontFamily: 'EBGaramond',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: "English",
                      child: Text("English".tr),
                    ),
                    PopupMenuItem(
                      value: "Vietnamese",
                      child: Text("Vietnamese".tr),
                    ),
                  ],
                  onSelected: (newLanguage) {
                    selectedLanguage = newLanguage;
                    if (newLanguage == "English") {
                      const locale = Locale('en', 'US');
                      Get.updateLocale(locale);
                      toggleLanguage("English");
                    } else {
                      const locale = Locale('vi', 'Vie');
                      Get.updateLocale(locale);
                      toggleLanguage("Vietnamese");
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
