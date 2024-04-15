import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/firebase_options.dart';
import 'package:pyramid_game/src/constants/storage.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_in/sign_in_screen.dart';
import 'package:pyramid_game/src/features/core/screens/home_screen/home_screen.dart';
import 'package:pyramid_game/src/utils/locale.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  // runApp(DevicePreview(builder: (context) => const MyApp()));
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
  // late String selectedLanguage;

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
    return GetMaterialApp(
      // useInheritedMediaQuery: true,
      // builder: DevicePreview.appBuilder,
      // locale: DevicePreview.locale(context),
      translations: LocaleString(),
      locale: box.read('language') == "English" || box.read('language') == null
          ? const Locale('en', 'US')
          : const Locale('vi', 'Vie'),
      // locale: Get.deviceLocale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: (isSignedIn && auth.currentUser!.emailVerified)
          ? HomePage()
          : SignInScreen(),
    );
  }
}
