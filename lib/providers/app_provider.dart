import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

enum AppScreen { splash, onboarding, permissions, contactSync, contactSyncProgress, main }
enum ModalScreen { detail, add, edit, settings, none }
enum AppTab { home, calendar, statistics, profile }

class AppProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  AppScreen _currentScreen = AppScreen.splash;
  ModalScreen _modalScreen = ModalScreen.none;
  AppTab _activeTab = AppTab.home;
  bool _darkMode = false;
  bool _useSystemTheme = true;
  bool _notificationsEnabled = true;
  bool _hasCompletedOnboarding = false;

  AppScreen get currentScreen => _currentScreen;
  ModalScreen get modalScreen => _modalScreen;
  AppTab get activeTab => _activeTab;
  bool get darkMode => _darkMode;
  bool get useSystemTheme => _useSystemTheme;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  AppProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = await _storageService.loadUser();
    if (user != null) {
      _darkMode = user['darkMode'] ?? false;
      _useSystemTheme = user['useSystemTheme'] ?? true;
      _notificationsEnabled = user['notificationsEnabled'] ?? true;
      _hasCompletedOnboarding = user['hasCompletedOnboarding'] ?? false;
    }
  }

  void setScreen(AppScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void setModalScreen(ModalScreen screen) {
    _modalScreen = screen;
    notifyListeners();
  }

  void setActiveTab(AppTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    final user = await _storageService.loadUser();
    if (user != null) {
      user['hasCompletedOnboarding'] = true;
      await _storageService.saveUser(user);
    }
    notifyListeners();
  }


  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    _useSystemTheme = false;
    final user = await _storageService.loadUser();
    if (user != null) {
      user['darkMode'] = value;
      user['useSystemTheme'] = false;
      await _storageService.saveUser(user);
    }
    AnalyticsService().logThemeChanged(isDark: value);
    notifyListeners();
  }
  
  Future<void> setUseSystemTheme(bool value) async {
    _useSystemTheme = value;
    final user = await _storageService.loadUser();
    if (user != null) {
      user['useSystemTheme'] = value;
      await _storageService.saveUser(user);
    }
    notifyListeners();
  }
  
  void updateThemeFromSystem(Brightness brightness) {
    if (_useSystemTheme) {
      _darkMode = brightness == Brightness.dark;
      notifyListeners();
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final user = await _storageService.loadUser();
    if (user != null) {
      user['notificationsEnabled'] = value;
      await _storageService.saveUser(user);
    }
    notifyListeners();
  }
}

