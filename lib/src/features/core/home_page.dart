import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/sizes.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_in/sign_in_screen.dart';
import 'package:pyramid_game/src/features/core/home_page_widgets/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawerEnableOpenDragGesture: false,
        drawer: const NavBar(),
        appBar: AppBar(
          backgroundColor: whiteColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: whiteColor,
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: buttonHeight,
                    ),
                  ),
                  child: const Text(
                    'JOIN A ROOM',
                    style: TextStyle(
                      fontFamily: 'EBGaramond',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: whiteColor,
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: buttonHeight,
                    ),
                  ),
                  child: const Text(
                    'CREATE A ROOM',
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
    );
  }
}
