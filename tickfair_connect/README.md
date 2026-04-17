# TickFair Connect

## Project Description
TickFair Connect is a Flutter-based mobile application designed to solve the problem of unfair ticket distribution for small events. It implements a first-come-first-served queue system coupled with a single-ticket policy to ensure transparency, fairness, and simplicity.

The app targets university-age users who often miss out on tickets due to simultaneous heavy access and lack of visible queue order.

## Key Features
- **Authentication & Profile**: User registration and login via email/password.
- **Event Listing & Discovery**: Display a scrollable list of available events with search/filter capabilities.
- **Queue Management**: Allow users to join a queue for selected events, preventing duplicate entries.
- **Real-Time Updates**: Display queue position and estimated wait time.
- **Ticket Reservation**: Reserve tickets when it's the user's turn, with confirmation and ticket saving.

## Technology Stack
- **Frontend**: Flutter (Dart)
- **Authentication**: Firebase Authentication
- **Database**: Firebase Firestore
- **Realtime Updates**: Firebase Realtime Database
- **Notifications**: Firebase Cloud Messaging
- **Storage**: Firebase Cloud Storage

## Installation and Running

### Prerequisites
- Flutter SDK (latest version)
- Dart SDK
- Firebase CLI (for Firebase setup)

### Installation Steps
1. Clone this project:
   ```
   git clone <repository-url>
   cd tickfair_connect
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add `google-services.json` to `android/app/`
   - Add Firebase config to `lib/firebase_options.dart`

4. Run the app:
   ```
   flutter run
   ```

### Building for Production
```
flutter build apk  # For Android
flutter build ios  # For iOS
```

## Development
- **Developer**: Thiraphot Punkham
- **Date**: February 2026
- **Version**: MVP

## License
This project is part of an academic assignment and for personal use.

## Contact
For questions or suggestions, contact [email or other channel]

---

*TickFair Connect - Making ticket booking fair and easy*</content>
<parameter name="filePath">d:\Mini Project tickfair connect\tickfair_connect\README.md