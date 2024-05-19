import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/features/core/controllers/room_controller.dart';

class AttendersScreen extends StatefulWidget {
  final String roomId;
  const AttendersScreen({super.key, required this.roomId});

  @override
  State<AttendersScreen> createState() => _AttendersScreenState();
}

class _AttendersScreenState extends State<AttendersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final User? auth = FirebaseAuth.instance.currentUser;
  String _searchQuery = '';
  bool isAdmin = false;
  final roomController = Get.put(RoomController());

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> checkAdmin([String? email]) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection("Rooms")
          .doc(widget.roomId)
          .get();

      if (documentSnapshot.exists) {
        final adminEmail = documentSnapshot.data()?["admin"];
        if (adminEmail != null && adminEmail == auth?.email) {
          setState(() {
            isAdmin = true;
          });
        }
      }
    } catch (e) {
      print("Error checking admin: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    checkAdmin();
  }

  Future<void> modifyAttender(
      Map<String, dynamic> user, String collectionField, bool isAdd) async {
    try {
      await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          final docRef =
              FirebaseFirestore.instance.collection("Rooms").doc(widget.roomId);
          final docSnapshot = await transaction.get(docRef);

          if (!docSnapshot.exists) {
            throw Exception("Room does not exist");
          }

          final nameField = List<Map<String, dynamic>>.from(
              docSnapshot.data()?[collectionField] ?? []);
          if (isAdd) {
            nameField.add(user);
          } else {
            nameField.removeWhere((item) => item["gmail"] == user["gmail"]);
          }

          transaction.update(docRef, {collectionField: nameField});
        },
      );

      print(
          "${isAdd ? "Added to" : "Removed from"} $collectionField successfully!");
    } catch (e) {
      print("Error modifying attender: $e");
    }
  }

  void showInforDialog(BuildContext context, String titleText,
      String contentText, Map<String, dynamic> user, String type) {
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
                onPressed: () async {
                  Get.back();
                  switch (type) {
                    case "kick":
                      roomController.updateIsKickedOut(true);
                      await modifyAttender(user, "attenders", false);
                      roomController.updateIsKickedOut(false);
                      // Future.delayed(const Duration(seconds: 1), () {
                      //   roomController.updateIsKickedOut(false);
                      // });
                      break;
                    case "block":
                      roomController.updateIsKickedOut(true);
                      await modifyAttender(user, "attenders", false);
                      await modifyAttender(user, "blockedList", true);
                      roomController.updateIsKickedOut(false);
                      // Future.delayed(const Duration(seconds: 1), () {
                      //   roomController.updateIsKickedOut(false);
                      // });
                      break;
                    case "unblock":
                      modifyAttender(user, "blockedList", false);
                      break;
                  }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 35,
                color: primaryColor,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            centerTitle: true,
            backgroundColor: whiteColor,
            shape:
                const Border(bottom: BorderSide(color: primaryColor, width: 1)),
            title: Text(
              "ATTENDERS".tr,
              style: const TextStyle(
                color: primaryColor,
                fontFamily: 'EBGaramond',
                fontWeight: FontWeight.w700,
                fontSize: 30,
                letterSpacing: 3,
              ),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.person)),
                Tab(icon: Icon(Icons.person_off)),
              ],
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name or gmail'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Attenders Tab
                    buildAttenderList("attenders"),
                    // Blocked List Tab
                    buildAttenderList("blockedList"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAttenderList(String collectionField) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("Rooms")
          .doc(widget.roomId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final roomData = snapshot.data!.data() ?? {};
          final filteredList = _searchQuery.isEmpty
              ? List<Map<String, dynamic>>.from(roomData[collectionField] ?? [])
              : List<Map<String, dynamic>>.from(roomData[collectionField] ?? [])
                  .where((user) {
                  final name = user["name"].toLowerCase();
                  final email = user["gmail"].toLowerCase();
                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                }).toList();
          if (filteredList.isEmpty) {
            return Center(
              child: Text(
                "Empty List".tr,
                style: const TextStyle(
                  color: Colors.grey,
                  fontFamily: 'EBGaramond',
                  fontWeight: FontWeight.w500,
                  fontSize: 25,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  filteredList[index]["name"],
                  style: const TextStyle(
                    color: primaryColor,
                    fontFamily: 'EBGaramond',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  filteredList[index]["gmail"],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'EBGaramond',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                trailing: isAdmin
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (collectionField == "attenders") ...[
                            if (filteredList[index]["gmail"] ==
                                roomData["admin"]) ...[
                              Container()
                            ] else ...[
                              IconButton(
                                onPressed: () {
                                  showInforDialog(
                                    context,
                                    "Information".tr,
                                    "Are you sure to block this attender?".tr,
                                    filteredList[index],
                                    "block",
                                  );
                                },
                                icon: const Icon(Icons.block_flipped),
                              ),
                              IconButton(
                                onPressed: () {
                                  showInforDialog(
                                    context,
                                    "Information".tr,
                                    "Are you sure to kick this attender?".tr,
                                    filteredList[index],
                                    "kick",
                                  );
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ]
                          ] else ...[
                            IconButton(
                              onPressed: () {
                                showInforDialog(
                                  context,
                                  "Information".tr,
                                  "Unblock this attender?".tr,
                                  filteredList[index],
                                  "unblock",
                                );
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                          ]
                        ],
                      )
                    : (filteredList[index]["gmail"] == roomData["admin"])
                        ? const Icon(
                            Icons.admin_panel_settings,
                          )
                        : const Icon(
                            Icons.person_outline,
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
    );
  }
}
