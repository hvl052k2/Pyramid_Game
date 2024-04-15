import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/features/core/screens/home_screen/home_screen.dart'; 
import 'package:pyramid_game/src/features/core/screens/result_screen/result_screen_widgets/custom_progress_bar.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.roomId, required this.type});
  final String roomId;
  final String type;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  void showExitDialog() {
    Get.defaultDialog(
      title: "Information".tr,
      titleStyle: const TextStyle(color: Colors.red),
      content: Text(
        "Do you want to exit?".tr,
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: () {
                Get.offAll(() => HomePage());
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
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
                  borderRadius: BorderRadius.circular(25.0),
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
      barrierDismissible: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }

  void saveHistory() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection("Rooms")
        .doc(widget.roomId)
        .get();
    List attendersFirebase = docSnapshot["attenders"];
    Map rankListsMapFirebase = docSnapshot["rankListsMap"];
    String titleFirebase = docSnapshot["title"];
    for (var item in attendersFirebase) {
      final userData = await FirebaseFirestore.instance
          .collection("Users")
          .doc(item["gmail"])
          .get();
      if (userData.exists) {
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(item["gmail"])
            .collection("History")
            .doc(widget.roomId)
            .set({
          "createdAt": DateTime.now(),
          "numberOfPlayers": attendersFirebase.length,
          "rankListsMap": rankListsMapFirebase,
          "title": titleFirebase
        });
      }
    }
  }

  @override
  void initState() {
    if (widget.type == "stream") {
      saveHistory();
    } else {
      return;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            shape: const Border(
              bottom: BorderSide(color: whiteColor, width: 1),
            ),
            title: Text(
              "RESULT".tr,
              style: const TextStyle(
                color: whiteColor,
                fontFamily: 'EBGaramond',
                fontWeight: FontWeight.w700,
                fontSize: 30,
                letterSpacing: 5,
              ),
            ),
            centerTitle: true,
            backgroundColor: primaryColor,
            leading: widget.type == "watchHistory"
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 35,
                      color: whiteColor,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  )
                : Container(),
            actions: [
              widget.type == "stream"
                  ? IconButton(
                      icon: const Icon(
                        Icons.logout_outlined,
                        size: 35,
                        color: whiteColor,
                      ),
                      onPressed: () {
                        showExitDialog();
                      },
                    )
                  : Container(),
            ],
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Rooms")
                .doc(widget.roomId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final roomData = snapshot.data!.data() as Map<String, dynamic>;
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: Map.from(roomData["rankListsMap"]).keys.length,
                  itemBuilder: (context, index) {
                    String key = Map.from(roomData["rankListsMap"])
                        .keys
                        .elementAt(index);
                    return Container(
                      height: List.from(roomData["rankListsMap"][key])
                              .isNotEmpty
                          ? List.from(roomData["rankListsMap"][key]).length * 60
                          : 60,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              alignment: Alignment.topCenter,
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: whiteColor, width: 2),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Text(
                                key,
                                style: const TextStyle(
                                  color: whiteColor,
                                  fontFamily: 'EBGaramond',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 40,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 70),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.from(
                                                roomData["rankListsMap"][key])
                                            .map((item) => Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item["name"],
                                                      style: const TextStyle(
                                                        color: whiteColor,
                                                        fontFamily:
                                                            'EBGaramond',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Text(
                                                      item["gmail"],
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontFamily:
                                                            'EBGaramond',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                  ],
                                                ))
                                            .toList(),
                                      ),
                                      const SizedBox(width: 10),
                                      List.from(roomData["rankListsMap"][key])
                                              .isNotEmpty
                                          ? const VerticalDivider(
                                              color: Colors.grey,
                                              width: 3,
                                              thickness: 2,
                                            )
                                          : Container(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.from(
                                                roomData["rankListsMap"][key])
                                            .map((item) => CustomProgressbar(
                                                  width: (item["count"] * 2)
                                                      .toDouble(),
                                                  height: 40,
                                                  numVote: item["count"],
                                                ))
                                            .toList(),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
