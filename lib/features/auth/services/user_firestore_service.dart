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
}
