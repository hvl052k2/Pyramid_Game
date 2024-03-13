import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
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
        body: Container(
            // color: primaryColor,
            ),
      ),
    );
  }
}
