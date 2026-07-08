import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_providers.dart';
import 'app_route_tracker.dart';
import 'app_routes.dart';
import 'app_theme.dart';
import 'providers/app_state_provider.dart';
import 'widgets/budget_exceeded_popup_presenter.dart';

class SpendlyApp extends StatelessWidget {
  const SpendlyApp({super.key});

  static final _navigatorKey = GlobalKey<NavigatorState>();
  static final _routeTracker = AppRouteTracker();

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Spendly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: appState.themeMode,
            navigatorKey: _navigatorKey,
            navigatorObservers: [_routeTracker],
            initialRoute: AppRoutes.authGate,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            builder: (context, child) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: BudgetExceededPopupPresenter(
                  navigatorKey: _navigatorKey,
                  routeTracker: _routeTracker,
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
