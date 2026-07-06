import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/auth_constants.dart';
import '../models/app_user.dart';

class UserFirestoreService {
  UserFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection(AuthConstants.usersCollection);
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) {
      return null;
    }
    return AppUser.fromFirestore(doc);
  }

  Future<void> createUser(AppUser user) {
    return _users
        .doc(user.uid)
        .set(user.toCreateMap(), SetOptions(merge: true));
  }

  Future<void> updateUserProfile({
    required String uid,
    required String? displayName,
    required String? photoUrl,
  }) {
    return _users.doc(uid).set({
      'displayName': displayName,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteUser(String uid) {
    return _users.doc(uid).delete();
  }

  Future<void> deleteKnownUserData(String uid) async {
    final userDoc = _users.doc(uid);
    for (final collectionId in [
      'expenses',
      'settings',
      'customCategories',
      'categories',
    ]) {
      final snapshot = await userDoc.collection(collectionId).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
