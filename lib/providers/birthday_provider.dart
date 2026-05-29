import 'package:flutter/foundation.dart';
import '../models/birthday.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/error_handler.dart';
import '../services/analytics_service.dart';
import 'package:uuid/uuid.dart';

class BirthdayProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Birthday> _birthdays = [];
  bool _isLoading = false;
  AppError? _error;
  final Map<String, int> _daysUntilCache = {};
  final Map<String, int> _ageCache = {};

  List<Birthday> get birthdays => _birthdays;
  bool get isLoading => _isLoading;
  AppError? get error => _error;

  BirthdayProvider() {
    _loadBirthdays();
  }

  Future<void> _loadBirthdays() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await _storageService.loadBirthdays();

      // Handle empty state gracefully - no mock data
      _birthdays = loaded.map((b) {
        // Use cache if available, otherwise calculate
        final cacheKey = b.birthdate.toIso8601String();
        final daysUntil = _daysUntilCache[cacheKey] ??
            Birthday.calculateDaysUntil(b.birthdate);
        final age = _ageCache[cacheKey] ?? Birthday.calculateAge(b.birthdate);

        // Update cache
        _daysUntilCache[cacheKey] = daysUntil;
        _ageCache[cacheKey] = age;

        return b.copyWith(daysUntil: daysUntil, age: age);
      }).toList();

      // Sort by days until
      _birthdays.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
      _error = null;
    } catch (e, stackTrace) {
      _error = ErrorHandler.handleError(e, stackTrace);
      _error?.log();
      // On error, just use empty list - UI will handle empty state
      _birthdays = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryLoad() async {
    await _loadBirthdays();
  }

  Future<void> addBirthday(Birthday birthday) async {
    try {
      _error = null;
      final newBirthday = birthday.copyWith(
        id: const Uuid().v4(),
        daysUntil: Birthday.calculateDaysUntil(birthday.birthdate),
        age: Birthday.calculateAge(birthday.birthdate),
      );

      _birthdays.add(newBirthday);
      _birthdays.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
      await _storageService.saveBirthdays(_birthdays);
      await NotificationService.scheduleBirthdayReminder(newBirthday);
      AnalyticsService().logBirthdayAdded();
      notifyListeners();
    } catch (e, stackTrace) {
      _error = ErrorHandler.handleError(e, stackTrace);
      _error?.log();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBirthday(Birthday updatedBirthday) async {
    try {
      _error = null;
      final index = _birthdays.indexWhere((b) => b.id == updatedBirthday.id);
      if (index != -1) {
        final daysUntil =
            Birthday.calculateDaysUntil(updatedBirthday.birthdate);
        final age = Birthday.calculateAge(updatedBirthday.birthdate);

        _birthdays[index] = updatedBirthday.copyWith(
          daysUntil: daysUntil,
          age: age,
        );
        _birthdays.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
        await _storageService.saveBirthdays(_birthdays);
        await NotificationService.scheduleBirthdayReminder(_birthdays[index]);
        AnalyticsService().logBirthdayEdited();
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _error = ErrorHandler.handleError(e, stackTrace);
      _error?.log();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBirthday(String id) async {
    try {
      _error = null;
      await NotificationService.cancelReminder(id);
      _birthdays.removeWhere((b) => b.id == id);
      await _storageService.saveBirthdays(_birthdays);
      AnalyticsService().logBirthdayDeleted();
      notifyListeners();
    } catch (e, stackTrace) {
      _error = ErrorHandler.handleError(e, stackTrace);
      _error?.log();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAllBirthdays() async {
    try {
      _error = null;
      // Cancel all reminders
      for (var birthday in _birthdays) {
        await NotificationService.cancelReminder(birthday.id);
      }
      _birthdays.clear();
      _daysUntilCache.clear();
      _ageCache.clear();
      await _storageService.saveBirthdays(_birthdays);
      notifyListeners();
    } catch (e, stackTrace) {
      _error = ErrorHandler.handleError(e, stackTrace);
      _error?.log();
      notifyListeners();
      rethrow;
    }
  }

  List<Birthday> getUpcomingBirthdays() {
    return _birthdays.where((b) => b.daysUntil >= 0).toList();
  }

  List<Birthday> searchBirthdays(String query) {
    if (query.isEmpty) return _birthdays;
    return _birthdays
        .where((b) => b.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Birthday> getBirthdaysForMonth(int month, int year) {
    return _birthdays.where((b) {
      return b.birthdate.month == month;
    }).toList();
  }

  List<Birthday> getBirthdaysForDate(int day, int month) {
    return _birthdays.where((b) {
      return b.birthdate.day == day && b.birthdate.month == month;
    }).toList();
  }
}
