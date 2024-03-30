import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/features/core/home_screen/home_screen.dart';

class SignInController extends GetxController {
  RxBool obscured = false.obs;
  RxBool isLoading = false.obs;

  final formfield = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  void toggleObscured() {
    obscured.value = !obscured.value;
  }

  void toggleIsLoading(bool value) {
    isLoading.value = value;
  }

  void signIn(String email, String password) async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (credential.user!.emailVerified) {
        toggleIsLoading(false);
        Get.snackbar(
          "Information".tr,
          "Sign in successfully".tr,
          colorText: whiteColor,
          backgroundColor: Colors.green,
        );
        Get.offAll(HomePage());
      } else {
        toggleIsLoading(false);
        Get.defaultDialog(
          title: "Information".tr,
          titleStyle: const TextStyle(color: Colors.red),
          content: Text(
            "Your email is not authenticated.\nPlease check your verification email before signing in."
                .tr,
            textAlign: TextAlign.center,
          ),
          onConfirm: () => Get.back(),
          barrierDismissible: false,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        );
      }
    } on FirebaseAuthException {
      toggleIsLoading(false);
      Get.snackbar(
        "Information".tr,
        "Account or password is incorrect".tr,
        colorText: whiteColor,
        backgroundColor: Colors.red,
      );
    }
  }
}
