import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

class MonthlyBudgetActionsSheet extends StatelessWidget {
  const MonthlyBudgetActionsSheet({
    required this.currentBudget,
    required this.onEditLimit,
    required this.onResetLimit,
    super.key,
  });

  final double currentBudget;
  final VoidCallback onEditLimit;
  final VoidCallback onResetLimit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly budget',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            if (currentBudget <= 0)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set limit'),
                onTap: onEditLimit,
              )
            else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Edit limit'),
                onTap: onEditLimit,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reset to unlimited'),
                onTap: onResetLimit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
