# Spendly

Spendly is a Flutter expense tracker for personal budgeting and expense review. It uses Firebase Authentication and Firestore for user accounts, expenses, settings, budgets, and category data.

## What it does

- Email/password sign up, login, forgot password, and reset password
- Home dashboard with period-based spending summary
- Add, edit, view, search, sort, filter, and delete expenses
- Category management and custom categories
- Overall budget and per-category budgets
- Budget alerts for warning and exceeded states
- Reports with category breakdown and export flow
- Light and dark themes with shared Spendly design tokens

## Tech Stack

- Flutter
- Provider for app state
- Firebase Auth
- Cloud Firestore
- Google Fonts

## Project Structure

- `lib/app` - app shell, routing, providers, navigation, and theme
- `lib/core` - shared widgets, theme tokens, and app-wide utilities
- `lib/features/auth` - authentication screens, providers, models, and services
- `lib/features/home` - dashboard, period selection, and recent expenses
- `lib/features/expenses` - expense flows, detail screens, lists, and services
- `lib/features/settings` - settings, budgets, categories, and notifications
- `lib/features/reports` - spending reports and export UI

## Getting Started

### Prerequisites

- Flutter SDK `^3.12.2`
- A configured Firebase project

### Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Ensure Firebase is configured for the app. The entrypoint initializes Firebase from `lib/firebase_options.dart`.

3. Run the app:

```bash
flutter run
```

## Firebase Notes

- `lib/main.dart` initializes Firebase before the app starts
- Authentication is handled through Firebase Auth
- App data is stored in Cloud Firestore
- If you change Firebase projects, regenerate `lib/firebase_options.dart`

## Development Commands

```bash
flutter analyze
flutter test
flutter run
```

## Architecture

Spendly follows a feature-first Flutter architecture:

- Screens and widgets stay presentation-focused
- Providers own UI-facing state and async transitions
- Services wrap Firebase and other external SDK calls
- Shared UI stays in `lib/core`
- Routes are centralized through `AppRoutes`
- App-wide dependencies are registered in `AppProviders`

## Notes

- The app is not published to pub.dev
- Firebase credentials and generated platform files are required for local development
