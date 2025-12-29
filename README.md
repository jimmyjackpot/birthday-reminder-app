# Birthday Reminder App

A beautiful and functional Birthday Reminder App built with Flutter, based on a modern design. This app helps you never miss a special day by keeping track of all your friends' and family's birthdays with a sleek, user-friendly interface.

## 🚀 Features

- 🎂 **Birthday Management**: Easily add, edit, and delete birthdays.
- 📅 **Calendar View**: View upcoming birthdays in a beautiful interactive calendar.
- 🔔 **Smart Reminders**: Set up customizable notifications to get alerted before the big day.
- 📊 **Statistics**: View birthday statistics and upcoming celebrations.
- 🔍 **Search & Filter**: Quickly find any birthday in your list.
- 🌙 **Dark Mode Support**: Beautiful UI that adapts to your system preferences.
- 🔄 **Contact Sync**: Import birthdays directly from your phone contacts.
- 💾 **Local Storage**: Your data stays private and secure on your device.

## 📱 Screenshots & Design

The app's design is inspired by the [Birthday Reminder App Design on Figma](https://www.figma.com/design/IHeabpMycCtFsDSZHz2nMN/Birthday-Reminder-App-Design).

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Icons**: [Lucide Icons](https://lucide.dev/) (via custom implementation)
- **Animations**: Custom Flutter animations & `motion` for web prototype.

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (Birthday, User, etc.)
├── providers/                # State management (App & Birthday providers)
├── screens/                  # All app screens (Home, Calendar, Details, etc.)
├── services/                 # Services (Notification, Analytics, Storage)
├── theme/                    # App themes and styling
├── utils/                    # Helper functions and animations
└── widgets/                  # Reusable UI components
```

## 🚀 Getting Started

### Flutter App (Mobile & Desktop)

1.  **Prerequisites**: Ensure you have Flutter installed (`flutter doctor`).
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```

### Web Prototype

The project also includes a web-based design prototype:

1.  **Install Dependencies**:
    ```bash
    npm install
    ```
2.  **Start Development Server**:
    ```bash
    npm run dev
    ```

## 📦 Key Dependencies

- `provider`: For reactive state management.
- `flutter_local_notifications`: For birthday alerts.
- `table_calendar`: For the interactive calendar view.
- `google_fonts`: For modern typography (Geist font family).
- `flutter_contacts`: For importing contacts.

## 📝 License

This project is open-source. Feel free to use and modify it for your own purposes.
