import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/features/authentication/screens/profile/profile_screen.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_in/sign_in_screen.dart';
import 'package:pyramid_game/src/features/core/history_screen/history_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final auth = FirebaseAuth.instance;

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

  void signOut() async {
    await auth.signOut().then((value) => {
          showSnackBar("Sign out successfully", true),
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => SignInScreen(),
            ),
          )
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
                      accountName: Text(
                        userData["userName"],
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      accountEmail: Text(
                        auth.currentUser!.email.toString(),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
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
                      title: const Text("Profile"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_backup_restore),
                      title: const Text("History"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => HistoryScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Setting"),
                      onTap: () {},
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
                      title: const Text("Sign out"),
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
