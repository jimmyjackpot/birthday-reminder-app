# Firebase Analytics Setup Guide

## ✅ Configuration Complete!

Your Firebase Analytics is now fully configured with your credentials:
- **Project ID**: `birthday-reminder-app-5ca26`
- **Measurement ID**: `G-PKPRPQ2DDF`
- **App ID**: `1:854734097142:web:ddd29ffd97cfad233ebad7`

## Installation

### 1. Install Firebase SDK

Run this command to install the Firebase SDK:

```bash
npm install firebase
# or
pnpm install firebase
# or
yarn add firebase
```

### 2. Files Created

- ✅ `src/app/config/firebase.ts` - Firebase configuration and initialization
- ✅ `src/app/services/analytics.ts` - Analytics service using Firebase SDK
- ✅ `index.html` - Updated with your Measurement ID

### 3. How It Works

The Firebase SDK is automatically initialized when the app loads. All events are tracked using the official Firebase Analytics SDK, with fallback to gtag for compatibility.

### 3. Verify Installation

1. Open your app in the browser
2. Open Developer Tools (F12) → Console
3. You should see analytics events being logged (in development mode)
4. Check Firebase Console → Analytics → Events to see events in real-time

## Tracked Events

The following major events are automatically tracked:

### User Actions
- `add_birthday` - When user adds a birthday/anniversary
- `edit_birthday` - When user edits an event
- `delete_birthday` - When user deletes an event
- `view_birthday_details` - When user views event details
- `select_event_type` - When user selects birthday vs anniversary

### Navigation
- `screen_view` - Screen/page views
- `tab_navigation` - Tab switches (home/calendar/profile)
- `view_mode_change` - List vs Calendar view toggle

### Search & Interaction
- `search` - Search performed with query length and results count
- `wish_sent` - Birthday wish sent
- `share` - Event shared
- `photo_uploaded` - Photo uploaded

### Settings
- `settings_opened` - Settings screen opened
- `notification_setting_changed` - Notification toggles
- `notification_permission_requested` - Permission request with result
- `sound_setting_changed` - Sound settings changed
- `vibration_setting_changed` - Vibration toggle
- `reminder_setting_changed` - Reminder days/time changed
- `ad_frequency_changed` - Ad frequency setting
- `test_notification` - Test notification clicked
- `test_sound` - Test sound clicked
- `test_vibration` - Test vibration clicked
- `premium_button_clicked` - Premium button clicked

### App Lifecycle
- `app_opened` - App launched
- `error_occurred` - Errors with context

## Event Parameters

All events include:
- `event_type`: "birthday" or "anniversary" (where applicable)
- `timestamp`: Unix timestamp in milliseconds

Additional parameters vary by event type (see `src/app/services/analytics.ts` for details).

## Testing

Events are logged to console in development mode. In production, they're sent to Firebase Analytics.

## Privacy

All events are anonymous and don't contain personally identifiable information (PII).

