import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';
import 'package:pyramid_game/src/constants/image_strings.dart';
import 'package:pyramid_game/src/constants/sizes.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final double coverHeight = 250;
  final double profileHeight = 144;
  Uint8List? _avatarImage, _wallImage;
  File? selectedAvatarImage, selectedWallImage;
  String? avatarImageUrl, wallImageUrl;
  bool isLoading = false;

  Future uploadImageToFirebase() async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref();
    // avatar image
    if (selectedAvatarImage != null) {
      final avatarRef = ref.child('avatar_images/$fileName.png');
      await avatarRef.putFile(selectedAvatarImage!);
      avatarImageUrl = await avatarRef.getDownloadURL();
      selectedAvatarImage = null;
      _avatarImage = null;
    }

    // wall image
    if (selectedWallImage != null) {
      final wallRef = ref.child('wall_images/$fileName.png');
      await wallRef.putFile(selectedWallImage!);
      wallImageUrl = await wallRef.getDownloadURL();
      selectedWallImage = null;
      _wallImage = null;
    }
  }

  Future updateUser() {
    CollectionReference user = FirebaseFirestore.instance.collection('Users');
    return user.doc(auth.currentUser!.email).update({
      'userName': nameController.text,
      'phoneNumber': phoneController.text,
      'bio': bioController.text,
      'avatarImage': avatarImageUrl,
      'wallImage': wallImageUrl,
    }).then((value) {
      showSnackBar("Update sucessfully", true);
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    });
  }

  void showUpdateDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Update Profile",
          style: TextStyle(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          "Are you sure to update profile?",
          textAlign: TextAlign.center,
        ),
        actions: [
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: whiteColor,
                      color: primaryColor,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.all(10.0),
                        ),
                        child: const Text(
                          'Cancle',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await uploadImageToFirebase();
                          updateUser();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.all(10.0),
                        ),
                        child: const Text(
                          'Ok',
                          style: TextStyle(color: whiteColor),
                        ),
                      ),
                    ],
                  );
          })
        ],
      ),
    );
  }

  void showSnackBar(String message, bool status) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            Icon(
              status ? Icons.done_rounded : Icons.info_rounded,
              color: whiteColor,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: whiteColor,
                fontFamily: 'EBGaramond',
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
          backgroundColor: status ? Colors.green : Colors.red,
        ),
      );

  Future _pickImageFromGallery(String type) async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      if (type == "wallImage") {
        selectedWallImage = File(returnImage.path);
        _wallImage = File(returnImage.path).readAsBytesSync();
      } else {
        selectedAvatarImage = File(returnImage.path);
        _avatarImage = File(returnImage.path).readAsBytesSync();
      }
    });

    if (context.mounted) Navigator.pop(context);
  }

  Future _pickImageFromCamera(String type) async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      if (type == "wallImage") {
        selectedWallImage = File(returnImage.path);
        _wallImage = File(returnImage.path).readAsBytesSync();
      } else {
        selectedAvatarImage = File(returnImage.path);
        _avatarImage = File(returnImage.path).readAsBytesSync();
      }
    });
    if (context.mounted) Navigator.pop(context);
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
                      onTap: () {
                        _pickImageFromCamera(type);
                      },
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
                      onTap: () {
                        _pickImageFromGallery(type);
                      },
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 35,
              color: whiteColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Edit profile",
            style: TextStyle(
              color: whiteColor,
              fontFamily: "EBGaramond",
              fontWeight: FontWeight.w500,
              fontSize: 30,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(auth.currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              nameController.text = userData["userName"];
              phoneController.text = userData["phoneNumber"];
              bioController.text = userData["bio"];
              avatarImageUrl = userData["avatarImage"];
              wallImageUrl = userData["wallImage"];
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: profileHeight / 2),
                        child: Container(
                          color: Colors.grey,
                          width: double.infinity,
                          height: coverHeight,
                          child: _wallImage != null
                              ? Image.memory(_wallImage!, fit: BoxFit.cover)
                              : userData["wallImage"] != null
                                  ? Image.network(
                                      userData["wallImage"],
                                      fit: BoxFit.cover,
                                    )
                                  : const Image(
                                      image: AssetImage(wallImage),
                                      fit: BoxFit.cover,
                                    ),
                        ),
                      ),
                      Positioned(
                        right: -20,
                        bottom: profileHeight / 2,
                        child: MaterialButton(
                          onPressed: () {
                            showImagePickerOption(context, "wallImage");
                          },
                          color: whiteColor,
                          padding: const EdgeInsets.all(8),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 25,
                          ),
                        ),
                      ),
                      Positioned(
                        top: coverHeight - profileHeight / 2,
                        child: Stack(
                          children: [
                            _avatarImage != null
                                ? CircleAvatar(
                                    radius: profileHeight / 2,
                                    backgroundImage: MemoryImage(_avatarImage!),
                                  )
                                : userData["avatarImage"] != null
                                    ? CircleAvatar(
                                        radius: profileHeight / 2,
                                        backgroundImage: NetworkImage(
                                            userData["avatarImage"]),
                                      )
                                    : CircleAvatar(
                                        // backgroundColor: Colors.grey,
                                        radius: profileHeight / 2,
                                        backgroundImage:
                                            const AssetImage(avatarImage),
                                      ),
                            Positioned(
                              right: -20,
                              bottom: 0,
                              child: MaterialButton(
                                onPressed: () {
                                  showImagePickerOption(context, "avatarImage");
                                },
                                color: whiteColor,
                                padding: const EdgeInsets.all(8),
                                shape: const CircleBorder(),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 25,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, top: 10),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Name",
                              style: TextStyle(color: whiteColor),
                            ),
                            TextField(
                              controller: nameController,
                              style: const TextStyle(color: whiteColor),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                prefixIconColor: whiteColor,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Phone",
                              style: TextStyle(color: whiteColor),
                            ),
                            TextField(
                              controller: phoneController,
                              style: const TextStyle(color: whiteColor),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.phone_android),
                                prefixIconColor: whiteColor,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Bio",
                              style: TextStyle(color: whiteColor),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: bioController,
                                style: const TextStyle(
                                  color: whiteColor,
                                ),
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showUpdateDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: primaryColor,
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                vertical: buttonHeight,
                              ),
                            ),
                            child: const Text(
                              'UPDATE',
                              style: TextStyle(
                                color: whiteColor,
                                fontFamily: 'EBGaramond',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
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
    );
  }
}
