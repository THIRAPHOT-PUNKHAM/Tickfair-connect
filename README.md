# 🎟️ TickFair Connect

> *Making ticket booking fair and easy* 🚀

## 📖 Project Description
**TickFair Connect** is a Flutter-based mobile application designed to solve the problem of unfair ticket distribution for small events. It implements a **first-come-first-served queue system** coupled with a **single-ticket policy** to ensure transparency, fairness, and simplicity.

The app targets university-age users who often miss out on tickets due to simultaneous heavy access and lack of visible queue order.

## ✨ Key Features
* **🔐 Authentication & Profile:** User registration and login via email/password and Google Sign-In.
* **📅 Event Listing & Discovery:** Display a scrollable list of available events with search/filter capabilities.
* **👥 Queue Management:** Allow users to join a queue for selected events, preventing duplicate entries.
* **⏱️ Real-Time Updates:** Display queue position and estimated wait time.
* **🎫 Ticket Reservation:** Reserve tickets when it's the user's turn, with confirmation and ticket saving.
* **🎟️ My Tickets:** View booked tickets with QR code verification from the profile screen.

## 🛠️ Technology Stack

| Component | Technology |
| :--- | :--- |
| **Frontend** | Flutter 3 (Dart) 📱 |
| **Authentication** | Firebase Authentication (Email/Password + Google) 🔒 |
| **Database** | Cloud Firestore 🗄️ |
| **State Management** | Provider 🔄 |
| **QR Code** | qr_flutter 🔲 |

## 🚀 Installation and Running

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.11.0)
* [Firebase CLI](https://firebase.google.com/docs/cli) (for Firebase setup)
* Android Studio or VS Code

### Installation Steps

1. **Clone this project:**
   ```bash
   git clone <repository-url>
   cd tickfair_connect
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   * Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   * Add an Android app and download `google-services.json` to `android/app/`.
   * Run `flutterfire configure` to generate `lib/firebase_options.dart`.
   * Enable **Email/Password** and **Google** sign-in methods in Firebase Authentication.

4. **Run the app:**
   ```bash
   flutter run
   ```

### 📦 Building for Production

```bash
# Android App Bundle (recommended for Play Store)
flutter build appbundle

# Android APK
flutter build apk
```

> **Note (Windows):** If building on Windows with a Thai locale, the Gradle JVM must use the Gregorian calendar. This is already configured in `android/gradle.properties`:
> ```
> org.gradle.jvmargs=... -Duser.language=en -Duser.country=US
> ```

## 👨‍💻 Development
* **Developer:** Thiraphot Punkham
* **Student ID:** 6731503014
* **Date:** April 2026
* **Version:** 1.0.0

## 📄 License
This project is part of an academic assignment and for personal use.

## 📬 Contact
For questions or suggestions, contact: `6731503014@lamduan.mfu.ac.th`
