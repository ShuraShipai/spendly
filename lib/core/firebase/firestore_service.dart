import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_constants.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get users {
    return firestore.collection(FirestoreConstants.usersCollection);
  }

  DocumentReference<Map<String, dynamic>> userDocument(String uid) {
    return users.doc(uid);
  }

  CollectionReference<Map<String, dynamic>> userCollection(
    String uid,
    String collection,
  ) {
    return userDocument(uid).collection(collection);
  }

  DocumentReference<Map<String, dynamic>> userSettingsDocument(
    String uid,
    String document,
  ) {
    return userCollection(
      uid,
      FirestoreConstants.settingsCollection,
    ).doc(document);
  }

  WriteBatch batch() {
    return firestore.batch();
  }
}
