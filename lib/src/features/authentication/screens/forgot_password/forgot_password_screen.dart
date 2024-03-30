import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/common_widgets/custom_appbar.dart';
import 'package:pyramid_game/src/common_widgets/custom_elevated_button.dart';
import 'package:pyramid_game/src/common_widgets/custom_text_form_field.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/features/authentication/controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final forgotPasswordController = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: const CustomAppBar(),
        body: ListView(
          padding: const EdgeInsets.all(30),
          children: [
            Image(
              image: const AssetImage(forgotPasswordImage),
              height: size.height * 0.25,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'FORGOT'.tr,
                  style: const TextStyle(
                    fontSize: 40,
                    color: whiteColor,
                    fontFamily: 'EBGaramond',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: whiteColor, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: whiteColor,
                  ),
                  child: Text(
                    'PASSWORD?'.tr,
                    style: const TextStyle(
                      fontSize: 50,
                      color: primaryColor,
                      fontFamily: 'EBGaramond',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Form(
                key: forgotPasswordController.formfield,
                child: Column(
                  children: [
                    CustomTextFormField(
                      textController: forgotPasswordController.email,
                      hintText: "Email".tr,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) {
                        bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                            .hasMatch(value!);
                        if (value.isEmpty) {
                          return "Enter email.".tr;
                        }
                        if (!emailValid) {
                          return "Enter valid email.".tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => CustomElevatedButton(
                          onPressed: () {
                            if (forgotPasswordController.formfield.currentState!
                                .validate()) {
                              forgotPasswordController.toggleIsLoading(true);
                              forgotPasswordController.submit(
                                forgotPasswordController.email.text,
                              );
                            }
                          },
                          isLoading: forgotPasswordController.isLoading.value,
                          textContent: "RESET PASSWORD".tr,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
