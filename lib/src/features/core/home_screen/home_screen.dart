import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/constants/sizes.dart';
import 'package:pyramid_game/src/features/authentication/screens/sign_in/sign_in_screen.dart';
import 'package:pyramid_game/src/features/core/home_screen/home_screen_widgets/navbar.dart';
import 'package:pyramid_game/src/features/core/room_screen/room_screen.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final roomCodeConTroller = TextEditingController();
  final titleController = TextEditingController();
  final passwordController = TextEditingController();
  final _formfield = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  String errorText = '';

  String randomRoomId() {
    final random = Random();
    final randomNumber = random.nextInt(1000000);
    final formattedNumber = randomNumber.toString().padLeft(6, '0');
    return formattedNumber;
  }

  Future<bool> checkRoomCode() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(roomCodeConTroller.text.toString())
        .get();

    if (docSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkPassword() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(roomCodeConTroller.text.toString())
        .get();

    if (docSnapshot.exists) {
      return passwordController.text == docSnapshot["password"];
    } else {
      return false;
    }
  }

  Future<bool> checkRoomStatus() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(roomCodeConTroller.text.toString())
        .get();

    if (docSnapshot.exists) {
      return docSnapshot["status"];
    } else {
      return false;
    }
  }

  Future<List> getAttenderList(String roomId) async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection("Rooms").doc(roomId).get();

    if (docSnapshot.exists) {
      return docSnapshot["attenders"];
    } else {
      return [];
    }
  }

  Future<String> joinRoom(String roomId) async {
    final userData = await FirebaseFirestore.instance
        .collection("Users")
        .doc(auth?.email)
        .get();
    String userName = userData["userName"];
    bool isRoomCodeValid = await checkRoomCode();
    bool isPasswordValid = await checkPassword();
    bool isRoomStatusValid = await checkRoomStatus();

    if (isRoomCodeValid && isPasswordValid && isRoomStatusValid) {
      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final docSnapshot = await transaction
              .get(FirebaseFirestore.instance.collection("Rooms").doc(roomId));

          if (!docSnapshot.exists) {
            throw Exception("Room does not exist");
          }

          List attenders = List.from(docSnapshot.data()!["attenders"]);
          attenders.add({
            "attenderGmail": auth?.email,
            "attenderName": userName,
          });

          transaction.update(docSnapshot.reference, {"attenders": attenders});
        });

        if (context.mounted) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => RoomScreen(
                roomId: roomId,
                title: titleController.text,
              ),
            ),
          );
        }

        roomCodeConTroller.clear();
        titleController.clear();
        passwordController.clear();
      } catch (e) {
        return e.toString();
      }
    } else {
      if (!isRoomCodeValid) {
        return "Room code does not exist";
      } else if (!isPasswordValid) {
        return "Incorrect password, try again";
      } else {
        return "The room was closed";
      }
    }

    return "";
  }

  Future createRoom() async {
    late String roomId;
    late String userName;
    try {
      roomId = randomRoomId();
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(auth!.email)
          .get()
          .then(
        (DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            userName = documentSnapshot["userName"];
          }
        },
      );

      await FirebaseFirestore.instance.collection("Rooms").doc(roomId).set(
        {
          "admin": auth?.email,
          "attenders": [
            {"attenderGmail": auth?.email, "attenderName": userName}
          ],
          "createdAt": DateTime.now(),
          "password": passwordController.text.toString().trim(),
          "result": [],
          "status": true,
          "title": titleController.text.toString(),
        },
      );

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => RoomScreen(
              roomId: roomId,
              title: titleController.text,
            ),
          ),
        );
        roomCodeConTroller.clear();
        titleController.clear();
        passwordController.clear();
      }
    } catch (e) {
      print("Something went wrong");
    }
  }

  void showLoadingModal() {}

  void showRoomDialog(BuildContext context, String content, String type) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Information",
          style: TextStyle(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        contentPadding: EdgeInsets.zero,
        actions: [
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                type == "create"
                    ? Form(
                        key: _formfield,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: "Title",
                              ),
                              maxLength: 30,
                              maxLines: null,
                              autofocus: true,
                              controller: titleController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter title";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: "Password",
                              ),
                              maxLength: 6,
                              controller: passwordController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter password";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      )
                    : Form(
                        key: _formfield,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: "Room code",
                              ),
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              controller: roomCodeConTroller,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter room code";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: "Password",
                              ),
                              maxLength: 6,
                              controller: passwordController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter password";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 20),
                errorText == ""
                    ? Container()
                    : Column(
                        children: [
                          Text(
                            errorText,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                isLoading
                    ? const CircularProgressIndicator(
                        backgroundColor: whiteColor,
                        color: primaryColor,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              roomCodeConTroller.clear();
                              titleController.clear();
                              passwordController.clear();
                              setState(() => errorText = "");
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding: const EdgeInsets.all(10.0),
                            ),
                            child: const Text(
                              'Cancle',
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formfield.currentState!.validate()) {
                                if (type == "create") {
                                  setState(() => isLoading = true);
                                  await createRoom();
                                  setState(() => isLoading = false);
                                } else {
                                  setState(() => isLoading = true);
                                  String error =
                                      await joinRoom(roomCodeConTroller.text);
                                  setState(() {
                                    isLoading = false;
                                    errorText = error;
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding: const EdgeInsets.all(10.0),
                            ),
                            child: const Text(
                              'Ok',
                              style: TextStyle(color: whiteColor),
                            ),
                          ),
                        ],
                      ),
              ],
            );
          })
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
        drawerEnableOpenDragGesture: false,
        drawer: const NavBar(),
        appBar: AppBar(
          shape: const Border(bottom: BorderSide(color: whiteColor, width: 1)),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: whiteColor),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          backgroundColor: primaryColor,
        ),
        body: ListView(
          padding: const EdgeInsets.all(30),
          children: [
            Image(
              image: const AssetImage(pyramidLogo),
              height: size.height * 0.3,
            ),
            const Text(
              "START",
              style: TextStyle(
                fontSize: 50,
                color: whiteColor,
                fontFamily: 'EBGaramond',
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: whiteColor, width: 1),
                borderRadius: BorderRadius.circular(20),
                color: whiteColor,
              ),
              child: const Text(
                'YOUR GAME',
                style: TextStyle(
                  fontSize: 50,
                  color: primaryColor,
                  fontFamily: 'EBGaramond',
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            const Icon(Icons.keyboard_double_arrow_down,
                size: 80, color: whiteColor),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showRoomDialog(context, "Enter room code", "join");
                },
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
                onPressed: () {
                  showRoomDialog(context, "Set up your room.", "create");
                },
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
    );
  }
}
