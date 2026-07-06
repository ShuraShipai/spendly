import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/constants/auth_constants.dart';

class UserPreferencesData {
  const UserPreferencesData({
    required this.themeMode,
    required this.currencyCode,
    required this.weekStartsOn,
    required this.budgetAlertsEnabled,
    this.defaultDashboardPeriod = 'today',
  });

  final String themeMode;
  final String currencyCode;
  final String weekStartsOn;
  final bool budgetAlertsEnabled;
  final String defaultDashboardPeriod;

  factory UserPreferencesData.fromMap(Map<String, dynamic> map) {
    return UserPreferencesData(
      themeMode: map['themeMode'] as String? ?? 'system',
      currencyCode: map['currencyCode'] as String? ?? 'INR',
      weekStartsOn: map['weekStartsOn'] as String? ?? 'monday',
      budgetAlertsEnabled: map['budgetAlertsEnabled'] as bool? ?? true,
      defaultDashboardPeriod:
          map['defaultDashboardPeriod'] as String? ?? 'today',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'themeMode': themeMode,
      'currencyCode': currencyCode,
      'weekStartsOn': weekStartsOn,
      'budgetAlertsEnabled': budgetAlertsEnabled,
      'defaultDashboardPeriod': defaultDashboardPeriod,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class UserBudgetData {
  const UserBudgetData({
    required this.monthlyBudgetCents,
    required this.categoryBudgetCents,
  });

  final int monthlyBudgetCents;
  final Map<String, int> categoryBudgetCents;

  factory UserBudgetData.fromMap(Map<String, dynamic> map) {
    final rawCategoryBudgets = map['categoryBudgetCents'];
    return UserBudgetData(
      monthlyBudgetCents: map['monthlyBudgetCents'] as int? ?? 0,
      categoryBudgetCents: rawCategoryBudgets is Map
          ? rawCategoryBudgets.map(
              (key, value) => MapEntry(key.toString(), value as int? ?? 0),
            )
          : const {},
    );
  }

  Map<String, Object?> toMap() {
    return {
      'monthlyBudgetCents': monthlyBudgetCents,
      'categoryBudgetCents': categoryBudgetCents,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class SettingsFirestoreService {
  SettingsFirestoreService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  SettingsFirestoreService.memory() : firestore = null;

  final FirebaseFirestore? firestore;
  final Map<String, UserPreferencesData> _memoryPreferences = {};
  final Map<String, UserBudgetData> _memoryBudgets = {};

  bool get _usesMemory => firestore == null;

  DocumentReference<Map<String, dynamic>> _settingDoc(
    String uid,
    String docId,
  ) {
    return firestore!
        .collection(AuthConstants.usersCollection)
        .doc(uid)
        .collection('settings')
        .doc(docId);
  }

  Future<UserPreferencesData?> loadPreferences(String uid) async {
    if (_usesMemory) {
      return _memoryPreferences[uid];
    }

    final doc = await _settingDoc(uid, 'preferences').get();
    if (!doc.exists) {
      return null;
    }
    return UserPreferencesData.fromMap(doc.data() ?? {});
  }

  Future<void> savePreferences(
    String uid,
    UserPreferencesData preferences,
  ) async {
    if (_usesMemory) {
      _memoryPreferences[uid] = preferences;
      return;
    }

    await _settingDoc(
      uid,
      'preferences',
    ).set(preferences.toMap(), SetOptions(merge: true));
  }

  Future<UserBudgetData?> loadBudget(String uid) async {
    if (_usesMemory) {
      return _memoryBudgets[uid];
    }

    final doc = await _settingDoc(uid, 'budget').get();
    if (!doc.exists) {
      return null;
    }
    return UserBudgetData.fromMap(doc.data() ?? {});
  }

  Future<void> saveBudget(String uid, UserBudgetData budget) async {
    if (_usesMemory) {
      _memoryBudgets[uid] = budget;
      return;
    }

    await _settingDoc(
      uid,
      'budget',
    ).set(budget.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteSettings(String uid) async {
    if (_usesMemory) {
      _memoryPreferences.remove(uid);
      _memoryBudgets.remove(uid);
      return;
    }

    final settings = await firestore!
        .collection(AuthConstants.usersCollection)
        .doc(uid)
        .collection('settings')
        .get();
    final batch = firestore!.batch();
    for (final doc in settings.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
