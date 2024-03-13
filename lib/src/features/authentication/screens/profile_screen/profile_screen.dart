import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/constants/sizes.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_in/sign_in_screen.dart';
import 'package:pyramid_game/src/features/core/home_page_widgets/navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final double coverHeight = 250;
  final double profileHeight = 144;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 35,
              color: whiteColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Edit profile",
            style: TextStyle(
              color: whiteColor,
              fontFamily: "EBGaramond",
              fontWeight: FontWeight.w500,
              fontSize: 30,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(auth.currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              nameController.text = userData["userName"];
              phoneController.text = userData["phoneNumber"];
              bioController.text = userData["bio"];
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: profileHeight / 2),
                        child: Container(
                          color: Colors.grey,
                          width: double.infinity,
                          height: coverHeight,
                          child: const Image(
                            image: AssetImage(wallImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: coverHeight - profileHeight / 2,
                        child: CircleAvatar(
                          radius: profileHeight / 2,
                          child: const ClipOval(
                            child: Image(image: AssetImage(avatarImage)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, top: 10),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Name",
                              style: TextStyle(color: whiteColor),
                            ),
                            TextField(
                              controller: nameController,
                              style: const TextStyle(color: whiteColor),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                prefixIconColor: whiteColor,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Phone",
                              style: TextStyle(color: whiteColor),
                            ),
                            TextField(
                              controller: phoneController,
                              style: const TextStyle(color: whiteColor),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.phone_android),
                                prefixIconColor: whiteColor,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Bio",
                              style: TextStyle(color: whiteColor),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: bioController,
                                style: const TextStyle(
                                  color: whiteColor,
                                ),
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              foregroundColor: primaryColor,
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                vertical: buttonHeight,
                              ),
                            ),
                            child: const Text(
                              'UPDATE',
                              style: TextStyle(
                                color: whiteColor,
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
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error ${snapshot.error}"),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
