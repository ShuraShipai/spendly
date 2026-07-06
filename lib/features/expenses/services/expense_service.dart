import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/constants/auth_constants.dart';
import '../constants/expense_constants.dart';
import '../models/expense_entry.dart';

class ExpenseService {
  ExpenseService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  ExpenseService.memory() : firestore = null;

  final FirebaseFirestore? firestore;
  final Map<String, List<ExpenseEntry>> _memoryStore = {};
  final Map<String, StreamController<List<ExpenseEntry>>> _memoryStreams = {};

  bool get _usesMemory => firestore == null;

  CollectionReference<Map<String, dynamic>> _expenses(String uid) {
    return firestore!
        .collection(AuthConstants.usersCollection)
        .doc(uid)
        .collection(ExpenseConstants.expensesCollection);
  }

  Stream<List<ExpenseEntry>> watchActiveExpenses(String uid) {
    if (_usesMemory) {
      return _memoryController(uid).stream;
    }

    return _expenses(uid)
        .orderBy('occurredAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((doc) => (doc.data()['status'] as String?) != 'deleted')
              .map(ExpenseEntry.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<ExpenseEntry> createExpense(String uid, ExpenseEntry expense) async {
    if (_usesMemory) {
      final id = expense.id.isEmpty
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : expense.id;
      final stored = expense.copyWith(id: id);
      final expenses = _memoryStore.putIfAbsent(uid, () => []);
      expenses.insert(0, stored);
      _emitMemory(uid);
      return stored;
    }

    final doc = _expenses(uid).doc();
    final stored = expense.copyWith(id: doc.id);
    await doc.set(stored.toFirestoreCreateMap());
    return stored;
  }

  Future<void> updateExpense(String uid, ExpenseEntry expense) async {
    if (_usesMemory) {
      final expenses = _memoryStore.putIfAbsent(uid, () => []);
      final index = expenses.indexWhere((entry) => entry.id == expense.id);
      if (index >= 0) {
        expenses[index] = expense;
      }
      _emitMemory(uid);
      return;
    }

    await _expenses(uid)
        .doc(expense.id)
        .set(expense.toFirestoreUpdateMap(), SetOptions(merge: true));
  }

  Future<void> softDeleteExpense(String uid, String expenseId) async {
    if (_usesMemory) {
      final expenses = _memoryStore[uid];
      expenses?.removeWhere((expense) => expense.id == expenseId);
      _emitMemory(uid);
      return;
    }

    await _expenses(uid).doc(expenseId).set({
      'status': 'deleted',
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> restoreExpense(String uid, ExpenseEntry expense) async {
    if (_usesMemory) {
      final expenses = _memoryStore.putIfAbsent(uid, () => []);
      if (!expenses.any((entry) => entry.id == expense.id)) {
        expenses.insert(0, expense);
      }
      _emitMemory(uid);
      return;
    }

    await _expenses(uid).doc(expense.id).set({
      ...expense.toFirestoreUpdateMap(),
      'status': 'active',
      'deletedAt': null,
    }, SetOptions(merge: true));
  }

  Future<void> deleteAllExpenses(String uid) async {
    if (_usesMemory) {
      _memoryStore.remove(uid);
      _emitMemory(uid);
      return;
    }

    final snapshot = await _expenses(uid).get();
    final batch = firestore!.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  StreamController<List<ExpenseEntry>> _memoryController(String uid) {
    return _memoryStreams.putIfAbsent(uid, () {
      final controller = StreamController<List<ExpenseEntry>>.broadcast(
        onListen: () => _emitMemory(uid),
      );
      return controller;
    });
  }

  void _emitMemory(String uid) {
    final controller = _memoryStreams[uid];
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(List<ExpenseEntry>.unmodifiable(_memoryStore[uid] ?? []));
  }
}
