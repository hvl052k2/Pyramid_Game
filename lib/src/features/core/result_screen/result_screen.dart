import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/features/core/result_screen/result_screen_widgets/custom_progress_bar.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen(
      {super.key, required this.rankLists, required this.roomId});
  final List<List<Map<String, dynamic>>> rankLists;
  final String roomId;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final rank = ["A", "B", "C", "D", "F"];

  void updateRankLists(List rankLists) async {
    var myMap = {};
    for (var i = 0; i < rank.length; i++) {
      myMap[rank[i]] = rankLists[i];
    }
    CollectionReference room = FirebaseFirestore.instance.collection('Rooms');
    return room.doc(widget.roomId).update({"rankLists": myMap});
  }

  @override
  void initState() {
    updateRankLists(widget.rankLists);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final double sumVote =
    //     widget.result.length.toDouble() * (widget.result.length.toDouble() - 1);

    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          shape: const Border(bottom: BorderSide(color: whiteColor, width: 1)),
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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 35,
              color: whiteColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: widget.rankLists
              .map(
                (rankList) => Container(
                  height: rankList.length * 60,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: whiteColor, width: 2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Text(
                            rank[widget.rankLists.indexOf(rankList)],
                            style: const TextStyle(
                              color: whiteColor,
                              fontFamily: 'EBGaramond',
                              fontWeight: FontWeight.w700,
                              fontSize: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: rankList
                                  .map((item) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["name"],
                                            style: const TextStyle(
                                              color: whiteColor,
                                              fontFamily: 'EBGaramond',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            item["gmail"],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'EBGaramond',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(width: 10),
                            const VerticalDivider(
                              color: Colors.grey,
                              width: 3,
                              thickness: 2,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: rankList
                                  .map((item) => CustomProgressbar(
                                        width: (item["count"] * 2).toDouble(),
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
              )
              .toList(),
        ),
      ),
    );
  }
}
