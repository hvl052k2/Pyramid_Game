import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/features/core/home_screen/home_screen.dart';
import 'package:pyramid_game/src/features/core/result_screen/result_screen_widgets/custom_progress_bar.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.roomId});
  final String roomId;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const HomePage(),
                    ),
                  );
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
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            shape:
                const Border(bottom: BorderSide(color: whiteColor, width: 1)),
            title: const Text(
              "RESULT",
              style: TextStyle(
                color: whiteColor,
                fontFamily: 'EBGaramond',
                fontWeight: FontWeight.w700,
                fontSize: 30,
                letterSpacing: 5,
              ),
            ),
            centerTitle: true,
            backgroundColor: primaryColor,
            leading: Container(),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout_outlined,
                  size: 35,
                  color: whiteColor,
                ),
                onPressed: () {
                  showExitDialog(
                    context,
                    "Information",
                    "Do you want to exit?",
                  );
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
                final roomData = snapshot.data!.data() as Map<String, dynamic>;
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: roomData["rankListsMap"].keys.length,
                  itemBuilder: (context, index) {
                    String key = roomData["rankListsMap"].keys.elementAt(index);
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
