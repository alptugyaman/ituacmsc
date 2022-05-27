import 'dart:io';

import 'package:cloud/image_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static Future<UploadTask?> uploadFile(String destination, File file) async {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      if (kDebugMode) print(e);
      return null;
    }
  }

  static Future<void> saveImageFileDetails(ImageModel images) async {
    //* Firebase consoleda oluşturduğumuz collectionı girmemiz gerekiyor.
    final firestore = FirebaseFirestore.instance.collection('images').doc();
    firestore.set(images.toJson());
  }

  static Stream<QuerySnapshot<ImageModel>> getImageModel() {
    final images = FirebaseFirestore.instance
        //* Firebase consoleda oluşturduğumuz collectionı girmemiz gerekiyor.
        .collection('images')
        //* order çekeceğimiz alan.
        .orderBy('uploadTime', descending: true)
        .withConverter<ImageModel>(
          fromFirestore: (snapshots, _) =>
              ImageModel.fromJson(snapshots.data()!),
          toFirestore: (images, _) => images.toJson(),
        );

    return images.snapshots();
  }
}
