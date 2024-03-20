import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/constants/sizes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final auth = FirebaseAuth.instance;
  final _formfield = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;

  void submit(String email) async {
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(emailController.text.toString())
        .get();
    if (documentSnapshot.exists) {
      auth.sendPasswordResetEmail(email: email).then(
            (value) async => {
              await Future.delayed(const Duration(seconds: 2)),
              setState(() {
                isLoading = false;
              }),
              if (context.mounted)
                {
                  showInforDialog(
                      context,
                      "Reset password link has been sent to your registered email address.",
                      true)
                }
            },
          );
      emailController.clear();
    } else {
      if (context.mounted) {
        showInforDialog(context, "Email does not exist", false);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void showInforDialog(BuildContext context, String content, bool isBool) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isBool ? "Successfully" : "Fail",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isBool ? Colors.green : Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Ok',
                style: TextStyle(color: whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
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
        ),
        body: ListView(
          padding: const EdgeInsets.all(30),
          children: [
            Image(
              image: const AssetImage(forgotPasswordImage),
              height: size.height * 0.3,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'FORGOT ',
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
                    'PASSWORD?',
                    style: TextStyle(
                      fontSize: 40,
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
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formfield.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            submit(
                              emailController.text.toString(),
                            );
                            // emailController.clear();
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
                                backgroundColor: whiteColor,
                                color: primaryColor,
                              )
                            : const Text(
                                'RESET PASSWORD',
                                style: TextStyle(
                                  fontFamily: 'EBGaramond',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
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
