// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:pyramid_game/src/constants/colors.dart';
// import 'package:pyramid_game/src/features/authentication/screens/sign_in/sign_in_screen.dart';
// import 'package:pyramid_game/src/features/core/home_screen/home_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   final auth = FirebaseAuth.instance;
//   bool isSignedIn = false;

//   void checkIfSignedIn() async {
//     auth.authStateChanges().listen((User? user) {
//       if (user != null && mounted) {
//         setState(() {
//           isSignedIn = true;
//         });
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     checkIfSignedIn();
//     startTimer();
//   }

//   Timer startTimer() {
//     var duration = const Duration(seconds: 3);
//     return Timer(duration, route);
//   }

//   void route() {
//     if (isSignedIn && auth.currentUser!.emailVerified) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (BuildContext context) => const HomePage(),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (BuildContext context) => SignInScreen(),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: whiteColor,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [whiteColor, Colors.grey, primaryColor],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: Lottie.asset(
//             "assets/splash/splash.json",
//             width: 150,
//             height: 150,
//             fit: BoxFit.fill,
//           ),
//         ),
//       ),
//     );
//   }
// }
