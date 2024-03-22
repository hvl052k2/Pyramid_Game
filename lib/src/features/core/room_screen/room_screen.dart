import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/constants/sizes.dart';
import 'package:pyramid_game/src/features/core/home_screen/home_screen.dart';
import 'package:pyramid_game/src/features/core/result_screen/result_screen.dart';
import 'package:pyramid_game/src/features/core/room_screen/room_widgets/vote_form_widget.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
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
  bool isSwitched = true;
  bool isLoading = false;
  bool isCountdown = false;
  bool isAdmin = false;
  List<Map<String, dynamic>> result = [];
  String userVoted1 = "",
      userVoted2 = "",
      userVoted3 = "",
      userVoted4 = "",
      userVoted5 = "";

  final CountdownController timerController =
      CountdownController(autoStart: true);

  Future updateSwitch(value) {
    CollectionReference room = FirebaseFirestore.instance.collection('Rooms');
    return room.doc(widget.roomId).update({"status": value});
  }

  // Future updateStartVoting(bool value) {
  //   CollectionReference room = FirebaseFirestore.instance.collection('Rooms');
  //   return room.doc(widget.roomId).update({"isStart": value});
  // }

  Future updateResult(List<Map<String, dynamic>> result) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(
            FirebaseFirestore.instance.collection("Rooms").doc(widget.roomId));

        if (!docSnapshot.exists) {
          throw Exception("Room does not exist");
        }

        List resultFirebase = List.from(docSnapshot.data()!["result"]);
        resultFirebase.addAll(result);
        // print("update result Firebase: $resultFirebase");

        transaction.update(docSnapshot.reference, {"result": resultFirebase});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void startVoting() {
    setState(() {
      isCountdown = true;
    });
    updateSwitch(false);
    // updateStartVoting(true);
  }

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

  void showImagePickerOption(BuildContext context, String type) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SizedBox(
          width: size.width,
          height: size.height / 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Column(children: [
                        Icon(
                          Icons.camera_alt,
                          color: primaryColor,
                          size: 70,
                        ),
                        Text(
                          "Camera",
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: "EBGaramond",
                            fontWeight: FontWeight.w500,
                            fontSize: 25,
                          ),
                        )
                      ]),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Column(children: [
                        Icon(
                          Icons.image,
                          color: primaryColor,
                          size: 70,
                        ),
                        Text(
                          "Gallery",
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: "EBGaramond",
                            fontWeight: FontWeight.w500,
                            fontSize: 25,
                          ),
                        )
                      ]),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showInforDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Information",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Ok',
                style: TextStyle(color: whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool checkDuplicateEmail() {
    Map<String, dynamic> outputMap1 = jsonDecode(userVoted1);
    Map<String, dynamic> outputMap2 = jsonDecode(userVoted2);
    Map<String, dynamic> outputMap3 = jsonDecode(userVoted3);
    Map<String, dynamic> outputMap4 = jsonDecode(userVoted4);
    Map<String, dynamic> outputMap5 = jsonDecode(userVoted5);

    Set<String> uniqueValues = {
      outputMap1["gmail"],
      outputMap2["gmail"],
      outputMap3["gmail"],
      outputMap4["gmail"],
      outputMap5["gmail"],
    };

    // Kiểm tra xem có giá trị trùng lặp hay không
    if (uniqueValues.length < 5) {
      return true;
    } else {
      return false;
    }
  }

  bool checkVoteForYourSelf() {
    Map<String, dynamic> outputMap1 = json.decode(userVoted1);
    Map<String, dynamic> outputMap2 = json.decode(userVoted2);
    Map<String, dynamic> outputMap3 = json.decode(userVoted3);
    Map<String, dynamic> outputMap4 = json.decode(userVoted4);
    Map<String, dynamic> outputMap5 = json.decode(userVoted5);
    Set<String> uniqueValues = {
      outputMap1["gmail"],
      outputMap2["gmail"],
      outputMap3["gmail"],
      outputMap4["gmail"],
      outputMap5["gmail"],
    };

    bool isVoteForYourSelf = uniqueValues.contains(auth!.email.toString());
    return isVoteForYourSelf;
  }

  Future countVoted() async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection("Rooms")
        .doc(widget.roomId)
        .get();
    List resultFirebase = docSnapshot["result"];
    Map<String, Map<String, dynamic>> countMap = {};

    for (var item in resultFirebase) {
      String key = item['gmail'];
      if (countMap.containsKey(key)) {
        countMap[key]?['count'] += 1;
      } else {
        countMap[key] = {
          'name': item['name'],
          'gmail': item['gmail'],
          'count': 1
        };
      }
    }

    List<Map<String, dynamic>> countVotedMap = countMap.values.toList();
    List<Map<String, dynamic>> sortedCountVotedMap =
        sortCountVotedMap(countVotedMap);
    List<List<Map<String, dynamic>>> rankLists =
        divideRankList(sortedCountVotedMap);

    setState(() {
      isLoading = false;
    });

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ResultScreen(
            rankLists: rankLists,
            roomId: widget.roomId,
          ),
        ),
      );
    }
  }

  List<Map<String, dynamic>> sortCountVotedMap(
      List<Map<String, dynamic>> ountVotedMap) {
    ountVotedMap.sort((a, b) => b['count'].compareTo(a['count']));
    return ountVotedMap;
  }

  List<List<Map<String, dynamic>>> divideRankList(
      List<Map<String, dynamic>> sortedResult) {
    List<List<Map<String, dynamic>>> rankLists = [];
    int len = sortedResult.length;
    List<Map<String, dynamic>> a = sortedResult.sublist(0, (len * 0.1).round());
    rankLists.add(a);
    List<Map<String, dynamic>> b =
        sortedResult.sublist(a.length, a.length + (len * 0.2).round());
    rankLists.add(b);
    List<Map<String, dynamic>> c = sortedResult.sublist(
        a.length + b.length, a.length + b.length + (len * 0.35).round());
    rankLists.add(c);
    List<Map<String, dynamic>> d = sortedResult.sublist(
        a.length + b.length + c.length,
        a.length + b.length + c.length + (len * 0.25).round());
    rankLists.add(d);
    List<Map<String, dynamic>> f =
        sortedResult.sublist(a.length + b.length + c.length + d.length);
    rankLists.add(f);

    return rankLists;
  }

  void submit() async {
    if (userVoted1 != "" &&
        userVoted2 != "" &&
        userVoted3 != "" &&
        userVoted4 != "" &&
        userVoted5 != "") {
      bool isDuplicate = checkDuplicateEmail();
      bool isVoteForYourSelf = checkVoteForYourSelf();
      if (!isDuplicate) {
        if (!isVoteForYourSelf) {
          setState(() {
            isLoading = true;
          });
          Map<String, dynamic> outputMap1 = json.decode(userVoted1);
          Map<String, dynamic> outputMap2 = json.decode(userVoted2);
          Map<String, dynamic> outputMap3 = json.decode(userVoted3);
          Map<String, dynamic> outputMap4 = json.decode(userVoted4);
          Map<String, dynamic> outputMap5 = json.decode(userVoted5);
          result
            ..add(outputMap1)
            ..add(outputMap2)
            ..add(outputMap3)
            ..add(outputMap4)
            ..add(outputMap5);
          await updateResult(result);
        } else {
          showInforDialog(context, "You can not vote for yourself");
        }
      } else {
        showInforDialog(context, "You voted the same person");
      }
    } else {
      showInforDialog(context, "Be carefu, some votes are blank");
    }
  }

  void leaveRoom() async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(
            FirebaseFirestore.instance.collection("Rooms").doc(widget.roomId));

        if (!docSnapshot.exists) {
          throw Exception("Room does not exist");
        }

        List attenders = List.from(docSnapshot.data()!["attenders"]);
        attenders.removeWhere(
            (item) => item["attenderGmail"] == auth!.email.toString());

        transaction.update(docSnapshot.reference, {"attenders": attenders});
      });

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const HomePage(),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    checkAdmin();
    super.initState();
  }

  void showExitDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Information",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "Do you want to exit this room?",
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                onPressed: () {
                  leaveRoom();
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(color: primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                ),
                child: const Text(
                  'No',
                  style: TextStyle(color: whiteColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 35,
                color: whiteColor,
              ),
              onPressed: () {
                showExitDialog(context);
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
                      child: const Text("Start voting"),
                    )
                  : Container(),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(
                  Icons.receipt_long_outlined,
                  size: 30,
                  color: whiteColor,
                ),
                onPressed: () {},
              ),
            ],
            backgroundColor: primaryColor,
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Rooms")
                .doc(widget.roomId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final roomData = snapshot.data!.data() as Map<String, dynamic>;
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isAdmin && !isCountdown
                              ? Container(
                                  width: 160,
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
                                      const Text("Room status",
                                          style: TextStyle(color: whiteColor)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Close",
                                            style: TextStyle(color: whiteColor),
                                          ),
                                          Switch(
                                            value: isSwitched,
                                            onChanged: (value) async {
                                              setState(() {
                                                isSwitched = value;
                                              });
                                              await updateSwitch(value);
                                            },
                                            activeColor: Colors.green,
                                            inactiveThumbColor: Colors.red,
                                            inactiveTrackColor:
                                                Colors.red.withOpacity(0.5),
                                          ),
                                          const Text(
                                            "Open",
                                            style: TextStyle(color: whiteColor),
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
                                    isCountdown
                                        ? TimerCountdown(
                                            enableDescriptions: false,
                                            format: CountDownTimerFormat
                                                .minutesSeconds,
                                            endTime: DateTime.now().add(
                                              const Duration(
                                                minutes: 0,
                                                seconds: 20,
                                              ),
                                            ),
                                            timeTextStyle: const TextStyle(
                                                color: whiteColor),
                                            colonsTextStyle: const TextStyle(
                                                color: whiteColor),
                                            onEnd: () {
                                              countVoted();
                                            },
                                          )
                                        : const Text(
                                            "00  :  20",
                                            style: TextStyle(color: whiteColor),
                                          ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.alarm, color: whiteColor),
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
                        fontSize: 30,
                        color: whiteColor,
                        fontFamily: 'EBGaramond',
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: whiteColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                              ),
                              child: const Text(
                                '1',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 10),
                            DropdownMenu(
                              inputDecorationTheme: const InputDecorationTheme(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: whiteColor),
                                ),
                              ),
                              requestFocusOnTap: true,
                              onSelected: (person) {
                                if (person != null) {
                                  userVoted1 = person.data.toString();
                                }
                              },
                              trailingIcon: const Icon(
                                Icons.arrow_drop_down,
                                color: whiteColor,
                              ),
                              enableFilter: true,
                              width: size.width / 1.7,
                              textStyle: const TextStyle(color: whiteColor),
                              dropdownMenuEntries:
                                  List.from(roomData["attenders"])
                                      .map(
                                        (item) => DropdownMenuEntry(
                                          value: Text({
                                            '"gmail": "${item["attenderGmail"]}"',
                                            '"name": "${item["attenderName"]}"'
                                          }.toString()),
                                          label:
                                              item["attenderName"].toString(),
                                          labelWidget: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item["attenderName"]),
                                              Text(
                                                item["attenderGmail"],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: whiteColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 10),
                            DropdownMenu(
                              inputDecorationTheme: const InputDecorationTheme(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: whiteColor),
                                ),
                              ),
                              requestFocusOnTap: true,
                              onSelected: (person) {
                                if (person != null) {
                                  userVoted2 = person.data.toString();
                                }
                              },
                              trailingIcon: const Icon(
                                Icons.arrow_drop_down,
                                color: whiteColor,
                              ),
                              enableFilter: true,
                              width: size.width / 1.7,
                              textStyle: const TextStyle(color: whiteColor),
                              dropdownMenuEntries:
                                  List.from(roomData["attenders"])
                                      .map(
                                        (item) => DropdownMenuEntry(
                                          value: Text({
                                            '"gmail": "${item["attenderGmail"]}"',
                                            '"name": "${item["attenderName"]}"'
                                          }.toString()),
                                          label:
                                              item["attenderName"].toString(),
                                          labelWidget: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item["attenderName"]),
                                              Text(
                                                item["attenderGmail"],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: whiteColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                              ),
                              child: const Text(
                                '3',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 10),
                            DropdownMenu(
                              inputDecorationTheme: const InputDecorationTheme(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: whiteColor),
                                ),
                              ),
                              requestFocusOnTap: true,
                              onSelected: (person) {
                                if (person != null) {
                                  userVoted3 = person.data.toString();
                                }
                              },
                              trailingIcon: const Icon(
                                Icons.arrow_drop_down,
                                color: whiteColor,
                              ),
                              enableFilter: true,
                              width: size.width / 1.7,
                              textStyle: const TextStyle(color: whiteColor),
                              dropdownMenuEntries:
                                  List.from(roomData["attenders"])
                                      .map(
                                        (item) => DropdownMenuEntry(
                                          value: Text({
                                            '"gmail": "${item["attenderGmail"]}"',
                                            '"name": "${item["attenderName"]}"'
                                          }.toString()),
                                          label:
                                              item["attenderName"].toString(),
                                          labelWidget: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item["attenderName"]),
                                              Text(
                                                item["attenderGmail"],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: whiteColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                              ),
                              child: const Text(
                                '4',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 10),
                            DropdownMenu(
                              inputDecorationTheme: const InputDecorationTheme(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: whiteColor),
                                ),
                              ),
                              requestFocusOnTap: true,
                              onSelected: (person) {
                                if (person != null) {
                                  userVoted4 = person.data.toString();
                                }
                              },
                              trailingIcon: const Icon(
                                Icons.arrow_drop_down,
                                color: whiteColor,
                              ),
                              enableFilter: true,
                              width: size.width / 1.7,
                              textStyle: const TextStyle(color: whiteColor),
                              dropdownMenuEntries:
                                  List.from(roomData["attenders"])
                                      .map(
                                        (item) => DropdownMenuEntry(
                                          value: Text({
                                            '"gmail": "${item["attenderGmail"]}"',
                                            '"name": "${item["attenderName"]}"'
                                          }.toString()),
                                          label:
                                              item["attenderName"].toString(),
                                          labelWidget: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item["attenderName"]),
                                              Text(
                                                item["attenderGmail"],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: whiteColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                              ),
                              child: const Text(
                                '5',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 25,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 10),
                            DropdownMenu(
                              inputDecorationTheme: const InputDecorationTheme(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: whiteColor),
                                ),
                              ),
                              requestFocusOnTap: true,
                              onSelected: (person) {
                                if (person != null) {
                                  userVoted5 = person.data.toString();
                                }
                              },
                              trailingIcon: const Icon(
                                Icons.arrow_drop_down,
                                color: whiteColor,
                              ),
                              enableFilter: true,
                              width: size.width / 1.7,
                              textStyle: const TextStyle(color: whiteColor),
                              dropdownMenuEntries:
                                  List.from(roomData["attenders"])
                                      .map(
                                        (item) => DropdownMenuEntry(
                                          value: Text({
                                            '"gmail": "${item["attenderGmail"]}"',
                                            '"name": "${item["attenderName"]}"'
                                          }.toString()),
                                          label:
                                              item["attenderName"].toString(),
                                          labelWidget: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item["attenderName"]),
                                              Text(
                                                item["attenderGmail"],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: isLoading
                          ? const Column(
                              children: [
                                LinearProgressIndicator(
                                  backgroundColor: whiteColor,
                                  color: primaryColor,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Wating everyone ...",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontFamily: 'EBGaramond',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25,
                                  ),
                                )
                              ],
                            )
                          : ElevatedButton(
                              onPressed: isCountdown ? submit : null,
                              style: ElevatedButton.styleFrom(
                                disabledBackgroundColor: Colors.grey,
                                disabledForegroundColor: whiteColor,
                                foregroundColor: whiteColor,
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: buttonHeight,
                                ),
                              ),
                              child: const Text(
                                'SUBMIT',
                                style: TextStyle(
                                  fontFamily: 'EBGaramond',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
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
    );
  }
}
