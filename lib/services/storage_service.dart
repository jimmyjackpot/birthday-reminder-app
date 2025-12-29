import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/birthday.dart';

class StorageService {
  static const String _birthdaysKey = 'birthdays';
  static const String _userKey = 'user';

  // Save birthdays
  Future<void> saveBirthdays(List<Birthday> birthdays) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = birthdays.map((b) => b.toJson()).toList();
    await prefs.setString(_birthdaysKey, jsonEncode(jsonList));
  }

  // Load birthdays
  Future<List<Birthday>> loadBirthdays() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_birthdaysKey);
    
    if (jsonString == null) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Birthday.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save user data
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  // Load user data
  Future<Map<String, dynamic>?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_birthdaysKey);
    await prefs.remove(_userKey);
  }
}

