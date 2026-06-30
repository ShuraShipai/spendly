import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final displayName = user?.displayName;
    final firstName = displayName == null || displayName.isEmpty
        ? null
        : displayName.split(' ').first;
    final greeting = firstName == null ? 'Hi there' : 'Hi $firstName';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          104,
        ),
        children: [
          _HomeHeader(greeting: greeting, displayName: displayName),
          const SizedBox(height: AppSpacing.md),
          const _PeriodSelector(),
          const SizedBox(height: AppSpacing.xl),
          const _WeeklySpendCard(),
          const SizedBox(height: AppSpacing.xxl),
          const _EmptyStateCard(),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.greeting, required this.displayName});

  final String greeting;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final initial = displayName == null || displayName!.isEmpty
        ? 'S'
        : displayName![0].toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: Theme.of(context).textTheme.bodySmall),
              Text(
                'Good evening',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB0A4F5), Color(0xFF8C7DF0)],
            ),
          ),
          child: SizedBox.square(
            dimension: 36,
            child: Center(
              child: Text(
                initial,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.card;
    final borderColor = isDark ? AppColors.darkInkMuted : AppColors.line;

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: borderColor.withValues(alpha: 0.28)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PeriodChip(label: 'Today'),
              _PeriodChip(label: 'Week', selected: true),
              _PeriodChip(label: 'Month'),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.mint : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : AppColors.inkSubtle,
          ),
        ),
      ),
    );
  }
}

class _WeeklySpendCard extends StatelessWidget {
  const _WeeklySpendCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [AppColors.darkSurface, Color(0xFF16221F)]
        : const [AppColors.mintTint, AppColors.card];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.mintTintStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Text(
              'SPENT THIS WEEK',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.inkSubtle),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('₹0', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add expenses to see your total grow',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _PennyEmptyMark(),
        const SizedBox(height: AppSpacing.sm),
        Text('No expenses yet', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tap the + button to log your first one. It takes 10 seconds.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PennyEmptyMark extends StatelessWidget {
  const _PennyEmptyMark();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.mintTint;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        shape: BoxShape.circle,
        boxShadow: isDark ? null : AppShadows.soft,
      ),
      child: SizedBox.square(
        dimension: 96,
        child: Center(
          child: Text(
            '₹',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.mint),
          ),
        ),
      ),
    );
  }
}
