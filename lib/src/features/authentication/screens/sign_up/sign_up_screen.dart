import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/common_widgets/custom_appbar.dart';
import 'package:pyramid_game/src/common_widgets/custom_elevated_button.dart';
import 'package:pyramid_game/src/common_widgets/custom_text_form_field.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/features/authentication/controllers/sign_up_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({
    super.key,
  });

  final signUpController = Get.put(SignUpController());
  final Uri privacyUri = Uri(
      scheme: 'https',
      host: 'www.freeprivacypolicy.com',
      path: 'live/532ceaaf-1c57-40bd-b485-8757131ceadc');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(),
        backgroundColor: primaryColor,
        body: ListView(
          children: [
            Image(
              image: const AssetImage(signUpLogo),
              height: size.height * 0.23,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'PYRAMID ',
                  style: TextStyle(
                    fontSize: 35,
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
                  child: const Text(
                    'GAME',
                    style: TextStyle(
                      fontSize: 40,
                      color: primaryColor,
                      fontFamily: 'EBGaramond',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Form(
                    key: signUpController.formfield,
                    child: Column(
                      children: [
                        CustomTextFormField(
                          textController: signUpController.fullName,
                          hintText: 'Full name'.tr,
                          prefixIcon: Icons.person_2_outlined,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter your full name.".tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          textController: signUpController.email,
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
                        const SizedBox(height: 10),
                        Obx(
                          () => CustomTextFormField(
                            obscured: signUpController.obscured.value,
                            textController: signUpController.password,
                            hintText: "Password".tr,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                signUpController.obscured.value
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                              onPressed: signUpController.toggleObscured,
                            ),
                            validator: (value) {
                              bool passwordValid = RegExp(
                                      r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$")
                                  .hasMatch(value!);
                              if (value.isEmpty) {
                                return "Enter password.".tr;
                              } else if (signUpController.password.text.length <
                                  8) {
                                return "Password length should not be less than 8 characters."
                                    .tr;
                              }
                              if (!passwordValid) {
                                return [
                                  "Password should contain at least one upper case,"
                                      .tr,
                                  "one lower case, one digit, and one special character."
                                      .tr
                                ].join("\n");
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => CustomTextFormField(
                            obscured: signUpController.obscured.value,
                            textController: signUpController.confirmPassword,
                            hintText: "Confirm password".tr,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                signUpController.obscured.value
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                              onPressed: signUpController.toggleObscured,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please re-enter your password.".tr;
                              }
                              if (signUpController.password.text !=
                                  signUpController.confirmPassword.text) {
                                return "Password does not match.".tr;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(
                        () => Checkbox(
                          value: signUpController.isChecked.value,
                          activeColor: Colors.red,
                          onChanged: (newBool) {
                            signUpController.toggleIsChecked(newBool!);
                          },
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "By registering, you agree to".tr,
                            style: const TextStyle(
                              fontFamily: 'EBGaramond',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: whiteColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              launchUrl(
                                privacyUri,
                                mode: LaunchMode.inAppWebView,
                              );
                            },
                            child: Text(
                              "our terms and conditions.".tr,
                              style: const TextStyle(
                                fontFamily: 'EBGaramond',
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => CustomElevatedButton(
                        onPressed: signUpController.isChecked.value
                            ? () {
                                if (signUpController.formfield.currentState!
                                    .validate()) {
                                  signUpController.toggleIsLoading(true);
                                  signUpController.signUp(
                                    signUpController.email.text
                                        .toString()
                                        .trim(),
                                    signUpController.password.text
                                        .toString()
                                        .trim(),
                                  );
                                }
                              }
                            : null,
                        isLoading: signUpController.isLoading.value,
                        textContent: "SIGN UP".tr,
                        disableBackCorlor: Colors.grey,
                        disableForeCorlor: whiteColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?'.tr,
                        style: const TextStyle(
                          color: whiteColor,
                          fontFamily: 'EBGaramond',
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          'Sign in'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: whiteColor,
                            fontSize: 20,
                            fontFamily: 'EBGaramond',
                            decoration: TextDecoration.underline,
                            decorationColor: whiteColor,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
