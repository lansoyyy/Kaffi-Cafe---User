# Copilot Instructions for Kaffi Cafe Flutter App

## Project Overview
- This is a Flutter app for a cafe, supporting seat reservation, menu ordering, chat support, and user authentication.
- Main features: seat/table reservation, menu browsing and ordering, chat/FAQ support, branch/type selection, persistent user choices.
- Uses Firebase (Firestore, Auth) and GetStorage for local persistence.

## Key Architecture & Patterns
- **Screens**: Located in `lib/screens/`, each major feature (home, menu, reservation, chat) is a separate screen.
- **Navigation**: Uses `GetMaterialApp` (GetX) for navigation and state management. Main entry: `main.dart` → `AuthWrapper` → tabbed screens.
- **Widgets**: Custom widgets (e.g., `TextWidget`, `ButtonWidget`, `DividerWidget`) in `lib/widgets/` for consistent UI.
- **State**: StatefulWidgets for local state, GetStorage for persistent selections (branch/type).
- **Firestore**: Used for orders, menu, and user data. See `firebase_options.dart` for config.
- **Reservation Flow**: `reservation_screen.dart` shows tables first; date/time picker appears below selected table (no Stack overlays).
- **Menu Flow**: After reservation, user is navigated to menu tab to order drinks.

## Developer Workflows
- **Build/Run**: Standard Flutter commands (`flutter run`, `flutter build`). No custom build scripts detected.
- **Firebase**: Requires `firebase_options.dart` and initialization in `main.dart`.
- **Local Storage**: Uses GetStorage for persisting user selections.
- **Testing**: Widget tests in `test/widget_test.dart` (default Flutter test).

## Project-Specific Conventions
- **Dialog Logic**: Dialogs for branch/type selection only show if not already selected (checked via GetStorage).
- **UI Patterns**: Header widgets show current branch/type; selection chips for categories and times.
- **Navigation**: Use `Navigator.pushReplacementNamed(context, '/menu')` after reservation.
- **No Stack overlays**: All dynamic UI (e.g., reservation pickers) should appear inline below the triggering widget.

## Integration Points
- **Firebase**: Firestore for data, Auth for user context.
- **GetX**: Used for navigation and state management.
- **GetStorage**: For local persistence of user choices.

## Examples
- See `lib/screens/reservation_screen.dart` for reservation UI logic and inline picker placement.
- See `lib/screens/home_screen.dart` for dialog logic and persistent selection.
- See `lib/screens/tabs/menu_tab.dart` for menu ordering flow.

## Quickstart for AI Agents
- Start with `main.dart` and follow navigation to understand app flow.
- Use custom widgets from `lib/widgets/` for UI consistency.
- Persist user choices with GetStorage, check before showing dialogs.
- Place dynamic UI inline, not overlayed.
- Reference Firestore and Auth via `firebase_options.dart` and `main.dart`.

---

If any section is unclear or missing, please provide feedback to improve these instructions.
