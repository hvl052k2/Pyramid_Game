import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/features/authentication/screens/profile/profile_screen.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_in/sign_in_screen.dart';
import 'package:pyramid_game/src/features/core/history_screen/history_screen.dart';
import 'package:pyramid_game/src/features/core/settings_screen/settings_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final auth = FirebaseAuth.instance;

  void signOut() async {
    await auth.signOut().then((value) => {
          Get.snackbar(
            "Information".tr,
            "Sign out successfully".tr,
            colorText: whiteColor,
            backgroundColor: Colors.green,
          ),
          Get.offAll(() => SignInScreen())
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: whiteColor,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(auth.currentUser!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor,
                        ),
                        child: Text(
                          userData["userName"],
                          style: const TextStyle(
                            color: whiteColor,
                            fontFamily: 'EBGaramond',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      accountEmail: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor,
                        ),
                        child: Text(
                          auth.currentUser!.email.toString(),
                          style: const TextStyle(
                            color: whiteColor,
                            fontFamily: 'EBGaramond',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      currentAccountPicture: userData["avatarImage"] != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userData["avatarImage"]),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: AssetImage(avatarImage),
                            ),
                      decoration: BoxDecoration(
                        image: userData["wallImage"] != null
                            ? DecorationImage(
                                image: NetworkImage(userData["wallImage"]),
                                fit: BoxFit.cover)
                            : const DecorationImage(
                                image: AssetImage(wallImage),
                                fit: BoxFit.cover),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        "Profile".tr,
                        style: const TextStyle(
                          fontFamily: 'EBGaramond',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Get.to(() => const ProfileScreen());
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_backup_restore),
                      title: Text(
                        "History".tr,
                        style: const TextStyle(
                          fontFamily: 'EBGaramond',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Get.to(() => HistoryScreen());
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: Text(
                        "Settings".tr,
                        style: const TextStyle(
                          fontFamily: 'EBGaramond',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Get.to(() => const SettingsScreen());
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Divider(
                      height: 10,
                      color: Colors.grey,
                      indent: 10,
                      endIndent: 10,
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded),
                      title: Text(
                        "Sign out".tr,
                        style: const TextStyle(
                          fontFamily: 'EBGaramond',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      onTap: signOut,
                    ),
                  ],
                )
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
    );
  }
}
