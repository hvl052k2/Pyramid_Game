import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/common_widgets/custom_elevated_button.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/features/core/controllers/room_controller.dart';
import 'package:pyramid_game/src/features/core/screens/room_screen/room_widgets/vote_form_widget.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.roomId, required this.title});
  final String roomId;
  final String title;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final auth = FirebaseAuth.instance.currentUser;

  //
  bool isCountdown = false;
  bool isAdmin = false;
  bool canStart = false;
  final roomController = Get.put(RoomController());
  //

  final CountdownController timerController =
      CountdownController(autoStart: false);

  void checkAdmin() async {
    late String adminEmail;
    await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(widget.roomId)
        .get()
        .then(
      (DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          adminEmail = documentSnapshot["admin"];
        }
      },
    );
    if (adminEmail == auth?.email) {
      setState(() {
        isAdmin = true;
      });
    }
  }

  @override
  void initState() {
    roomController.roomId.value = widget.roomId;
    checkAdmin();
    super.initState();
  }

  void startVoting() {
    if (canStart) {
      setState(() {
        isCountdown = true;
      });
      roomController.updateIsCountdown(true);
      roomController.updateSwitch(false);
    } else {
      roomController.showInforDialog(
          "The number of players is less than 6, it is impossible to start."
              .tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {});
          },
          child: Scaffold(
            backgroundColor: primaryColor,
            appBar: AppBar(
              backgroundColor: primaryColor,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 35,
                  color: whiteColor,
                ),
                onPressed: () {
                  if (isCountdown) {
                    roomController.showInforDialog(
                        "You cannot leave the room while voting.".tr);
                  } else {
                    roomController.showExitDialog(
                      context,
                      "Information".tr,
                      "Do you want to exit this room?".tr,
                    );
                  }
                },
              ),
              actions: [
                isAdmin
                    ? ElevatedButton(
                        onPressed: isCountdown ? null : startVoting,
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: Colors.grey,
                          disabledForegroundColor: primaryColor,
                          foregroundColor: whiteColor,
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                        child: Text("Start voting".tr),
                      )
                    : Container(),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.receipt_long_outlined,
                    size: 30,
                    color: whiteColor,
                  ),
                  onPressed: () {
                    roomController.showGameRules(context);
                  },
                ),
              ],
            ),
            body: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Rooms")
                  .doc(widget.roomId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final roomData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  if (List.from(roomData["attenders"]).length > 5) {
                    canStart = true;
                  }
                  if (roomData["isCountdown"]) {
                    timerController.start();
                    isCountdown = true;
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isAdmin && !roomData["isCountdown"]
                                ? Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: whiteColor),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("Room status".tr,
                                            style: const TextStyle(
                                                color: whiteColor)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Close".tr,
                                              style: const TextStyle(
                                                  color: whiteColor),
                                            ),
                                            Obx(
                                              () => Switch(
                                                value: roomController
                                                    .isSwitched.value,
                                                onChanged: (value) async {
                                                  roomController
                                                      .toggleIsSwitched(value);
                                                  await roomController
                                                      .updateSwitch(value);
                                                },
                                                activeColor: Colors.green,
                                                inactiveThumbColor: Colors.red,
                                                inactiveTrackColor:
                                                    Colors.red.withOpacity(0.5),
                                              ),
                                            ),
                                            Text(
                                              "Open".tr,
                                              style: const TextStyle(
                                                  color: whiteColor),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: whiteColor),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            List.from(roomData['attenders'])
                                                .toList()
                                                .length
                                                .toString(),
                                            style: const TextStyle(
                                              color: whiteColor,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.person,
                                            color: whiteColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: whiteColor),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.roomId,
                                            style: const TextStyle(
                                                color: whiteColor),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.home,
                                            color: whiteColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: whiteColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Countdown(
                                        controller: timerController,
                                        seconds: 150,
                                        build: (_, double time) => Text(
                                          "${time.toInt().toString()}s",
                                          style: const TextStyle(
                                              color: whiteColor),
                                        ),
                                        onFinished: () {
                                          roomController.countVoted();
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.alarm,
                                          color: whiteColor),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Image(
                        image: const AssetImage(pyramidLogo),
                        height: size.height * 0.2,
                      ),
                      Text(
                        roomData["title"],
                        style: const TextStyle(
                          fontSize: 25,
                          color: whiteColor,
                          fontFamily: 'EBGaramond',
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          VoteFormWidget(
                            size: size,
                            order: "1",
                            attenderList: roomData["attenders"],
                            onSelected: (person) {
                              if (person != null) {
                                roomController.userVoted1.value =
                                    person.data.toString();
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          VoteFormWidget(
                            size: size,
                            order: "2",
                            attenderList: roomData["attenders"],
                            onSelected: (person) {
                              if (person != null) {
                                roomController.userVoted2.value =
                                    person.data.toString();
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          VoteFormWidget(
                            size: size,
                            order: "3",
                            attenderList: roomData["attenders"],
                            onSelected: (person) {
                              if (person != null) {
                                roomController.userVoted3.value =
                                    person.data.toString();
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          VoteFormWidget(
                            size: size,
                            order: "4",
                            attenderList: roomData["attenders"],
                            onSelected: (person) {
                              if (person != null) {
                                roomController.userVoted4.value =
                                    person.data.toString();
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          VoteFormWidget(
                            size: size,
                            order: "5",
                            attenderList: roomData["attenders"],
                            onSelected: (person) {
                              if (person != null) {
                                roomController.userVoted5.value =
                                    person.data.toString();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Obx(
                        () => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: roomController.isLoading.value
                              ? Column(
                                  children: [
                                    const LinearProgressIndicator(
                                      backgroundColor: whiteColor,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "Wating everyone ...".tr,
                                      style: const TextStyle(
                                        color: whiteColor,
                                        fontFamily: 'EBGaramond',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 25,
                                      ),
                                    )
                                  ],
                                )
                              : CustomElevatedButton(
                                  onPressed: roomData["isCountdown"]
                                      ? roomController.submit
                                      : null,
                                  textContent: "SUBMIT".tr,
                                  disableBackCorlor: Colors.grey,
                                  disableForeCorlor: whiteColor,
                                ),
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
        ),
      ),
    );
  }
}
