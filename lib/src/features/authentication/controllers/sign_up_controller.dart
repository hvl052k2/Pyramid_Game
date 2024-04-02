import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/constants/colors.dart';

class SignUpController extends GetxController {
  RxBool obscured = false.obs;
  RxBool isLoading = false.obs;
  RxBool isChecked = false.obs;

  final formfield = GlobalKey<FormState>();
  final fullName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  void toggleObscured() {
    obscured.value = !obscured.value;
  }

  void toggleIsLoading(bool value) {
    isLoading.value = value;
  }

  void toggleIsChecked(bool value) {
    isChecked.value = value;
  }

  void signUp(String email, String password) async {
    try {
      UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseFirestore.instance
          .collection("Users")
          .doc(credential.user!.email)
          .set({
        "userName": fullName.text,
        "phoneNumber": "",
        "bio": "Empty bio...",
      });
      toggleIsLoading(false);
      FirebaseAuth.instance.currentUser!.sendEmailVerification().then((value) {
        Get.defaultDialog(
          title: "Information".tr,
          titleStyle: const TextStyle(color: Colors.green),
          content: Text(
            "Sign up successfully!\nPlease, check your email to verify account"
                .tr,
            textAlign: TextAlign.center,
          ),
          onConfirm: () {
            Get.back();
            Get.back();
          },
          barrierDismissible: false,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        );
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        toggleIsLoading(false);
        Get.snackbar(
          "Information".tr,
          "The account already exists for this email.".tr,
          colorText: whiteColor,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      toggleIsLoading(false);
      Get.snackbar(
        "Information".tr,
        e.toString(),
        colorText: whiteColor,
        backgroundColor: Colors.red,
      );
    }
  }
}
