# TickFair Connect

Cross‑platform Flutter mobile application implementing the MVP described in `PRD-tickfairconnect.md`.

## Project setup

1. Install Flutter SDK and ensure `flutter` is on your PATH.
2. Open the project folder in VS Code or your preferred IDE.
3. Run `flutter pub get` to install dependencies.

## Firebase configuration

Before running the app you must add Firebase configuration files:

- For Android: place `google-services.json` in `android/app/`.
- For iOS/macOS: place `GoogleService-Info.plist` in `ios/Runner/` and `macos/Runner/` respectively.

Also add the required Gradle and Xcode setup from the [Firebase Flutter docs](https://firebase.flutter.dev/docs/overview).

Call `Firebase.initializeApp()` before using any Firebase APIs; this is already
handled in `lib/main.dart`.

## Running the app

- Debug on an emulator or device with `flutter run`.
- Build a release APK with `flutter build apk`.

## Core screens & features

- Login / Register (Firebase Auth)
- Event listing and detail
- Queue status and ticket reservation

See `PRD-tickfairconnect.md` for full requirements.

## Development notes

Use the `AuthService` and `DbService` in `lib/services` as helpers for
authentication and Firestore operations. Screens are located in
`lib/screens`.

### Firestore indexes ⚠️

Several of the app's queries filter on multiple fields (e.g. eventId +
status + joinedAt in the queue collection). Firestore requires a
composite index for these queries; otherwise you'll see an error like:

```
[cloud_firestore/failed-precondition] The query requires an index...
```

A `firestore.indexes.json` file is included at the project root with the
necessary definitions. To deploy the indexes run:

```bash
firebase deploy --only firestore:indexes
```

Alternatively, follow the link provided in the error message to create
them manually in the Firebase console.


