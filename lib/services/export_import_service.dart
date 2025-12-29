import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/birthday.dart';

class ExportImportService {
  Future<String> exportToJson(List<Birthday> birthdays) async {
    final jsonList = birthdays.map((b) => b.toJson()).toList();
    return jsonEncode(jsonList);
  }

  Future<void> exportAndShare(List<Birthday> birthdays) async {
    try {
      final jsonString = await exportToJson(birthdays);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/birthdays_backup.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Birthday Reminder Backup',
        subject: 'Birthday Data Export',
      );
    } catch (e) {
      throw Exception('Failed to export birthdays: $e');
    }
  }

  Future<List<Birthday>> importFromJson(String jsonString) async {
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => Birthday.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to import birthdays: $e');
    }
  }

  Future<List<Birthday>> importFromFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      return await importFromJson(jsonString);
    } catch (e) {
      throw Exception('Failed to import from file: $e');
    }
  }
}

