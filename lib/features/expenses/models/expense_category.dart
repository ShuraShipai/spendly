import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
    String? iconKey,
  }) : iconKey = iconKey ?? id;

  final String id;
  final String label;
  final Color color;
  final IconData icon;
  final String iconKey;

  static const food = ExpenseCategory(
    id: 'food',
    label: 'Food',
    color: AppColors.food,
    icon: Icons.restaurant_rounded,
  );
  static const groceries = ExpenseCategory(
    id: 'groceries',
    label: 'Groceries',
    color: AppColors.groceries,
    icon: Icons.shopping_basket_rounded,
  );
  static const transport = ExpenseCategory(
    id: 'transport',
    label: 'Transport',
    color: AppColors.transport,
    icon: Icons.directions_car_rounded,
  );
  static const shopping = ExpenseCategory(
    id: 'shopping',
    label: 'Shopping',
    color: AppColors.shopping,
    icon: Icons.shopping_bag_rounded,
  );
  static const bills = ExpenseCategory(
    id: 'bills',
    label: 'Bills',
    color: AppColors.bills,
    icon: Icons.receipt_long_rounded,
  );
  static const rent = ExpenseCategory(
    id: 'rent',
    label: 'Rent',
    color: AppColors.rent,
    icon: Icons.home_rounded,
  );
  static const health = ExpenseCategory(
    id: 'health',
    label: 'Health',
    color: AppColors.health,
    icon: Icons.favorite_rounded,
  );
  static const fun = ExpenseCategory(
    id: 'fun',
    label: 'Fun',
    color: AppColors.entertainment,
    icon: Icons.play_arrow_rounded,
  );
  static const travel = ExpenseCategory(
    id: 'travel',
    label: 'Travel',
    color: AppColors.travel,
    icon: Icons.near_me_rounded,
  );

  static const quickDefaults = [food, groceries, transport];
  static const defaults = [
    food,
    groceries,
    transport,
    shopping,
    bills,
    rent,
    health,
    fun,
    travel,
  ];

  static ExpenseCategory byId(
    String id, {
    String? labelSnapshot,
    int? colorArgbSnapshot,
    String? iconKeySnapshot,
  }) {
    for (final category in defaults) {
      if (category.id == id) {
        return category;
      }
    }

    return ExpenseCategory(
      id: id,
      label: labelSnapshot == null || labelSnapshot.isEmpty
          ? id
          : labelSnapshot,
      color: Color(colorArgbSnapshot ?? AppColors.mint.toARGB32()),
      icon: CustomCategoryIconResolver.iconFor(
        iconKeySnapshot ??
            CustomCategoryIconResolver.iconKeyFor(labelSnapshot ?? id),
      ),
      iconKey:
          iconKeySnapshot ??
          CustomCategoryIconResolver.iconKeyFor(labelSnapshot ?? id),
    );
  }

  bool get isCustom => !defaults.any((category) => category.id == id);

  bool hasSameLabel(String otherLabel) {
    return normalizedLabel(label) == normalizedLabel(otherLabel);
  }

  static String normalizedLabel(String label) {
    return label.trim().toLowerCase();
  }

  static String customIdFor(String label) {
    final slug = label
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    return 'custom-${slug.isEmpty ? 'category' : slug}';
  }

  factory ExpenseCategory.custom({
    required String label,
    required Color color,
    Iterable<ExpenseCategory> existingCategories = const [],
  }) {
    final trimmedLabel = label.trim();
    final iconKey = CustomCategoryIconResolver.iconKeyFor(
      trimmedLabel,
      usedIconKeys: existingCategories
          .where((category) => category.isCustom)
          .map((category) => category.iconKey),
    );

    return ExpenseCategory(
      id: customIdFor(trimmedLabel),
      label: trimmedLabel,
      color: color,
      icon: CustomCategoryIconResolver.iconFor(iconKey),
      iconKey: iconKey,
    );
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String;
    final label = map['label'] as String;
    final iconKey =
        map['iconKey'] as String? ??
        (ExpenseCategory.defaults.any((category) => category.id == id)
            ? id
            : CustomCategoryIconResolver.iconKeyFor(label));

    return ExpenseCategory(
      id: id,
      label: label,
      color: Color(map['color'] as int),
      icon: CustomCategoryIconResolver.iconFor(iconKey),
      iconKey: iconKey,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'label': label,
      'color': color.toARGB32(),
      'colorArgb': color.toARGB32(),
      'iconKey': iconKey,
      'isSystem': !isCustom,
      'isQuick': quickDefaults.any((category) => category.id == id),
      'isArchived': false,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CustomCategoryIconResolver {
  const CustomCategoryIconResolver._();

  static const _fallbackIconKeys = [
    'star',
    'work',
    'school',
    'fitness',
    'savings',
    'celebration',
    'gaming',
    'palette',
    'music',
    'park',
  ];

  static String iconKeyFor(
    String label, {
    Iterable<String> usedIconKeys = const [],
  }) {
    final normalized = ExpenseCategory.normalizedLabel(label);
    for (final entry in _keywordIconKeys.entries) {
      if (entry.key.any(normalized.contains)) {
        return entry.value;
      }
    }

    final usedFallbackKeys = usedIconKeys
        .where(_fallbackIconKeys.contains)
        .toSet();
    for (final iconKey in _fallbackIconKeys) {
      if (!usedFallbackKeys.contains(iconKey)) {
        return iconKey;
      }
    }

    return _fallbackIconKeys[_stableIndex(
      normalized,
      _fallbackIconKeys.length,
    )];
  }

  static IconData iconFor(String iconKey) {
    return _iconsByKey[iconKey] ?? Icons.sell_rounded;
  }

  static int _stableIndex(String value, int length) {
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash % length;
  }

  static final Map<List<String>, String> _keywordIconKeys = {
    ['water', 'h2o']: 'water',
    ['coffee', 'cafe', 'tea']: 'coffee',
    ['pet', 'pets', 'dog', 'cat']: 'pets',
    ['medicine', 'medical', 'health', 'doctor', 'pharmacy']: 'medical',
    ['travel', 'trip', 'flight', 'hotel', 'vacation']: 'travel',
    ['electricity', 'electric', 'power']: 'bolt',
    ['bill', 'bills', 'utility', 'utilities']: 'bill',
  };

  static const Map<String, IconData> _iconsByKey = {
    'water': Icons.water_drop_rounded,
    'coffee': Icons.coffee_rounded,
    'pets': Icons.pets_rounded,
    'medical': Icons.medical_services_rounded,
    'travel': Icons.flight_takeoff_rounded,
    'bolt': Icons.bolt_rounded,
    'bill': Icons.receipt_long_rounded,
    'star': Icons.star_rounded,
    'work': Icons.work_rounded,
    'school': Icons.school_rounded,
    'fitness': Icons.fitness_center_rounded,
    'savings': Icons.savings_rounded,
    'celebration': Icons.celebration_rounded,
    'gaming': Icons.sports_esports_rounded,
    'palette': Icons.palette_rounded,
    'music': Icons.music_note_rounded,
    'park': Icons.park_rounded,
  };
}
