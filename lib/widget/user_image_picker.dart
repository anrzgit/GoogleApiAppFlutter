import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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

  pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.camera,
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

  uploadVideoToFireSrore(File fileToUpload) async {
    print("video received in uploadVideoToFireSrore $fileToUpload ");
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      final picStorageRef = FirebaseStorage.instance
          .ref()
          .child('cover_video')
          .child(
              '${currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.mp4');

      print(4444);

      //to upload the file
      await picStorageRef.putFile(fileToUpload);
      //to get the url of the uploaded file
      await picStorageRef.getDownloadURL().then((value) {
        //to update the url in the firestore
        FirebaseFirestore.instance
            .collection('google_users')
            .doc(currentUser.uid)
            .update({
          'videos':
              FieldValue.arrayUnion([value]) // add video URL to videos array
        });
      });
      print('uploaded video to firestore');
    } catch (e) {
      print('error in uploadVideoToFireSrore ${e.toString()}');
    }
  }
}
