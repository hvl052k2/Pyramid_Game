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
import 'package:pyramid_game/src/features/core/room_screen/room_widgets/richText_widget.dart';
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
  bool isGoBack = true;
  List result = [];
  String userVoted1 = "",
      userVoted2 = "",
      userVoted3 = "",
      userVoted4 = "",
      userVoted5 = "";

  final CountdownController timerController =
      CountdownController(autoStart: false);

  Future updateSwitch(value) {
    CollectionReference room = FirebaseFirestore.instance.collection('Rooms');
    return room.doc(widget.roomId).update({"status": value});
  }

  Future updateIsCountdown(value) {
    CollectionReference room = FirebaseFirestore.instance.collection('Rooms');
    return room.doc(widget.roomId).update({"isCountdown": value});
  }

  Future updateSubmitterList() async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(
            FirebaseFirestore.instance.collection("Rooms").doc(widget.roomId));
        final userData = await FirebaseFirestore.instance
            .collection("Users")
            .doc(auth!.email)
            .get();

        if (!docSnapshot.exists) {
          throw Exception("Room does not exist");
        }

        List submitterListFirebase =
            List.from(docSnapshot.data()!["submitterList"]);
        submitterListFirebase
            .add({"name": userData["userName"], "gmail": auth!.email});

        transaction.update(
            docSnapshot.reference, {"submitterList": submitterListFirebase});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future updateResult(List result) async {
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
    updateIsCountdown(true);
    updateSwitch(false);
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
    Map outputMap1 = jsonDecode(userVoted1);
    Map outputMap2 = jsonDecode(userVoted2);
    Map outputMap3 = jsonDecode(userVoted3);
    Map outputMap4 = jsonDecode(userVoted4);
    Map outputMap5 = jsonDecode(userVoted5);

    Set uniqueValues = {
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
    Map outputMap1 = json.decode(userVoted1);
    Map outputMap2 = json.decode(userVoted2);
    Map outputMap3 = json.decode(userVoted3);
    Map outputMap4 = json.decode(userVoted4);
    Map outputMap5 = json.decode(userVoted5);
    Set uniqueValues = {
      outputMap1["gmail"],
      outputMap2["gmail"],
      outputMap3["gmail"],
      outputMap4["gmail"],
      outputMap5["gmail"],
    };

    bool isVoteForYourSelf = uniqueValues.contains(auth!.email.toString());
    return isVoteForYourSelf;
  }

  Future updateRankLists(List rankLists) async {
    final rank = ["A", "B", "C", "D", "F"];
    var myMap = {};
    for (var i = 0; i < rank.length; i++) {
      myMap[rank[i]] = rankLists[i];
    }
    CollectionReference room = FirebaseFirestore.instance.collection('Rooms');
    await room.doc(widget.roomId).update({"rankListsMap": myMap});
  }

  Future countVoted() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(widget.roomId)
        .get();
    List resultFirebase = docSnapshot["result"];

    Map countMap = {};

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

    List countVotedMap = countMap.values.toList();
    List sortedArrayWithCountAndName =
        await sortArrayWithCountAndName(countVotedMap);
    List rankLists = await divideRankList(sortedArrayWithCountAndName);

    // update rank list in firebase
    await updateRankLists(rankLists);

    setState(() {
      isLoading = false;
    });

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ResultScreen(
            roomId: widget.roomId,
          ),
        ),
      );
    }
  }

  List adjustRankF(List myArrayJson, List attenderNoVote) {
    // Kiểm tra xem trong myArrayJson có phần tử nào trùng rankFList hay không,
    // nếu có thì giá trị của key "count" của phần tử đó trong myArrayJson sẽ được gán bằng 0
    myArrayJson = myArrayJson.map((item1) {
      for (var item2 in attenderNoVote) {
        if (item2['gmail'] == item1['gmail']) {
          return {...item1, 'count': 0};
        }
      }
      return item1;
    }).toList();

    // Thêm người không tham gia voite
    for (var item in attenderNoVote) {
      if (!containsMap(myArrayJson, item)) {
        myArrayJson.add(item);
      }
    }

    print("myArrayJson after check with adjustRankF: $myArrayJson");
    return myArrayJson;
  }

  bool containsMap(List result, Map map) {
    return result.any((item) => map['gmail'] == item['gmail']);
  }

  List checkAttenderNoVote(List submitterList, List attenders) {
    // Xuất ra mảng chứa trong attenders nhưng không có trong submitterList
    List attenderNoVote = attenders.where((item1) {
      return !submitterList.any((item2) {
        return item2['gmail'] == item1['gmail'];
      });
    }).toList();

    // Thêm key "count" có giá trị 0 vào mảng vừa xuất ra.
    if (attenderNoVote.isNotEmpty) {
      attenderNoVote = attenderNoVote.map((item) {
        return {...item, 'count': 0};
      }).toList();
    }

    print("AttenderNoVote: $attenderNoVote");

    return attenderNoVote;
  }

  List checkSubmitterDontReceiveAnyVote(List submitterList, List list) {
    // Xuất ra mảng chứa trong result nhưng không có trong submitterList
    List submitterDontReceiveAnyVote =
        submitterList.where((item) => !containsMap(list, item)).toList();

    // Thêm key "count" có giá trị 0 vào mảng vừa xuất ra.
    if (submitterDontReceiveAnyVote.isNotEmpty) {
      submitterDontReceiveAnyVote = submitterDontReceiveAnyVote.map((item) {
        return {...item, 'count': 0};
      }).toList();
    }
    print("SubmitterDontReceiveAnyVote: $submitterDontReceiveAnyVote");

    return submitterDontReceiveAnyVote;
  }

  Future<List> sortArrayWithCountAndName(List myArrayJson) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(widget.roomId)
        .get();
    List submitterListFirebase = docSnapshot["submitterList"];
    List attendersFirebase = docSnapshot["attenders"];

    List attenderNoVote =
        checkAttenderNoVote(submitterListFirebase, attendersFirebase);
    List adjustMyArrayJson = adjustRankF(myArrayJson, attenderNoVote);

    List submitterDontReceiveAnyVote = checkSubmitterDontReceiveAnyVote(
        submitterListFirebase, adjustMyArrayJson);

    adjustMyArrayJson.addAll(submitterDontReceiveAnyVote);
    print(
        "adjustMyArrayJson after addAll submitterDontReceiveAnyVote: $adjustMyArrayJson");

    adjustMyArrayJson.sort((a, b) {
      var comparison = b['count'].compareTo(a['count']);
      if (comparison == 0) {
        var aName = a['name'].split(' ').last;
        var bName = b['name'].split(' ').last;
        comparison = aName.compareTo(bName);
      }
      return comparison;
    });

    print("adjustMyArrayJson after sort: $adjustMyArrayJson");

    return adjustMyArrayJson;
  }

  Future<List> divideRankList(List sortedResult) async {
    List rankLists = [];

    List f = []; // Tạo một danh sách rỗng để lưu trữ các phần tử có count = 0
    // Loại bỏ các phần tử có count = 0 khỏi mảng gốc
    sortedResult.removeWhere((item) {
      if (item["count"] == 0) {
        f.add(item);
        return true;
      }
      return false;
    });

    int len = sortedResult.length;
    List a = sortedResult.sublist(0, (len * 0.1).round());
    List b = sortedResult.sublist(a.length, a.length + (len * 0.2).round());
    List c = sortedResult.sublist(
        a.length + b.length, a.length + b.length + (len * 0.35).round());
    List d = sortedResult.sublist(a.length + b.length + c.length,
        a.length + b.length + c.length + (len * 0.25).round());

    rankLists
      ..add(a)
      ..add(b)
      ..add(c)
      ..add(d)
      ..add(f);

    print("rankLists after divide: $rankLists");
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
          Map outputMap1 = json.decode(userVoted1);
          Map outputMap2 = json.decode(userVoted2);
          Map outputMap3 = json.decode(userVoted3);
          Map outputMap4 = json.decode(userVoted4);
          Map outputMap5 = json.decode(userVoted5);
          result
            ..add(outputMap1)
            ..add(outputMap2)
            ..add(outputMap3)
            ..add(outputMap4)
            ..add(outputMap5);
          await updateSubmitterList();
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
        attenders
            .removeWhere((item) => item["gmail"] == auth!.email.toString());

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

  void showExitDialog(
      BuildContext context, String titleText, String contentText) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          titleText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          contentText,
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

  void showGameRules(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      backgroundColor: whiteColor,
      context: context,
      builder: (builder) {
        return SizedBox(
          width: size.width,
          // height: size.height,
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "GAME RULES",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'EBGaramond',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichTextWidget(
                      order: "1) ",
                      content:
                          "The game can only start when the number of players is greater than 5.",
                    ),
                    SizedBox(height: 10),
                    RichTextWidget(
                      order: "2) ",
                      content: "Only the room creator can start the game.",
                    ),
                    SizedBox(height: 10),
                    RichTextWidget(
                      order: "3) ",
                      content:
                          "You will not be able to exit the room once the game is started.",
                    ),
                    SizedBox(height: 10),
                    RichTextWidget(
                      order: "4) ",
                      content:
                          "Each player has 5 votes. You cannot vote for one person 2 times and cannot vote for yourself.",
                    ),
                    SizedBox(height: 10),
                    RichTextWidget(
                      order: "5) ",
                      content: "You can't leave the number of votes blank.",
                    ),
                    SizedBox(height: 10),
                    RichTextWidget(
                      order: "6) ",
                      content:
                          "Your voting results will only be recorded by clicking the SUBMIT button.",
                    ),
                    SizedBox(height: 10),
                    RichTextWidget(
                      order: "7) ",
                      content:
                          "Players who join the room without participating in the voting will be deleted and placed in rank F by default.",
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
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
              leading: isGoBack
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 35,
                        color: whiteColor,
                      ),
                      onPressed: () {
                        showExitDialog(
                          context,
                          "Information",
                          "Do you want to exit this room?",
                        );
                      },
                    )
                  : Container(),
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
                  onPressed: () {
                    showGameRules(context);
                  },
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
                  final roomData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  if (roomData["isCountdown"]) {
                    timerController.start();
                    isGoBack = false;
                  }
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isAdmin && roomData["status"]
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
                                            style:
                                                TextStyle(color: whiteColor)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Close",
                                              style:
                                                  TextStyle(color: whiteColor),
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
                                              style:
                                                  TextStyle(color: whiteColor),
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
                                        seconds: 30,
                                        build: (_, double time) => Text(
                                          "${time.toInt().toString()}s",
                                          style: const TextStyle(
                                              color: whiteColor),
                                        ),
                                        onFinished: () {
                                          countVoted();
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
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
                                inputDecorationTheme:
                                    const InputDecorationTheme(
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
                                              '"gmail": "${item["gmail"]}"',
                                              '"name": "${item["name"]}"'
                                            }.toString()),
                                            label: item["name"].toString(),
                                            labelWidget: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item["name"]),
                                                Text(
                                                  item["gmail"],
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
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
                                inputDecorationTheme:
                                    const InputDecorationTheme(
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
                                              '"gmail": "${item["gmail"]}"',
                                              '"name": "${item["name"]}"'
                                            }.toString()),
                                            label: item["name"].toString(),
                                            labelWidget: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item["name"]),
                                                Text(
                                                  item["gmail"],
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
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
                                inputDecorationTheme:
                                    const InputDecorationTheme(
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
                                              '"gmail": "${item["gmail"]}"',
                                              '"name": "${item["name"]}"'
                                            }.toString()),
                                            label: item["name"].toString(),
                                            labelWidget: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item["name"]),
                                                Text(
                                                  item["gmail"],
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
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
                                inputDecorationTheme:
                                    const InputDecorationTheme(
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
                                              '"gmail": "${item["gmail"]}"',
                                              '"name": "${item["name"]}"'
                                            }.toString()),
                                            label: item["name"].toString(),
                                            labelWidget: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item["name"]),
                                                Text(
                                                  item["gmail"],
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
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
                                inputDecorationTheme:
                                    const InputDecorationTheme(
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
                                              '"gmail": "${item["gmail"]}"',
                                              '"name": "${item["name"]}"'
                                            }.toString()),
                                            label: item["name"].toString(),
                                            labelWidget: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item["name"]),
                                                Text(
                                                  item["gmail"],
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
                                onPressed:
                                    roomData["isCountdown"] ? submit : null,
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
      ),
    );
  }
}
