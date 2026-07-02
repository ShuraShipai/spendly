import 'package:flutter/material.dart';

class DeleteExpenseSheetActionButton extends StatelessWidget {
  const DeleteExpenseSheetActionButton({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onPressed,
    this.boxShadow,
    super.key,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: boxShadow,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontSize: 15,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
