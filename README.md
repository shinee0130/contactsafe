# ContactSafe

ContactSafe is a Flutter application for securely managing your contacts, notes, events and photos. It lets you group contacts, attach files or notes and lock the app with an optional PIN. Firebase is used for authentication and cloud storage.

## Prerequisites

- **Flutter 3.7** or later.
- Run `flutter pub get` to fetch the dependencies listed in `pubspec.yaml`.
- Platform toolchains if you plan to build for a specific device:
  - Android SDK for Android builds.
  - Xcode for iOS builds.
  - A supported browser such as Chrome for web builds.

## Localization

Translation files live under `lib/l10n`. English, German and Mongolian strings
are provided as both `.arb` and `.json` files. You can switch languages from the
settings screen. To add a new language simply create another ARB/JSON file in
that directory and rebuild the app.

## Running Tests

Execute all unit and widget tests with:

```bash
flutter test
```

## Building

To produce release builds, run the following commands from the project root:

```bash
flutter build apk     # Android
flutter build ios     # iOS
flutter build web     # Web
```

Use `flutter run` to launch the app in debug mode on a connected device or simulator.

## Getting Started

See the [Flutter documentation](https://docs.flutter.dev/) for detailed installation and setup instructions.
