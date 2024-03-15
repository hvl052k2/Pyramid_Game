import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/constants/sizes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_in/sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formfield = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscured = false;

  void toggleObscured() {
    setState(() {
      obscured = !obscured;
    });
  }

  void showSnackBar(String message, bool status) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            Icon(
              status ? Icons.done_rounded : Icons.info_rounded,
              color: whiteColor,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: whiteColor,
                fontFamily: 'EBGaramond',
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.clip,
            ),
          ]),
          backgroundColor: status ? Colors.green : Colors.red,
        ),
      );

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
        "userName": emailController.text.split('@')[0],
        "phoneNumber": "",
        "bio": "Empty bio...",
      });
      if (context.mounted) {
        showSnackBar("Sign up successfully", true);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        showSnackBar("The password provided is too weak.", false);
      } else if (e.code == "email-already-in-use") {
        showSnackBar("The account already exists for that email.", false);
      }
    } catch (e) {
      showSnackBar(e.toString(), false);
    }
  }

  bool? isChecked = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 35,
              color: whiteColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.receipt_long,
                size: 35,
                color: whiteColor,
              ),
              onPressed: () {},
            ),
          ],
          backgroundColor: primaryColor,
        ),
        backgroundColor: primaryColor,
        body: ListView(
          children: [
            Image(
              image: const AssetImage(signUpLogo),
              height: size.height * 0.3,
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
                    key: _formfield,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: whiteColor),
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'EBGaramond',
                              fontSize: 18,
                            ),
                            prefixIcon: Icon(Icons.email_outlined),
                            prefixIconColor: whiteColor,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: whiteColor),
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                          ),
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
                        TextFormField(
                          controller: passwordController,
                          style: const TextStyle(color: whiteColor),
                          obscureText: obscured,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'EBGaramond',
                              fontSize: 18,
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            prefixIconColor: whiteColor,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscured
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                              onPressed: toggleObscured,
                            ),
                            suffixIconColor: whiteColor,
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: whiteColor),
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                          ),
                          validator: (value) {
                            bool passwordValid = RegExp(
                                    r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$")
                                .hasMatch(value!);
                            if (value.isEmpty) {
                              return "Enter password.";
                            } else if (passwordController.text.length < 8) {
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
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: confirmPasswordController,
                          style: const TextStyle(color: whiteColor),
                          obscureText: obscured,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            hintText: 'Confirm p assword',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'EBGaramond',
                              fontSize: 18,
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            prefixIconColor: whiteColor,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscured
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                              onPressed: toggleObscured,
                            ),
                            suffixIconColor: whiteColor,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(40.0),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: whiteColor),
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please re-enter your password.";
                            }
                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              return "Password does not match.";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        activeColor: Colors.red,
                        onChanged: (newBool) {
                          setState(() {
                            isChecked = newBool;
                          });
                        },
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
                    child: ElevatedButton(
                      onPressed: isChecked!
                          ? () {
                              if (_formfield.currentState!.validate()) {
                                signUp(
                                  emailController.text.toString(),
                                  passwordController.text.toString(),
                                );
                                // Navigator.pop(context);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: whiteColor,
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: buttonHeight,
                        ),
                      ),
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontFamily: 'EBGaramond',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
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
