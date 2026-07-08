import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_constants.dart';
import '../../../core/firebase/firestore_service.dart';
import '../models/expense_category.dart';

class CustomCategoryService {
  CustomCategoryService({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  CustomCategoryService.memory() : _firestoreService = null;

  final FirestoreService? _firestoreService;
  final Map<String, List<ExpenseCategory>> _memoryStore = {};

  bool get _usesMemory => _firestoreService == null;

  CollectionReference<Map<String, dynamic>> _customCategories(String uid) {
    return _firestoreService!.userCollection(
      uid,
      FirestoreConstants.customCategoriesCollection,
    );
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

  Future<void> deleteCustomCategory(String uid, String categoryId) async {
    if (_usesMemory) {
      final categories = _memoryStore[uid];
      if (categories == null) {
        return;
      }
      categories.removeWhere((category) => category.id == categoryId);
      return;
    }

    await _customCategories(uid).doc(categoryId).delete();
  }

  Future<void> deleteAllCustomCategories(String uid) async {
    if (_usesMemory) {
      _memoryStore.remove(uid);
      return;
    }

    final snapshot = await _customCategories(uid).get();
    final batch = _firestoreService!.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
