import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PickImageWidget {
  pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  uploadImageToFireSrore(File fileToUpload) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final picStorageRef = FirebaseStorage.instance
        .ref()
        .child('cover_pic')
        .child('${currentUser!.uid}.jpg');

    //to upload the file
    await picStorageRef.putFile(fileToUpload);
    //to get the url of the uploaded file
    await picStorageRef.getDownloadURL().then((value) {
      //to update the url in the firestore
      FirebaseFirestore.instance
          .collection('google_users')
          .doc(currentUser.uid)
          .update({'cover_pic': value});
    });
  }
}
