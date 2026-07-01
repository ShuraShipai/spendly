import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/constants/auth_constants.dart';
import '../constants/expense_constants.dart';
import '../models/expense_category.dart';

class CustomCategoryService {
  CustomCategoryService({this._firestore});

  final FirebaseFirestore? _firestore;
  final Map<String, List<ExpenseCategory>> _memoryStore = {};

  bool get _usesMemory => _firestore == null;

  CollectionReference<Map<String, dynamic>> _customCategories(String uid) {
    return _firestore!
        .collection(AuthConstants.usersCollection)
        .doc(uid)
        .collection(ExpenseConstants.customCategoriesCollection);
  }

  Future<List<ExpenseCategory>> loadCustomCategories(String uid) async {
    if (_usesMemory) {
      return List<ExpenseCategory>.unmodifiable(_memoryStore[uid] ?? const []);
    }

    final snapshot = await _customCategories(uid).get();
    final categories =
        snapshot.docs
            .map((doc) => ExpenseCategory.fromMap(doc.data()))
            .where((category) => category.isCustom)
            .toList()
          ..sort((a, b) => a.label.compareTo(b.label));

    return categories;
  }

  Future<void> saveCustomCategory(String uid, ExpenseCategory category) async {
    if (!category.isCustom) {
      return;
    }

    if (_usesMemory) {
      final categories = _memoryStore.putIfAbsent(uid, () => []);
      final existingIndex = categories.indexWhere(
        (stored) => stored.id == category.id,
      );
      if (existingIndex >= 0) {
        categories[existingIndex] = category;
      } else {
        categories.add(category);
      }
      categories.sort((a, b) => a.label.compareTo(b.label));
      return;
    }

    await _customCategories(
      uid,
    ).doc(category.id).set(category.toMap(), SetOptions(merge: true));
  }
}
