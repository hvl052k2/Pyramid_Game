import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/features/core/screens/home_screen/home_screen.dart';
import 'package:pyramid_game/src/features/core/screens/result_screen/result_screen.dart';
import 'package:pyramid_game/src/features/core/screens/room_screen/room_widgets/richText_widget.dart';

class RoomController extends GetxController {
  final auth = FirebaseAuth.instance.currentUser;

  RxString userVoted1 = "".obs;
  RxString userVoted2 = "".obs;
  RxString userVoted3 = "".obs;
  RxString userVoted4 = "".obs;
  RxString userVoted5 = "".obs;
  RxString roomId = "".obs;

  RxList result = [].obs;

  RxBool isSwitched = true.obs;
  RxBool isLoading = false.obs;

  void toggleIsLoading(bool value) {
    isLoading.value = value;
  }

  void toggleIsSwitched(bool value) {
    isSwitched.value = value;
  }

  Future updateSwitch(value) {
    CollectionReference room = FirebaseFirestore.instance.collection('Rooms');
    return room.doc(roomId.value).update({"status": value});
  }

  Future updateIsCountdown(value) {
    CollectionReference room = FirebaseFirestore.instance.collection('Rooms');
    return room.doc(roomId.value).update({"isCountdown": value});
  }

  Future updateSubmitterList() async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(
            FirebaseFirestore.instance.collection("Rooms").doc(roomId.value));
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
      // print(e.toString());
    }
  }

  Future updateResult(List result) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(
            FirebaseFirestore.instance.collection("Rooms").doc(roomId.value));

        if (!docSnapshot.exists) {
          throw Exception("Room does not exist");
        }

        List resultFirebase = List.from(docSnapshot.data()!["result"]);
        resultFirebase.addAll(result);
        // print("update result Firebase: $resultFirebase");

        transaction.update(docSnapshot.reference, {"result": resultFirebase});
      });
    } catch (e) {
      // print(e.toString());
    }
  }

  bool checkDuplicateEmail() {
    Map outputMap1 = jsonDecode(userVoted1.value);
    Map outputMap2 = jsonDecode(userVoted2.value);
    Map outputMap3 = jsonDecode(userVoted3.value);
    Map outputMap4 = jsonDecode(userVoted4.value);
    Map outputMap5 = jsonDecode(userVoted5.value);

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
    Map outputMap1 = json.decode(userVoted1.value);
    Map outputMap2 = json.decode(userVoted2.value);
    Map outputMap3 = json.decode(userVoted3.value);
    Map outputMap4 = json.decode(userVoted4.value);
    Map outputMap5 = json.decode(userVoted5.value);
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
    await room.doc(roomId.value).update({"rankListsMap": myMap});
  }

  Future countVoted() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(roomId.value)
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

    toggleIsLoading(false);

    Get.offAll(() => ResultScreen(
          roomId: roomId.value,
          type: "stream",
        ));
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

    // print("myArrayJson after check with adjustRankF: $myArrayJson");
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

    // print("AttenderNoVote: $attenderNoVote");

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
    // print("SubmitterDontReceiveAnyVote: $submitterDontReceiveAnyVote");

    return submitterDontReceiveAnyVote;
  }

  Future<List> sortArrayWithCountAndName(List myArrayJson) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(roomId.value)
        .get();
    List submitterListFirebase = docSnapshot["submitterList"];
    List attendersFirebase = docSnapshot["attenders"];

    List attenderNoVote =
        checkAttenderNoVote(submitterListFirebase, attendersFirebase);
    List adjustMyArrayJson = adjustRankF(myArrayJson, attenderNoVote);

    List submitterDontReceiveAnyVote = checkSubmitterDontReceiveAnyVote(
        submitterListFirebase, adjustMyArrayJson);

    adjustMyArrayJson.addAll(submitterDontReceiveAnyVote);
    // print(
    //     "adjustMyArrayJson after addAll submitterDontReceiveAnyVote: $adjustMyArrayJson");

    adjustMyArrayJson.sort((a, b) {
      var comparison = b['count'].compareTo(a['count']);
      if (comparison == 0) {
        var aName = a['name'].split(' ').last;
        var bName = b['name'].split(' ').last;
        comparison = aName.compareTo(bName);
      }
      return comparison;
    });

    // print("adjustMyArrayJson after sort: $adjustMyArrayJson");

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

    // print("rankLists after divide: $rankLists");
    return rankLists;
  }

  void leaveRoom() async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(
            FirebaseFirestore.instance.collection("Rooms").doc(roomId.value));

        if (!docSnapshot.exists) {
          throw Exception("Room does not exist");
        }

        List attenders = List.from(docSnapshot.data()!["attenders"]);
        attenders
            .removeWhere((item) => item["gmail"] == auth!.email.toString());

        transaction.update(docSnapshot.reference, {"attenders": attenders});
      });
      Get.off(() => HomePage());
    } catch (e) {
      // print(e.toString());
    }
  }

  void showInforDialog(String content) {
    Get.defaultDialog(
      title: "Information".tr,
      titleStyle: const TextStyle(color: Colors.red),
      content: Text(
        content,
        textAlign: TextAlign.center,
      ),
      onConfirm: () => Get.back(),
      barrierDismissible: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }

  void submit() async {
    if (userVoted1.value != "" &&
        userVoted2.value != "" &&
        userVoted3.value != "" &&
        userVoted4.value != "" &&
        userVoted5.value != "") {
      bool isDuplicate = checkDuplicateEmail();
      bool isVoteForYourSelf = checkVoteForYourSelf();
      if (!isDuplicate) {
        if (!isVoteForYourSelf) {
          toggleIsLoading(true);
          Map outputMap1 = json.decode(userVoted1.value);
          Map outputMap2 = json.decode(userVoted2.value);
          Map outputMap3 = json.decode(userVoted3.value);
          Map outputMap4 = json.decode(userVoted4.value);
          Map outputMap5 = json.decode(userVoted5.value);
          result
            ..add(outputMap1)
            ..add(outputMap2)
            ..add(outputMap3)
            ..add(outputMap4)
            ..add(outputMap5);
          await updateSubmitterList();
          await updateResult(result);
        } else {
          showInforDialog("You can not vote for yourself".tr);
        }
      } else {
        showInforDialog("You voted the same person".tr);
      }
    } else {
      showInforDialog("Be carefu, some votes are blank".tr);
    }
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
                  Get.back();
                  leaveRoom();
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                ),
                child: Text(
                  'Yes'.tr,
                  style: const TextStyle(color: primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                ),
                child: Text(
                  'No'.tr,
                  style: const TextStyle(color: whiteColor),
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "GAME RULES".tr,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'EBGaramond',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichTextWidget(
                      order: "1) ",
                      content:
                          "The game can only start when the number of players is greater than 5 (minimum 6 persons)."
                              .tr,
                    ),
                    const SizedBox(height: 5),
                    RichTextWidget(
                      order: "2) ",
                      content: "Only the room creator can start the game.".tr,
                    ),
                    const SizedBox(height: 5),
                    RichTextWidget(
                      order: "3) ",
                      content:
                          "You will not be able to exit the room once the game is started."
                              .tr,
                    ),
                    const SizedBox(height: 5),
                    RichTextWidget(
                      order: "4) ",
                      content:
                          "Each player has 5 votes. You cannot vote for one person 2 times and cannot vote for yourself."
                              .tr,
                    ),
                    const SizedBox(height: 5),
                    RichTextWidget(
                      order: "5) ",
                      content: "You can't leave the number of votes blank.".tr,
                    ),
                    const SizedBox(height: 5),
                    RichTextWidget(
                      order: "6) ",
                      content:
                          "Your voting results will be recorded only after pressing SUBMIT."
                              .tr,
                    ),
                    const SizedBox(height: 5),
                    RichTextWidget(
                      order: "7) ",
                      content:
                          "Players who join the room without participating in voting will be placed in F class with 0 votes by default."
                              .tr,
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
}
