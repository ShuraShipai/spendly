import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/models/expense_category.dart';
import '../providers/settings_provider.dart';
import '../widgets/add_category_sheet.dart';
import '../widgets/category_management_list.dart';
import '../widgets/destructive_confirmation_dialog.dart';
import '../widgets/settings_section_header.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _loadedCategoryUserId;
  var _hasLoadedCategories = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthProvider>().user?.uid;
    if (_hasLoadedCategories && _loadedCategoryUserId == uid) {
      return;
    }

    _loadedCategoryUserId = uid;
    _hasLoadedCategories = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(context.read<SettingsProvider>().loadCategories(uid));
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final categories = settingsProvider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            SettingsSectionHeader(
              title: 'CATEGORIES',
              actionLabel: 'Add',
              onAction: () => _showAddCategorySheet(authProvider.user?.uid),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (settingsProvider.isLoadingCategories) ...[
              const LinearProgressIndicator(minHeight: 3),
              const SizedBox(height: AppSpacing.sm),
            ],
            CategoryManagementList(
              categories: categories,
              onDeleteCategory: (category) =>
                  _confirmDeleteCategory(authProvider.user?.uid, category),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategorySheet(String? uid) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddCategorySheet(
        onSave: (label) {
          unawaited(
            context.read<SettingsProvider>().addCustomCategory(
              uid: uid,
              label: label,
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    String? uid,
    ExpenseCategory category,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => DestructiveConfirmationDialog(
        title: 'Delete ${category.label}?',
        message:
            'Existing expenses keep their category, but it is removed from future pickers.',
        confirmLabel: 'Delete',
      ),
    );

    if (shouldDelete ?? false) {
      if (!mounted) {
        return;
      }
      await context.read<SettingsProvider>().deleteCustomCategory(
        uid: uid,
        category: category,
      );
    }
  }
}
