import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/common_widgets/custom_appbar.dart';
import 'package:pyramid_game/src/common_widgets/custom_elevated_button.dart';
import 'package:pyramid_game/src/common_widgets/custom_text_form_field.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/constants/sizes.dart';
import 'package:pyramid_game/src/features/authentication/controllers/sign_up_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({
    super.key,
  });

  final signUpController = Get.put(SignUpController());

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
              height: size.height * 0.25,
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
                  Form(
                    key: signUpController.formfield,
                    child: Column(
                      children: [
                        CustomTextFormField(
                          textController: signUpController.fullName,
                          hintText: 'Full name',
                          prefixIcon: Icons.person_2_outlined,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter your full name.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          textController: signUpController.email,
                          hintText: "Email",
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                .hasMatch(value!);
                            if (value.isEmpty) {
                              return "Enter email.";
                            }
                            if (!emailValid) {
                              return "Enter valid email.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => CustomTextFormField(
                            obscured: signUpController.obscured.value,
                            textController: signUpController.password,
                            hintText: "Password",
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
                                return "Enter password.";
                              } else if (signUpController.password.text.length <
                                  8) {
                                return "Password length should not be lass than 8 characters.";
                              }
                              if (!passwordValid) {
                                return [
                                  "Password should contain at least one upper case,",
                                  "one lower case, one digit, and one special character."
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
                            hintText: "Confirm password",
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
                                return "Please Re-enter your password.";
                              }
                              if (signUpController.password.text !=
                                  signUpController.confirmPassword.text) {
                                return "Password does not match.";
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
                      const Text(
                        'I agree with all the rules.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'EBGaramond',
                        ),
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
                                    signUpController.email.text.toString(),
                                    signUpController.password.text.toString(),
                                  );
                                }
                              }
                            : null,
                        isLoading: signUpController.isLoading.value,
                        textContent: "SIGN UP",
                        disableBackCorlor: Colors.grey,
                        disableForeCorlor: whiteColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: whiteColor,
                          fontFamily: 'EBGaramond',
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
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
