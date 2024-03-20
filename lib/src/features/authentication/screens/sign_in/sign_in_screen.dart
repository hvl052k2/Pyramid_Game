import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/constants/sizes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pyramid_game/src/features/authentication/screens/forgot_password/forgot_password_screen.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_up/sign_up_screen.dart';
import 'package:pyramid_game/src/features/core/home_screen/home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formfield = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

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
            ),
          ]),
          backgroundColor: status ? Colors.green : Colors.red,
        ),
      );

  void signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                showSnackBar("Sign in successfully", true),
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const HomePage(),
                  ),
                )
              });
      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar("Account or password is incorrect", false);
      setState(() {
        isLoading = false;
      });
      // if (e.code == "user-not-found") {
      //   print('user not found');
      //   showSnackBar("No user found for that email.", false);
      // } else if (e.code == "wrong-password") {
      //   showSnackBar("Wrong password provided for that user.", false);
      // }
    }
  }

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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.yellow,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Leak content, you will face the highest penalties.',
                          style: TextStyle(
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
                              borderRadius: BorderRadius.all(
                                Radius.circular(40.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: whiteColor),
                              borderRadius: BorderRadius.all(
                                Radius.circular(40),
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
                                Radius.circular(40),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot password ?',
                          style: TextStyle(
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
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formfield.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          signIn(
                            emailController.text.toString(),
                            passwordController.text.toString(),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: whiteColor,
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: buttonHeight,
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              backgroundColor: primaryColor,
                              color: whiteColor,
                            )
                          : const Text(
                              'SIGN IN',
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
                        'Don\'t have an account?',
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
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign up',
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
