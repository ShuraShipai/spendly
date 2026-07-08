import 'package:flutter/material.dart';

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
    final normalized = label.trim().toLowerCase();
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
