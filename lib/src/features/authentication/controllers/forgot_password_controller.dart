import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  RxBool isLoading = false.obs;

  final formfield = GlobalKey<FormState>();
  final email = TextEditingController();

  void toggleIsLoading(bool value) {
    isLoading.value = value;
  }

  void submit(String emailText) async {
    final auth = FirebaseAuth.instance;
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(emailText)
        .get();
    if (documentSnapshot.exists) {
      auth.sendPasswordResetEmail(email: emailText).then(
            (value) => {
              Get.defaultDialog(
                title: "Information".tr,
                titleStyle: const TextStyle(color: Colors.green),
                content: Text(
                  "Reset password link has been sent to your registered email address."
                      .tr,
                  textAlign: TextAlign.center,
                ),
                onConfirm: () => Get.back(),
                barrierDismissible: false,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              toggleIsLoading(false),
              email.clear(),
            },
          );
    } else {
      Get.defaultDialog(
        title: "Information".tr,
        titleStyle: const TextStyle(color: Colors.red),
        content: Text(
          "Email does not exist".tr,
          textAlign: TextAlign.center,
        ),
        onConfirm: () => Get.back(),
        barrierDismissible: false,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      );
      toggleIsLoading(false);
    }
  }
}
