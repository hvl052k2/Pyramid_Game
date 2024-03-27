import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        appBar: AppBar(
          backgroundColor: whiteColor,
          title: const Text(
            "HISTORY",
            style: TextStyle(
              color: primaryColor,
              fontFamily: 'EBGaramond',
              fontWeight: FontWeight.w700,
              fontSize: 30,
              letterSpacing: 5,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 35,
              color: primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => ResultScreen(
                                roomId: document!.id,
                                type: "watchHistory",
                              ),
                            ),
                          );
                        },
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Id: ${document?.id}"),
                            Text("Title: ${document?["title"]}"),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Number of players: ${document?["numberOfPlayers"]}",
                            ),
                            Text("Created at: $formattedDate"),
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
