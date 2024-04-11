import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/features/core/screens/room_screen/room_screen.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxString errorText = ''.obs;

  final formfield = GlobalKey<FormState>();
  final password = TextEditingController();
  final roomCode = TextEditingController();
  final title = TextEditingController();
  final auth = FirebaseAuth.instance.currentUser;

  void toggleIsLoading(bool value) {
    isLoading.value = value;
  }

  Future<String> randomRoomId() async {
    final random = Random();
    final randomNumber = random.nextInt(1000000);
    late String formattedNumber;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot;
      do {
        formattedNumber = randomNumber.toString().padLeft(9, '0');
        docSnapshot = await transaction.get(FirebaseFirestore.instance
            .collection("Rooms")
            .doc(formattedNumber));
      } while (docSnapshot.exists);
    });
    return formattedNumber;
  }

  Future<bool> checkRoomCode() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(roomCode.text.toString())
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
        .doc(roomCode.text.toString())
        .get();

    if (docSnapshot.exists) {
      return password.text == docSnapshot["password"];
    } else {
      return false;
    }
  }

  Future<bool> checkRoomStatus() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(roomCode.text.toString())
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
            "gmail": auth?.email,
            "name": userName,
          });

          transaction.update(docSnapshot.reference, {"attenders": attenders});
        });

        Get.back();
        Get.to(() => RoomScreen(roomId: roomId, title: title.text));

        roomCode.clear();
        title.clear();
        password.clear();
      } catch (e) {
        return e.toString();
      }
    } else {
      if (!isRoomCodeValid) {
        return "Room code does not exist".tr;
      } else if (!isPasswordValid) {
        return "Incorrect password, try again".tr;
      } else {
        return "The room was closed".tr;
      }
    }
    return "";
  }

  Future createRoom() async {
    late String roomId;
    late String userName;
    try {
      roomId = await randomRoomId();

      // Lấy userName của người tạo phòng
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
            {"gmail": auth?.email, "name": userName}
          ],
          "createdAt": DateTime.now(),
          "password": password.text.toString().trim(),
          "rankListsMap": {},
          "result": [],
          "status": true,
          "isCountdown": false,
          "title": title.text.toString(),
          "submitterList": [],
        },
      );

      Get.back();
      Get.off(() => RoomScreen(roomId: roomId, title: title.text));

      roomCode.clear();
      title.clear();
      password.clear();
    } catch (e) {
      print("Something went wrong");
    }
  }

  void showJoinRoomDialog(BuildContext context, String content) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Information".tr,
          style: const TextStyle(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        contentPadding: EdgeInsets.zero,
        actions: [
          Obx(
            () => Column(
              children: [
                Form(
                  key: formfield,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Room code".tr,
                        ),
                        maxLength: 9,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        controller: roomCode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter room code".tr;
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Password".tr,
                        ),
                        maxLength: 6,
                        controller: password,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter password".tr;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                errorText.value == ""
                    ? Container()
                    : Column(
                        children: [
                          Obx(() => Text(
                                errorText.value,
                                style: const TextStyle(color: Colors.red),
                              )),
                          const SizedBox(height: 10),
                        ],
                      ),
                isLoading.value
                    ? const CircularProgressIndicator(
                        backgroundColor: whiteColor,
                        color: primaryColor,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Get.back();
                              roomCode.clear();
                              title.clear();
                              password.clear();
                              errorText.value = "";
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: const EdgeInsets.all(10.0),
                            ),
                            child: Text(
                              'Cancle'.tr,
                              style: const TextStyle(color: primaryColor),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (formfield.currentState!.validate()) {
                                toggleIsLoading(true);
                                String error = await joinRoom(roomCode.text);
                                toggleIsLoading(false);
                                errorText.value = error;
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: const EdgeInsets.all(10.0),
                            ),
                            child: Text(
                              'Ok'.tr,
                              style: const TextStyle(color: whiteColor),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void showCreateRoomDialog(BuildContext context, String content) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Information".tr,
          style: const TextStyle(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        contentPadding: EdgeInsets.zero,
        actions: [
          Obx(
            () => Column(
              children: [
                Form(
                  key: formfield,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Title".tr,
                        ),
                        maxLength: 30,
                        maxLines: null,
                        autofocus: true,
                        controller: title,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter title".tr;
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Password".tr,
                        ),
                        maxLength: 6,
                        controller: password,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter password".tr;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                errorText.value == ""
                    ? Container()
                    : Column(
                        children: [
                          Obx(() => Text(
                                errorText.value,
                                style: const TextStyle(color: Colors.red),
                              )),
                          const SizedBox(height: 10),
                        ],
                      ),
                isLoading.value
                    ? const CircularProgressIndicator(
                        backgroundColor: whiteColor,
                        color: primaryColor,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Get.back();
                              roomCode.clear();
                              title.clear();
                              password.clear();
                              errorText.value = "";
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: const EdgeInsets.all(10.0),
                            ),
                            child: Text(
                              'Cancle'.tr,
                              style: const TextStyle(color: primaryColor),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (formfield.currentState!.validate()) {
                                toggleIsLoading(true);
                                await createRoom();
                                toggleIsLoading(false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: const EdgeInsets.all(10.0),
                            ),
                            child: Text(
                              'Ok'.tr,
                              style: const TextStyle(color: whiteColor),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
