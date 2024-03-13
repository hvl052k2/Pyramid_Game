import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/firebase_options.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_in/sign_in_screen.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_up/sign_up_screen.dart';
import 'package:pyramid_game/src/features/core/home_page.dart';
import 'package:pyramid_game/src/utils/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final auth = FirebaseAuth.instance;
  bool isSignedIn = false;

  checkIfSignedIn() async {
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isSignedIn = true;
        });
      }
    });
  }

  @override
  void initState() {
    checkIfSignedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // themeMode: ThemeMode.system,
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isSignedIn ? const HomePage() : const SignInScreen(),
    );
  }
}
