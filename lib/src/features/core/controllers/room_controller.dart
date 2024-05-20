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

  Future updateSwitch(value) async {
    await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(roomId.value)
        .update({"status": value});
  }

  Future updateIsKickedOut(bool value) async {
    await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(roomId.value)
        .update({"isKickedOut": value});
  }

  Future updateIsCountdown(value) async {
    await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(roomId.value)
        .update({"isCountdown": value});
  }

  Future updateSubmitterList() async {
    final auth = FirebaseAuth.instance.currentUser;

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
            .add({"name": userData["userName"], "gmail": auth.email});

        transaction.update(
            docSnapshot.reference, {"submitterList": submitterListFirebase});
      });
    } catch (e) {
      // Handle error
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

        transaction.update(docSnapshot.reference, {"result": resultFirebase});
      });
    } catch (e) {
      // Handle error
    }
  }

  bool checkDuplicateEmail() {
    final emails = {
      jsonDecode(userVoted1.value)["gmail"],
      jsonDecode(userVoted2.value)["gmail"],
      jsonDecode(userVoted3.value)["gmail"],
      jsonDecode(userVoted4.value)["gmail"],
      jsonDecode(userVoted5.value)["gmail"],
    };
    return emails.length < 5;
  }

  bool checkVoteForYourSelf() {
    final auth = FirebaseAuth.instance.currentUser;

    final emails = {
      json.decode(userVoted1.value)["gmail"],
      json.decode(userVoted2.value)["gmail"],
      json.decode(userVoted3.value)["gmail"],
      json.decode(userVoted4.value)["gmail"],
      json.decode(userVoted5.value)["gmail"],
    };
    return emails.contains(auth!.email.toString());
  }

  Future updateRankLists(List rankLists) async {
    final rank = ["A", "B", "C", "D", "F"];
    final rankMap = Map.fromIterables(rank, rankLists);

    await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(roomId.value)
        .update({"rankListsMap": rankMap});
  }

  Future countVoted() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(roomId.value)
        .get();
    final resultFirebase = docSnapshot["result"];

    final countMap = <String, Map<String, dynamic>>{};
    for (final item in resultFirebase) {
      final key = item['gmail'];
      if (countMap.containsKey(key)) {
        countMap[key]!['count'] += 1;
      } else {
        countMap[key] = {
          'name': item['name'],
          'gmail': item['gmail'],
          'count': 1
        };
      }
    }

    final countVotedMap = countMap.values.toList();
    final sortedArrayWithCountAndName =
        await sortArrayWithCountAndName(countVotedMap);
    final rankLists = await divideRankList(sortedArrayWithCountAndName);

    await updateRankLists(rankLists);

    toggleIsLoading(false);

    Get.offAll(() => ResultScreen(
          roomId: roomId.value,
          type: "stream",
        ));
  }

  List adjustRankF(List myArrayJson, List attenderNoVote) {
    myArrayJson = myArrayJson.map((item1) {
      for (final item2 in attenderNoVote) {
        if (item2['gmail'] == item1['gmail']) {
          return {...item1, 'count': 0};
        }
      }
      return item1;
    }).toList();

    for (final item in attenderNoVote) {
      if (!myArrayJson.any((element) => element['gmail'] == item['gmail'])) {
        myArrayJson.add(item);
      }
    }
    return myArrayJson;
  }

  List checkAttenderNoVote(List submitterList, List attenders) {
    final attenderNoVote = attenders
        .where((item1) =>
            !submitterList.any((item2) => item2['gmail'] == item1['gmail']))
        .toList();

    return attenderNoVote.map((item) => {...item, 'count': 0}).toList();
  }

  List checkSubmitterDontReceiveAnyVote(List submitterList, List list) {
    final submitterDontReceiveAnyVote = submitterList
        .where(
            (item) => !list.any((element) => element['gmail'] == item['gmail']))
        .toList();

    return submitterDontReceiveAnyVote
        .map((item) => {...item, 'count': 0})
        .toList();
  }

  Future<List> sortArrayWithCountAndName(List myArrayJson) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(roomId.value)
        .get();
    final submitterListFirebase = docSnapshot["submitterList"];
    final attendersFirebase = docSnapshot["attenders"];

    final attenderNoVote =
        checkAttenderNoVote(submitterListFirebase, attendersFirebase);
    final adjustMyArrayJson = adjustRankF(myArrayJson, attenderNoVote);

    final submitterDontReceiveAnyVote = checkSubmitterDontReceiveAnyVote(
        submitterListFirebase, adjustMyArrayJson);

    adjustMyArrayJson.addAll(submitterDontReceiveAnyVote);

    adjustMyArrayJson.sort((a, b) {
      final countComparison = b['count'].compareTo(a['count']);
      if (countComparison != 0) {
        return countComparison;
      }
      final aName = a['name'].split(' ').last;
      final bName = b['name'].split(' ').last;
      return aName.compareTo(bName);
    });
    return adjustMyArrayJson;
  }

  Future<List> divideRankList(List sortedResult) async {
    final f = sortedResult.where((item) => item["count"] == 0).toList();
    sortedResult.removeWhere((item) => item["count"] == 0);

    final len = sortedResult.length;
    final a = sortedResult.sublist(0, (len * 0.1).round());
    final b = sortedResult.sublist(a.length, a.length + (len * 0.15).round());
    final c = sortedResult.sublist(
        a.length + b.length, a.length + b.length + (len * 0.25).round());
    final d = sortedResult.sublist(a.length + b.length + c.length,
        a.length + b.length + c.length + (len * 0.5).round());

    return [a, b, c, d, f];
  }

  void leaveRoom() async {
    final auth = FirebaseAuth.instance.currentUser;
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
      // Handle error
    }
  }

  bool checkExist(List attenders) {
    final auth = FirebaseAuth.instance.currentUser;

    return attenders.any((item) => item["gmail"] == auth!.email);
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
      final isDuplicate = checkDuplicateEmail();
      final isVoteForYourSelf = checkVoteForYourSelf();
      if (!isDuplicate) {
        if (!isVoteForYourSelf) {
          toggleIsLoading(true);
          final outputMap1 = json.decode(userVoted1.value);
          final outputMap2 = json.decode(userVoted2.value);
          final outputMap3 = json.decode(userVoted3.value);
          final outputMap4 = json.decode(userVoted4.value);
          final outputMap5 = json.decode(userVoted5.value);
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
      showInforDialog("Be careful, some votes are blank".tr);
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
            child: SingleChildScrollView(
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
                        content:
                            "You can't leave the number of votes blank.".tr,
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
          ),
        );
      },
    );
  }
}
