import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/common_widgets/custom_appbar.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:pyramid_game/src/features/core/result_screen/result_screen.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});
  final auth = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: CustomAppBar(
          isCenter: true,
          backgroundColor: whiteColor,
          iconColor: primaryColor,
          shape:
              const Border(bottom: BorderSide(color: primaryColor, width: 1)),
          title: Text(
            "HISTORY".tr,
            style: const TextStyle(
              color: primaryColor,
              fontFamily: 'EBGaramond',
              fontWeight: FontWeight.w700,
              fontSize: 30,
              letterSpacing: 5,
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(auth!.email)
              .collection("History")
              .snapshots(),
          builder: (context, snapshot) {
            final documents = snapshot.data?.docs;
            if (snapshot.hasData) {
              return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: documents?.length,
                  itemBuilder: (context, index) {
                    final document = documents?[index];
                    // Lấy timestamp từ Firestore và chuyển thành DateTime
                    final timestamp = document?['createdAt'] as Timestamp;
                    final dateTime = timestamp.toDate();
                    // Định dạng ngày/tháng/năm
                    final formattedDate =
                        DateFormat('dd-MM-yyyy').format(dateTime);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        onTap: () {
                          Get.to(() => ResultScreen(
                                roomId: document!.id,
                                type: "watchHistory",
                              ));
                        },
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.home_outlined),
                                const SizedBox(width: 10),
                                Text(
                                  "${document?.id}",
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontFamily: 'EBGaramond',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.track_changes),
                                const SizedBox(width: 10),
                                Text(
                                  "${document?["title"]}",
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontFamily: 'EBGaramond',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_2_outlined),
                                const SizedBox(width: 10),
                                Text(
                                  "${document?["numberOfPlayers"]}",
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontFamily: 'EBGaramond',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.alarm),
                                const SizedBox(width: 10),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontFamily: 'EBGaramond',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          size: 50,
                        ),
                      ),
                    );
                  });
            } else if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error ${snapshot.error}"),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
