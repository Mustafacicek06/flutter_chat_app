import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chat_app/services/storage_base.dart';

class FirebaseStorageService implements StorageBase {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  @override
  Future<String> uploadFile(
      String userID, String fileType, File toBeUploadFile) async {
    Reference ref = _firebaseStorage
        .ref()
        .child(userID)
        .child(fileType)
        .child("profil_foto.png");

    var uploadTask = await ref.putFile(toBeUploadFile);

    var url = await uploadTask.ref.getDownloadURL();

    return url;

    // var uploadTask = _firebaseStorage
    //     .ref()
    //     .child(
    //         "${DateTime.now().millisecondsSinceEpoch}, ${toBeUploadFile.path.split('.').last}")
    //     .putFile(toBeUploadFile);

    // uploadTask.snapshotEvents.listen((event) {});

    // var storageRef = await uploadTask.whenComplete(() {});

    // return await storageRef.ref.getDownloadURL();
  }
}
