import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_service.dart';
import '../models/app_user.dart';

class UserFirestoreService {
  UserFirestoreService({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestoreService.users;
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
}
