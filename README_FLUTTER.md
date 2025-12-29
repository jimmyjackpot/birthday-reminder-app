# Birthday Reminder App - Flutter

A beautiful and functional Birthday Reminder App built with Flutter. This app helps you never miss a special day by keeping track of all your friends' and family's birthdays.

## Features

- 🎂 **Birthday Management**: Add, edit, and delete birthdays
- 📅 **Calendar View**: View birthdays in a beautiful calendar interface
- 🔔 **Reminders**: Set up reminders to get notified before birthdays
- 🔍 **Search**: Quickly find birthdays by name
- 💾 **Local Storage**: All data is stored locally on your device
- 🎨 **Beautiful UI**: Modern, clean interface with smooth animations
- 📱 **Responsive**: Works great on all screen sizes

## Screens

1. **Splash Screen**: Beautiful animated splash screen
2. **Auth Screen**: Login/Signup interface (demo mode available)
3. **Contact Sync**: Option to sync birthdays from contacts
4. **Home Screen**: List and calendar views of upcoming birthdays
5. **Birthday Detail**: Detailed view of a birthday with actions
6. **Birthday Form**: Add or edit birthday information
7. **Profile Screen**: User profile and quick settings
8. **Settings Screen**: Comprehensive app settings

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── birthday.dart         # Birthday data model
├── providers/
│   ├── app_provider.dart    # App state management
│   └── birthday_provider.dart # Birthday state management
├── screens/
│   ├── splash_screen.dart
│   ├── auth_screen.dart
│   ├── contact_sync_screen.dart
│   ├── contact_sync_progress_screen.dart
│   ├── home_screen.dart
│   ├── birthday_detail_screen.dart
│   ├── birthday_form_screen.dart
│   ├── calendar_view_screen.dart
│   ├── profile_screen.dart
│   └── settings_screen.dart
├── services/
│   └── storage_service.dart  # Local storage service
└── widgets/
    ├── birthday_card.dart    # Birthday card widget
    └── bottom_nav.dart       # Bottom navigation widget
```

## Dependencies

- **provider**: State management
- **shared_preferences**: Local data storage
- **table_calendar**: Calendar widget
- **cached_network_image**: Image caching
- **google_fonts**: Beautiful typography
- **uuid**: Unique ID generation
- **intl**: Date formatting

## Usage

1. **Launch the app**: You'll see the splash screen first
2. **Login**: Use the demo login button to skip authentication
3. **Add Birthdays**: Tap the + button to add a new birthday
4. **View Birthdays**: Browse birthdays in list or calendar view
5. **Manage**: Tap on any birthday to view details, edit, or delete

## Features in Detail

### Birthday Management
- Add birthdays with name, date, and optional photo
- Edit existing birthdays
- Delete birthdays with confirmation
- Automatic age calculation
- Days until birthday calculation

### Reminders
- Enable/disable reminders per birthday
- Set reminder days (1 day, 2 days, 3 days, 1 week, 2 weeks before)
- Toggle reminders from birthday detail screen

### Calendar View
- Monthly calendar with birthday markers
- Tap on dates with birthdays to view details
- Navigate between months
- List of birthdays for current month

### Search
- Real-time search by name
- Filtered results in both list and calendar views

## State Management

The app uses **Provider** for state management:
- `AppProvider`: Manages app-level state (screens, tabs, settings)
- `BirthdayProvider`: Manages birthday data and operations

## Local Storage

All data is persisted using `shared_preferences`:
- Birthdays are saved automatically
- User preferences are stored
- Data persists across app restarts

## Customization

### Colors
The app uses a beautiful gradient color scheme:
- Primary: Blue
- Secondary: Purple
- Accent: Pink

You can customize colors in the theme configuration in `main.dart`.

### Mock Data
The app includes mock birthday data for demonstration. This is generated automatically on first launch if no birthdays exist.

## Future Enhancements

Potential features to add:
- [ ] Push notifications for birthday reminders
- [ ] Contact sync integration
- [ ] Share birthday functionality
- [ ] Wish messages templates
- [ ] Dark mode support
- [ ] Export/Import birthdays
- [ ] Birthday statistics and analytics
- [ ] Social media integration

## Troubleshooting

### Common Issues

1. **Dependencies not installing:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build errors:**
   - Make sure you're using Flutter 3.0.0 or higher
   - Check that all dependencies are compatible

3. **Storage issues:**
   - The app uses shared_preferences which should work on all platforms
   - Check app permissions if data isn't persisting

## Contributing

Feel free to contribute to this project! Some areas that could use improvement:
- Additional features
- UI/UX improvements
- Performance optimizations
- Bug fixes
- Documentation

## License

This project is open source and available for use.

## Support

For issues or questions, please check the code comments or create an issue in the repository.

---

**Enjoy never missing a birthday! 🎉**

