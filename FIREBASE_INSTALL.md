# Firebase Installation & Setup

## Quick Start

### 1. Install Firebase SDK

```bash
npm install firebase
```

Or with pnpm/yarn:
```bash
pnpm install firebase
# or
yarn add firebase
```

### 2. Verify Installation

After installing, your Firebase Analytics is already configured with:

- **Project**: `birthday-reminder-app-5ca26`
- **Measurement ID**: `G-PKPRPQ2DDF`
- **Config File**: `src/app/config/firebase.ts`

### 3. Test It

1. Start your dev server: `npm run dev`
2. Open browser console
3. You should see: `✅ Firebase Analytics initialized successfully`
4. Perform actions in the app (add birthday, change settings, etc.)
5. Check Firebase Console → Analytics → Events (may take a few minutes to appear)

## How It Works

1. **Firebase Config** (`src/app/config/firebase.ts`)
   - Initializes Firebase app with your credentials
   - Sets up Analytics with support checking
   - Exports `app` and `analytics` instances

2. **Analytics Service** (`src/app/services/analytics.ts`)
   - Singleton service that tracks all events
   - Queues events until Firebase is ready
   - Automatically processes queue when initialized

3. **Event Tracking**
   - All major user actions are automatically tracked
   - Events include relevant parameters (event type, timestamps, etc.)
   - Works in both development and production

## Troubleshooting

### Events not showing in Firebase Console?

1. **Wait a few minutes** - Events can take 24-48 hours to appear in some reports
2. **Check DebugView** - Firebase Console → Analytics → DebugView (shows events in real-time)
3. **Check Console** - Look for `✅ Firebase Analytics initialized` message
4. **Verify Measurement ID** - Make sure `G-PKPRPQ2DDF` matches your Firebase project

### Firebase not initializing?

1. Check browser console for errors
2. Verify Firebase package is installed: `npm list firebase`
3. Make sure you're running in a browser (not SSR)
4. Check network tab for Firebase requests

## Event List

All these events are automatically tracked:

- `app_opened` - App launched
- `add_birthday` - Add birthday/anniversary
- `edit_birthday` - Edit event
- `delete_birthday` - Delete event
- `view_birthday_details` - View event details
- `select_event_type` - Choose birthday vs anniversary
- `tab_navigation` - Switch tabs
- `view_mode_change` - List/Calendar toggle
- `search` - Search performed
- `settings_opened` - Settings accessed
- `notification_setting_changed` - Notification toggles
- `sound_setting_changed` - Sound settings
- `vibration_setting_changed` - Vibration toggle
- `reminder_setting_changed` - Reminder preferences
- `wish_sent` - Send wish
- `share` - Share event
- `photo_uploaded` - Upload photo
- And more...

See `src/app/services/analytics.ts` for complete list.

