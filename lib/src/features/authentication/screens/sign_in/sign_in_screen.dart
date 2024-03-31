import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/common_widgets/custom_elevated_button.dart';
import 'package:pyramid_game/src/common_widgets/custom_text_form_field.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/features/authentication/controllers/sign_in_controller.dart';
import 'package:pyramid_game/src/features/authentication/screens/forgot_password/forgot_password_screen.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_up/sign_up_screen.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({
    super.key,
  });

  final signInController = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        body: ListView(
          children: [
            Image(
              image: const AssetImage(pyramidLogo),
              height: size.height * 0.35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'PYRAMID ',
                  style: TextStyle(
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
                  child: const Text(
                    'GAME',
                    style: TextStyle(
                      fontSize: 50,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        color: Colors.yellow,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Leak content, you will face the highest penalties.'
                              .tr,
                          style: const TextStyle(
                            color: Colors.red,
                            fontFamily: 'EBGaramond',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: signInController.formfield,
                    child: Column(
                      children: [
                        CustomTextFormField(
                          textController: signInController.email,
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
                            obscured: signInController.obscured.value,
                            textController: signInController.password,
                            hintText: "Password".tr,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                signInController.obscured.value
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                              onPressed: signInController.toggleObscured,
                            ),
                            validator: (value) {
                              bool passwordValid = RegExp(
                                      r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$")
                                  .hasMatch(value!);
                              if (value.isEmpty) {
                                return "Enter password.".tr;
                              } else if (signInController.password.text.length <
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.to(() => ForgotPasswordScreen());
                        },
                        child: Text(
                          'Forgot password ?'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: whiteColor,
                            fontSize: 18,
                            fontFamily: 'EBGaramond',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => CustomElevatedButton(
                        onPressed: () {
                          if (signInController.formfield.currentState!
                              .validate()) {
                            signInController.toggleIsLoading(true);
                            signInController.signIn(
                              signInController.email.text.toString().trim(),
                              signInController.password.text.toString().trim(),
                            );
                          }
                        },
                        isLoading: signInController.isLoading.value,
                        textContent: "SIGN IN".tr,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?'.tr,
                        style: const TextStyle(
                          color: whiteColor,
                          fontFamily: 'EBGaramond',
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(() => SignUpScreen());
                        },
                        child: Text(
                          'Sign up'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: whiteColor,
                            fontSize: 20,
                            fontFamily: 'EBGaramond',
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
