import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/budget_alert_provider.dart';
import 'budget_notification_tile.dart';

class BudgetNotificationsList extends StatelessWidget {
  const BudgetNotificationsList({
    required this.notifications,
    required this.onNotificationTap,
    super.key,
  });

  final List<BudgetExceededAlert> notifications;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < notifications.length; index++) ...[
          BudgetNotificationTile(
            severity: _tileSeverityFor(notifications[index].severity),
            title: notifications[index].title,
            message: notifications[index].message,
            timeLabel: notifications[index].timeLabel,
            isUnread: notifications[index].isUnread,
            onTap: onNotificationTap,
          ),
          if (index != notifications.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  BudgetNotificationSeverity _tileSeverityFor(BudgetAlertSeverity severity) {
    return switch (severity) {
      BudgetAlertSeverity.exceeded => BudgetNotificationSeverity.exceeded,
      BudgetAlertSeverity.warning => BudgetNotificationSeverity.warning,
    };
  }
}
