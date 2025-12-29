import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../models/birthday.dart';

class ContactSyncService {
  Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  Future<List<Birthday>> syncContacts() async {
    try {
      // Request permission from flutter_contacts
      final granted = await FlutterContacts.requestPermission();
      if (!granted) {
        throw Exception('Contacts permission not granted');
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
        withAccounts: false,
      );
      
      debugPrint('ContactSyncService: Found ${contacts.length} contacts');
      
      final birthdays = <Birthday>[];
      int contactsWithBirthdays = 0;

      for (var contact in contacts) {
        // Check if contact has name
        if (contact.name.first.isEmpty && contact.displayName.isEmpty) {
          continue;
        }
        
        // Get display name
        final displayName = contact.displayName.isNotEmpty 
            ? contact.displayName 
            : '${contact.name.first} ${contact.name.last}'.trim();
        
        if (displayName.isEmpty) continue;
        
        // Check if contact has birthday in events
        DateTime? birthdate;
        for (var event in contact.events) {
          // Check if this is a birthday event
          // flutter_contacts uses EventLabel enum
          bool isBirthday = false;
          
          try {
            // Check label (most reliable method)
            if (event.label == EventLabel.birthday) {
              isBirthday = true;
            }
            // Additional fallback for string matching
            else {
              final labelStr = event.label.toString().toLowerCase();
              if (labelStr.contains('birthday') || labelStr.contains('birth')) {
                isBirthday = true;
              }
            }
          } catch (e) {
            debugPrint('ContactSyncService: Error checking event type: $e');
            continue;
          }
          
          if (isBirthday) {
            // Construct DateTime from year, month, day
            // Use current year if year is null or invalid
            final year = event.year ?? DateTime.now().year;
            try {
              // Validate month and day are valid
              if (event.month >= 1 && event.month <= 12 && 
                  event.day >= 1 && event.day <= 31) {
                birthdate = DateTime(year, event.month, event.day);
                // Verify the date is actually valid (handles cases like Feb 30)
                if (birthdate.month == event.month && birthdate.day == event.day) {
                  contactsWithBirthdays++;
                  break;
                }
              }
            } catch (e) {
              debugPrint('ContactSyncService: Invalid date for $displayName: $e');
              continue;
            }
          }
        }
        
        // If we found a birthday, add it
        if (birthdate != null) {
          // Only add if birthdate is valid (allow future years for children)
          final now = DateTime.now();
          if (birthdate.year >= 1900 && birthdate.year <= now.year + 20) {
            // Use a unique ID to avoid conflicts
            final birthdayId = 'contact_${contact.id}_${birthdate.toIso8601String()}';
            final birthday = Birthday(
              id: birthdayId,
              name: displayName,
              birthdate: birthdate,
              age: Birthday.calculateAge(birthdate),
              daysUntil: Birthday.calculateDaysUntil(birthdate),
              photo: null, // Photo handling can be added later if needed
              reminderEnabled: true,
              reminderDays: 3,
              contactId: contact.id, // Link to contact
            );
            birthdays.add(birthday);
          }
        }
      }

      debugPrint('ContactSyncService: Found ${birthdays.length} birthdays from $contactsWithBirthdays contacts with birthday events');
      
      if (birthdays.isEmpty) {
        debugPrint('ContactSyncService: No birthdays found. Make sure contacts have birthday information set.');
      }

      return birthdays;
    } catch (e, stackTrace) {
      // Provide more detailed error information
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        throw Exception('Contacts permission denied. Please grant contacts permission to sync birthdays.');
      }
      throw Exception('Failed to sync contacts: ${e.toString()}\nStack trace: $stackTrace');
    }
  }

  Future<bool> checkPermission() async {
    final status = await Permission.contacts.status;
    return status.isGranted;
  }
}
