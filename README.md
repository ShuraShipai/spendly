# Spendly

Spendly is a Flutter expense tracker for everyday budgeting. It helps users log expenses, review spending by day/week/month, manage budgets, create custom categories, receive budget alerts, and export CSV data.

The app uses Firebase Authentication for accounts, Cloud Firestore for user data, Provider for state management and dependency injection, and a feature-first Flutter architecture.

## Features

- Email/password authentication
- Sign up, login, sign out, forgot password, reset password, and email verification
- Editable profile details
- Account deletion flow with account-data cleanup after Firebase Auth deletion succeeds
- Home dashboard with period-based spending totals
- Today, week, and month dashboard period selection
- Recent expenses list
- Add expense flow with amount keypad, payment method, category picker, custom category creation, notes, and save confirmation
- Expense list with search, sorting, filters, amount range filtering, grouped list view, and detail navigation
- Edit expense flow with saved custom category support
- Soft delete and undo restore behavior
- Category management for custom categories
- Overall monthly budget
- Per-category budgets
- Budget warning/exceeded alerts
- Local notification support for budget thresholds
- Notifications screen for active budget alerts
- Settings for currency, week start, theme mode, budget alerts, categories, budgets, profile, exports, sign out, and delete account
- Insights screen with current-month summary, category breakdown, biggest expense, daily average, and monthly CSV export
- Settings export for the full expense history CSV
- Light/dark/system theme modes
- Shared design tokens for colors, spacing, radii, shadows, and text styles

## Tech Stack

- Flutter
- Dart
- Provider
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Flutter Local Notifications
- Google Fonts
- Material 3
- Flutter test framework

## State Management

Spendly uses `provider` as both the dependency injection layer and UI state layer.

- `AppProviders` is the composition root for services and providers.
- `Provider<T>` registers stateless services such as `AuthService`, `FirestoreService`, `ExpenseService`, and notification services.
- `ChangeNotifierProvider<T>` registers mutable state objects.
- `ChangeNotifierProxyProvider` binds providers to the active authenticated user.
- Widgets use `context.watch<T>()` when rendering state.
- Widgets use `context.read<T>()` inside callbacks.

Main providers:

- `AuthProvider`: auth status, current user, email verification, loading state, auth errors, profile updates, sign out, account deletion.
- `AppStateProvider`: theme mode, currency, week start, budget alert preference, user-bound preference loading/persistence.
- `ExpenseProvider`: active expense stream, local expense state, filtering, sorting, period totals, create/update/delete/restore behavior.
- `DashboardPeriodProvider`: selected dashboard period for the home screen.
- `SettingsProvider`: custom categories, monthly budget, category budgets, user-bound loading, budget persistence sequencing.
- `ReportsProvider`: monthly summaries and CSV generation from current expense state.
- `BudgetAlertProvider`: active/pending budget threshold alerts and local notification dispatch.

## Architecture

Spendly follows a feature-first architecture:

- `lib/main.dart` initializes Flutter bindings and Firebase, then runs `SpendlyApp`.
- `lib/app` owns app composition, routes, navigation shell, provider registration, and app-level widgets.
- `lib/core` owns feature-neutral constants, Firebase boundaries, theme tokens, and shared widgets.
- `lib/features/<feature>` owns feature-specific models, providers, screens, services, widgets, and constants.
- SDK and persistence calls stay inside services.
- Providers own UI-facing state, async transitions, and coordination.
- Screens and widgets stay presentation-focused.
- Routes are centralized through `AppRoutes`.
- Firestore collection/document names are centralized in `FirestoreConstants`.
- All production Firestore access goes through the shared `FirestoreService` boundary.

Dependency direction:

- `app` can import features to compose the application.
- `features` can import `core`.
- `core` must not import feature modules.
- Services can use Firebase SDKs.
- Widgets should not construct Firebase services directly.

## Firebase And Data Layer

Firebase startup happens in `lib/main.dart` using `DefaultFirebaseOptions.currentPlatform`.

Firestore access is centralized under `lib/core/firebase`:

- `firestore_constants.dart`: collection and document IDs.
- `firestore_service.dart`: shared `FirebaseFirestore` boundary and common user-scoped helpers.

Feature services use that shared boundary:

- `UserFirestoreService`: user profile document reads/writes/deletion.
- `ExpenseService`: expenses collection, active expense stream, create/update/soft delete/restore/delete all.
- `CustomCategoryService`: custom category collection, save/delete/delete all.
- `SettingsFirestoreService`: preferences and budget documents.

Current Firestore shape:

```text
users/{uid}
  settings/preferences
  settings/budget
  expenses/{expenseId}
  customCategories/{categoryId}
```

Important data behavior:

- Expenses are soft-deleted with `status: deleted`.
- Active expense streams filter deleted documents.
- Account deletion deletes the Firebase Auth account first, then feature-owned Firestore data, then the user document.
- User-bound app/settings providers guard against stale async results after account switches.

## Detailed Folder Structure

```text
lib/
  main.dart
  firebase_options.dart

  app/
    app_providers.dart              # Dependency injection and provider graph
    app_route_tracker.dart          # Current route tracking for app-level UI
    app_routes.dart                 # Named routes and dynamic route parsing
    app_theme.dart                  # ThemeData wiring
    main_navigation_screen.dart     # Signed-in tab shell
    spendly_app.dart                # Root MaterialApp
    providers/
      app_state_provider.dart       # Theme/currency/week-start/preferences
    widgets/
      budget_exceeded_popup_presenter.dart

  core/
    constants/
      app_constants.dart
    firebase/
      firestore_constants.dart      # Firestore collection/document names
      firestore_service.dart        # Shared Firestore boundary
    theme/
      app_colors.dart
      app_radii.dart
      app_shadows.dart
      app_spacing.dart
      app_text_styles.dart
    widgets/
      app_primary_button.dart
      app_text_field.dart
      app_text_link.dart
      summary_tile.dart
      user_profile_avatar.dart

  features/
    auth/
      constants/
        auth_constants.dart
        auth_validators.dart
      models/
        app_user.dart
        password_strength.dart
      providers/
        auth_provider.dart
      screens/
        auth_gate.dart
        forgot_password_screen.dart
        login_screen.dart
        reset_password_screen.dart
        sign_up_screen.dart
        welcome_screen.dart
      services/
        auth_service.dart
        user_firestore_service.dart
      widgets/
        auth_error_banner.dart
        auth_footer_link.dart
        auth_header.dart
        auth_icon_panel.dart
        auth_password_field.dart
        auth_scaffold.dart
        forgot_password_form.dart
        login_form.dart
        password_strength_bar.dart
        penny_mark.dart
        remember_me_row.dart
        reset_password_form.dart
        sign_up_form.dart

    expenses/
      models/
        custom_category_icon_resolver.dart
        expense_category.dart
        expense_day_group.dart
        expense_entry.dart
        expense_filter_chip_data.dart
        expense_list_query_state.dart
        expense_sort_option.dart
        payment_method.dart
      providers/
        add_expense_flow_controller.dart
        expense_provider.dart
      screens/
        edit_expense_screen.dart
        expense_detail_screen.dart
        expense_list_screen.dart
      services/
        custom_category_service.dart
        expense_service.dart
      widgets/
        add_expense_flow_sheet.dart
        amount_card.dart
        amount_keypad_step.dart
        amount_shortcut.dart
        category_add_tile.dart
        category_chip.dart
        category_list_row.dart
        category_picker_step.dart
        category_picker_tile.dart
        celebration_confetti_row.dart
        custom_category_name_dialog.dart
        delete_expense_confirmation_sheet.dart
        delete_expense_icon.dart
        delete_expense_sheet_action_button.dart
        edit_amount_editor.dart
        edit_expense_header.dart
        empty_expenses_list.dart
        expense_amount_range_filter.dart
        expense_amount_range_thumb.dart
        expense_celebration_step.dart
        expense_day_header.dart
        expense_delete_button.dart
        expense_deleted_progress_indicator.dart
        expense_deleted_snack_bar.dart
        expense_detail_header.dart
        expense_details_step.dart
        expense_filter_sheet.dart
        expense_filter_summary.dart
        expense_header_icon_box.dart
        expense_header_icon_button.dart
        expense_hero_amount.dart
        expense_info_card.dart
        expense_info_field.dart
        expense_info_row.dart
        expense_inline_sort_control.dart
        expense_list_body.dart
        expense_list_header.dart
        expense_list_sheet_launcher.dart
        expense_list_tile.dart
        expense_note_field.dart
        expense_overview_list.dart
        expense_search_field.dart
        expense_search_results_view.dart
        expense_sheet_frame.dart
        expense_sheet_header.dart
        expense_sheet_icon_button.dart
        expense_sort_sheet.dart
        expense_theme.dart
        mint_action_button.dart
        more_chip.dart
        number_pad.dart
        saved_expense_card.dart
        section_label.dart

    home/
      models/
        bottom_nav_metrics.dart
        dashboard_period.dart
      providers/
        dashboard_period_provider.dart
      screens/
        home_screen.dart
      widgets/
        add_expense_fab.dart
        email_verification_banner.dart
        empty_expense_state.dart
        home_header.dart
        navigation_icon_button.dart
        period_selector.dart
        period_spend_card.dart
        placeholder_tab.dart
        recent_expenses_list.dart
        spendly_bottom_nav_bar.dart

    reports/
      models/
        category_spend_summary.dart
      providers/
        reports_provider.dart
      screens/
        reports_screen.dart
      widgets/
        category_breakdown_list.dart
        category_breakdown_row.dart
        empty_reports_state.dart
        export_report_button.dart
        export_report_dialog.dart
        report_metric_card.dart
        reports_header.dart
        reports_total_card.dart

    settings/
      models/
        budget_alert_threshold_stage.dart
        budget_editor_request.dart
      providers/
        budget_alert_provider.dart
        settings_provider.dart
      screens/
        categories_screen.dart
        category_budgets_screen.dart
        notifications_screen.dart
        settings_screen.dart
      services/
        budget_local_notification_service.dart
        settings_firestore_service.dart
      widgets/
        add_category_sheet.dart
        budget_alert_card.dart
        budget_amount_sheet.dart
        budget_notification_tile.dart
        budget_notifications_list.dart
        budget_overview_card.dart
        category_budget_list.dart
        category_budget_row.dart
        category_budgets_editor.dart
        category_budgets_view.dart
        category_management_list.dart
        category_management_row.dart
        danger_action.dart
        destructive_confirmation_dialog.dart
        edit_profile_sheet.dart
        mint_switch.dart
        monthly_budget_actions_sheet.dart
        notifications_body.dart
        notifications_empty_state.dart
        profile_card.dart
        settings_body.dart
        settings_divider.dart
        settings_navigation_card.dart
        settings_option_sheet.dart
        settings_row.dart
        settings_section.dart
        settings_section_header.dart
```

## Screens And Navigation

Routes are defined in `AppRoutes`.

Primary routes include:

- `/` auth gate
- `/welcome`
- `/sign-up`
- `/login`
- `/forgot-password`
- `/reset-password`
- `/settings`
- `/categories`
- `/category-budgets`
- `/notifications`
- `/expense-detail`
- `/edit-expense`

The signed-in experience is composed through `MainNavigationScreen`, which hosts Home, Expenses, Insights, and Settings tabs.

## Testing

The project includes unit, provider, service, and widget tests.

Test areas:

- App provider/state contracts
- Auth provider account lifecycle
- Expense provider filtering, sorting, update rollback, delete/restore sequencing
- Add expense flow controller
- Custom categories and category IDs
- Edit expense custom category behavior
- Home dashboard period and bottom nav metrics
- Reports CSV generation and export wiring
- Settings provider category/budget behavior
- Budget alert provider and budget widgets
- Main widget flows

Run all tests:

```bash
flutter test
```

Run analysis:

```bash
flutter analyze
```

## Getting Started

### Prerequisites

- Flutter SDK with Dart `^3.12.2`
- Firebase project configured for the target platforms
- Generated `lib/firebase_options.dart`

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Validate

```bash
flutter analyze
flutter test
```

## Firebase Notes

- Firebase is initialized before app startup in `lib/main.dart`.
- Firebase options are read from `lib/firebase_options.dart`.
- Firestore collection/document names should be added to `FirestoreConstants`, not duplicated in feature files.
- New production Firestore-backed services should receive `FirestoreService` through `AppProviders`.
- Android declares `POST_NOTIFICATIONS` for Android 13+ budget notifications.

## Development Guidelines

- Keep feature-specific UI inside `lib/features/<feature>/widgets`.
- Keep reusable feature-neutral UI inside `lib/core/widgets`.
- Put Firebase and persistence calls in services.
- Put UI-facing state and async coordination in providers.
- Keep screens focused on layout, input, navigation, and provider calls.
- Add route constants to `AppRoutes` before navigating to new screens.
- Prefer existing theme tokens from `AppColors`, `AppSpacing`, `AppRadii`, `AppShadows`, and `AppTextStyles`.
- Add focused tests when changing provider behavior, persistence behavior, routing, or user-facing flows.

## Export Behavior

- Insights exports the current calendar month CSV.
- Settings exports the complete expense history CSV.

## Project Status

- Private Flutter app, not published to pub.dev.
- Firebase credentials and platform configuration are required for local development.
