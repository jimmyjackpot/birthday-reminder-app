import 'package:flutter/foundation.dart';

/// Analytics service for tracking user actions and app performance
/// This is a placeholder implementation that can be extended with
/// Firebase Analytics, Mixpanel, or other analytics providers
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _isEnabled = true;

  /// Enable or disable analytics
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Log a screen view
  void logScreenView(String screenName) {
    if (!_isEnabled) return;
    debugPrint('📊 Screen View: $screenName');
    // TODO: Integrate with analytics provider
    // Example: FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }

  /// Log a user action/event
  void logEvent(String eventName, [Map<String, dynamic>? parameters]) {
    if (!_isEnabled) return;
    debugPrint('📊 Event: $eventName ${parameters != null ? 'with params: $parameters' : ''}');
    // TODO: Integrate with analytics provider
    // Example: FirebaseAnalytics.instance.logEvent(
    //   name: eventName,
    //   parameters: parameters,
    // );
  }

  /// Log button click
  void logButtonClick(String buttonName, {String? screen}) {
    logEvent('button_click', {
      'button_name': buttonName,
      if (screen != null) 'screen': screen,
    });
  }

  /// Log birthday added
  void logBirthdayAdded() {
    logEvent('birthday_added');
  }

  /// Log birthday edited
  void logBirthdayEdited() {
    logEvent('birthday_edited');
  }

  /// Log birthday deleted
  void logBirthdayDeleted() {
    logEvent('birthday_deleted');
  }

  /// Log birthday shared
  void logBirthdayShared() {
    logEvent('birthday_shared');
  }

  /// Log contact sync
  void logContactSync({required int count}) {
    logEvent('contact_sync', {'count': count});
  }

  /// Log search performed
  void logSearch({required String query}) {
    logEvent('search_performed', {'query_length': query.length});
  }

  /// Log notification enabled/disabled
  void logNotificationToggled({required bool enabled}) {
    logEvent('notification_toggled', {'enabled': enabled});
  }

  /// Log theme changed
  void logThemeChanged({required bool isDark}) {
    logEvent('theme_changed', {'is_dark': isDark});
  }

  /// Log onboarding completed
  void logOnboardingCompleted() {
    logEvent('onboarding_completed');
  }

  /// Log app opened
  void logAppOpened() {
    logEvent('app_opened');
  }

  /// Log error
  void logError(String error, {String? screen, Map<String, dynamic>? context}) {
    logEvent('error_occurred', {
      'error': error,
      if (screen != null) 'screen': screen,
      if (context != null) ...context,
    });
  }

  /// Set user property
  void setUserProperty(String name, String value) {
    if (!_isEnabled) return;
    debugPrint('📊 User Property: $name = $value');
    // TODO: Integrate with analytics provider
    // Example: FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
  }
}

