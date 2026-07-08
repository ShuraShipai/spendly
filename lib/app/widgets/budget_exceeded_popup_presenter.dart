import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/settings/providers/budget_alert_provider.dart';
import '../../features/settings/screens/category_budgets_screen.dart';

import '../../features/settings/widgets/budget_alert_card.dart' as alert_card;
import '../app_route_tracker.dart';
import '../app_routes.dart';

enum _BudgetAlertAction { adjustBudget, viewBudget }

class BudgetExceededPopupPresenter extends StatefulWidget {
  const BudgetExceededPopupPresenter({
    required this.child,
    required this.navigatorKey,
    required this.routeTracker,
    super.key,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final AppRouteTracker routeTracker;

  @override
  State<BudgetExceededPopupPresenter> createState() =>
      _BudgetExceededPopupPresenterState();
}

class _BudgetExceededPopupPresenterState
    extends State<BudgetExceededPopupPresenter> {
  String? _visibleAlertId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleAlert(context.watch<BudgetAlertProvider>().pendingAlert);
  }

  @override
  void didUpdateWidget(covariant BudgetExceededPopupPresenter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleAlert(context.read<BudgetAlertProvider>().pendingAlert);
  }

  void _scheduleAlert(BudgetExceededAlert? alert) {
    if (alert == null || _visibleAlertId == alert.id) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _visibleAlertId != null) {
        return;
      }

      final pendingAlert = context.read<BudgetAlertProvider>().pendingAlert;
      if (pendingAlert == null) {
        return;
      }
      _showAlert(pendingAlert);
    });
  }

  Future<void> _showAlert(BudgetExceededAlert alert) async {
    _visibleAlertId = alert.id;
    final navigatorContext = widget.navigatorKey.currentContext;
    if (navigatorContext == null) {
      _visibleAlertId = null;
      return;
    }

    final action = await showDialog<_BudgetAlertAction>(
      context: navigatorContext,
      barrierDismissible: true,
      builder: (context) => _BudgetExceededDialog(alert: alert),
    );

    if (!mounted) {
      return;
    }

    context.read<BudgetAlertProvider>().markAlertShown(alert.id);
    _visibleAlertId = null;

    if (action == _BudgetAlertAction.adjustBudget) {
      _openBudgetEditor(alert);
    } else if (action == _BudgetAlertAction.viewBudget) {
      _viewBudget();
    }

    _scheduleAlert(context.read<BudgetAlertProvider>().pendingAlert);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  bool get _isOnBudgetsScreen {
    return widget.routeTracker.currentRouteName == AppRoutes.categoryBudgets;
  }

  void _viewBudget() {
    if (_isOnBudgetsScreen) {
      return;
    }

    widget.navigatorKey.currentState?.pushNamed(AppRoutes.categoryBudgets);
  }

  void _openBudgetEditor(BudgetExceededAlert alert) {
    final request = alert.type == BudgetExceededAlertType.overall
        ? const BudgetEditorRequest.overall()
        : BudgetEditorRequest.category(alert.category!.id);
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    if (_isOnBudgetsScreen) {
      navigator.pushReplacementNamed(
        AppRoutes.categoryBudgets,
        arguments: request,
      );
      return;
    }

    navigator.pushNamed(AppRoutes.categoryBudgets, arguments: request);
  }
}

class _BudgetExceededDialog extends StatelessWidget {
  const _BudgetExceededDialog({required this.alert});

  final BudgetExceededAlert alert;

  @override
  Widget build(BuildContext context) {
    final progress = alert.budget <= 0
        ? 1.0
        : (alert.spent / alert.budget).clamp(0.0, 1.0);
    final severity = alert.severity == BudgetAlertSeverity.exceeded
        ? alert_card.BudgetAlertSeverity.exceeded
        : alert_card.BudgetAlertSeverity.warning;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          alert_card.BudgetAlertCard(
            severity: severity,
            title: alert.title,
            message: alert.message,
            progress: progress,
            onAdjustBudget: () =>
                Navigator.of(context).pop(_BudgetAlertAction.adjustBudget),
            onViewExpenses: alert.severity == BudgetAlertSeverity.exceeded
                ? () => Navigator.of(context).pop(_BudgetAlertAction.viewBudget)
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.inkMuted),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}
