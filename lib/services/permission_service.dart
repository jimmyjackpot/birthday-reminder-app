import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  // Request contacts permission
  static Future<bool> requestContactsPermission(BuildContext context) async {
    final status = await Permission.contacts.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDialog(
          context,
          'Contacts Permission Required',
          'To sync birthdays from your contacts, please enable contacts permission in app settings.',
          Permission.contacts,
        );
      }
      return false;
    }

    // Request permission if denied or not determined
    final result = await Permission.contacts.request();
    return result.isGranted;
  }

  // Request camera permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDialog(
          context,
          'Camera Permission Required',
          'To take photos for birthdays, please enable camera permission in app settings.',
          Permission.camera,
        );
      }
      return false;
    }

    // Request permission if denied or not determined
    final result = await Permission.camera.request();
    return result.isGranted;
  }

  // Request storage/photos permission
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // Check Android version and use appropriate permission
    // Android 13+ (API 33+) uses READ_MEDIA_IMAGES
    // Android < 13 uses READ_EXTERNAL_STORAGE

    // Try photos permission first (Android 13+)
    Permission? permission;
    try {
      await Permission.photos.status;
      // If we can check photos status, it means we're on Android 13+
      permission = Permission.photos;
    } catch (e) {
      // Photos permission not available, use storage (Android < 13)
      permission = Permission.storage;
    }

    // Check current status
    final status = await permission.status;

    // If already granted or limited, return true
    if (status.isGranted || status.isLimited) {
      return true;
    }

    // If permanently denied, show dialog to open settings
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDialog(
          context,
          'Storage Permission Required',
          'To access files and photos, please enable storage/photos permission in app settings.',
          permission,
        );
      }
      return false;
    }

    // Request permission
    try {
      final result = await permission.request();

      // For photos permission, limited access is acceptable
      if (permission == Permission.photos) {
        return result.isGranted || result.isLimited;
      }

      // For storage permission, only granted is acceptable
      return result.isGranted;
    } catch (e) {
      // If photos permission fails, try storage as fallback (for edge cases)
      if (permission == Permission.photos) {
        try {
          final storageResult = await Permission.storage.request();
          return storageResult.isGranted;
        } catch (e2) {
          debugPrint('Storage permission request failed: $e2');
          return false;
        }
      }
      debugPrint('Permission request failed: $e');
      return false;
    }
  }

  // Request storage permission without context (for background operations)
  static Future<bool> requestStoragePermissionSilent() async {
    Permission? permission;

    try {
      await Permission.photos.status;
      permission = Permission.photos;
    } catch (e) {
      permission = Permission.storage;
    }

    final status = await permission.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (!status.isPermanentlyDenied) {
      try {
        final result = await permission.request();
        if (permission == Permission.photos) {
          return result.isGranted || result.isLimited;
        }
        return result.isGranted;
      } catch (e) {
        debugPrint('Silent storage permission request failed: $e');
        return false;
      }
    }

    return false;
  }

  // Request notification permission
  static Future<bool> requestNotificationPermission(
      BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDialog(
          context,
          'Notification Permission Required',
          'To receive birthday reminders, please enable notification permission in app settings.',
          Permission.notification,
        );
      }
      return false;
    }

    // Request permission if denied or not determined
    final result = await Permission.notification.request();

    // On Android 12+, also request exact alarm permission for precise notifications
    if (result.isGranted) {
      try {
        // Check if exact alarm permission is available (Android 12+)
        final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
        if (!exactAlarmStatus.isGranted &&
            !exactAlarmStatus.isPermanentlyDenied) {
          await Permission.scheduleExactAlarm.request();
        }
      } catch (e) {
        // Permission not available on this Android version, ignore
      }
    }

    return result.isGranted;
  }

  // Check if permission is granted
  static Future<bool> isContactsPermissionGranted() async {
    return await Permission.contacts.isGranted;
  }

  static Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  static Future<bool> isStoragePermissionGranted() async {
    try {
      final photosStatus = await Permission.photos.status;
      // If we can check photos status, use it (Android 13+)
      return photosStatus.isGranted || photosStatus.isLimited;
    } catch (e) {
      // Photos permission not available, check storage (Android < 13)
      return await Permission.storage.isGranted;
    }
  }

  static Future<bool> isNotificationPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  // Show permission dialog
  static Future<void> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    Permission permission,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Request all permissions at once (for onboarding)
  static Future<Map<Permission, PermissionStatus>>
      requestAllPermissions() async {
    final results = await [
      Permission.contacts,
      Permission.camera,
      Permission.photos,
      Permission.notification,
    ].request();

    // Also request exact alarm permission if notification was granted (Android 12+)
    if (results[Permission.notification]?.isGranted ?? false) {
      try {
        await Permission.scheduleExactAlarm.request();
      } catch (e) {
        // Permission not available on this Android version, ignore
      }
    }

    return results;
  }

  // Check all permissions status
  static Future<Map<String, bool>> checkAllPermissions() async {
    final notificationGranted = await Permission.notification.isGranted;
    bool exactAlarmGranted = false;

    // Check exact alarm permission if notification is granted (Android 12+)
    if (notificationGranted) {
      try {
        exactAlarmGranted = await Permission.scheduleExactAlarm.isGranted;
      } catch (e) {
        // Permission not available on this Android version
        exactAlarmGranted = true; // Assume granted for older Android versions
      }
    }

    return {
      'contacts': await Permission.contacts.isGranted,
      'camera': await Permission.camera.isGranted,
      'storage': await () async {
        try {
          final photosStatus = await Permission.photos.status;
          return photosStatus.isGranted || photosStatus.isLimited;
        } catch (e) {
          // Fallback to storage for Android < 13
          return await Permission.storage.isGranted;
        }
      }(),
      'notifications': notificationGranted && exactAlarmGranted,
    };
  }
}
