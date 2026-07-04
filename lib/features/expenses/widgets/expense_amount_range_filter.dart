import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ExpenseAmountRangeFilter extends StatelessWidget {
  const ExpenseAmountRangeFilter({
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
    super.key,
  });

  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMOUNT RANGE',
          style: textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatAmount(values.start),
              style: textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            Text(
              _formatAmount(values.end),
              style: textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.mint,
            inactiveTrackColor: AppColors.line,
            overlayColor: AppColors.mint.withValues(alpha: 0.12),
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 8,
              elevation: 0,
              pressedElevation: 0,
            ),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            trackHeight: 5,
            thumbColor: Colors.white,
            valueIndicatorColor: AppColors.mintDark,
            valueIndicatorTextStyle: textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: RangeSlider(
            values: values,
            min: min,
            max: max,
            divisions: _divisions,
            labels: RangeLabels(
              _formatAmount(values.start),
              _formatAmount(values.end),
            ),
            onChanged: (nextValues) {
              onChanged(
                RangeValues(
                  nextValues.start.roundToDouble(),
                  nextValues.end.roundToDouble(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.round()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  int get _divisions {
    final rawDivisions = ((max - min) / 50).round();
    if (rawDivisions < 1) {
      return 1;
    }
    if (rawDivisions > 100) {
      return 100;
    }
    return rawDivisions;
  }
}
