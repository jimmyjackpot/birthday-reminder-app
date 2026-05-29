enum EventType {
  birthday,
  anniversary,
}

class Birthday {
  final String id;
  final String name;
  final DateTime birthdate;
  final int age;
  final int daysUntil;
  final String? photo;
  final bool reminderEnabled;
  final int reminderDays;
  final String? contactId; // ID of linked contact
  final EventType eventType; // birthday or anniversary

  Birthday({
    required this.id,
    required this.name,
    required this.birthdate,
    required this.age,
    required this.daysUntil,
    this.photo,
    required this.reminderEnabled,
    required this.reminderDays,
    this.contactId,
    this.eventType = EventType.birthday,
  });

  // Calculate days until next birthday
  static int calculateDaysUntil(DateTime birthdate) {
    final today = DateTime.now();
    final nextBirthday = DateTime(
      today.year,
      birthdate.month,
      birthdate.day,
    );

    if (nextBirthday.isBefore(today) || nextBirthday.isAtSameMomentAs(today)) {
      return DateTime(today.year + 1, birthdate.month, birthdate.day)
          .difference(today)
          .inDays;
    }

    return nextBirthday.difference(today).inDays;
  }

  // Calculate age
  static int calculateAge(DateTime birthdate) {
    final today = DateTime.now();
    int age = today.year - birthdate.year;
    if (today.month < birthdate.month ||
        (today.month == birthdate.month && today.day < birthdate.day)) {
      age--;
    }
    return age;
  }

  // Create from JSON
  factory Birthday.fromJson(Map<String, dynamic> json) {
    return Birthday(
      id: json['id'] as String,
      name: json['name'] as String,
      birthdate: DateTime.parse(json['birthdate'] as String),
      age: json['age'] as int,
      daysUntil: json['daysUntil'] as int,
      photo: json['photo'] as String?,
      reminderEnabled: json['reminderEnabled'] as bool,
      reminderDays: json['reminderDays'] as int,
      contactId: json['contactId'] as String?,
      eventType: json['eventType'] != null
          ? EventType.values.firstWhere(
              (e) => e.toString() == json['eventType'],
              orElse: () => EventType.birthday,
            )
          : EventType.birthday,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthdate': birthdate.toIso8601String(),
      'age': age,
      'daysUntil': daysUntil,
      'photo': photo,
      'reminderEnabled': reminderEnabled,
      'reminderDays': reminderDays,
      'contactId': contactId,
      'eventType': eventType.toString(),
    };
  }

  // Create a copy with updated fields
  Birthday copyWith({
    String? id,
    String? name,
    DateTime? birthdate,
    int? age,
    int? daysUntil,
    String? photo,
    bool? reminderEnabled,
    int? reminderDays,
    String? contactId,
    EventType? eventType,
  }) {
    return Birthday(
      id: id ?? this.id,
      name: name ?? this.name,
      birthdate: birthdate ?? this.birthdate,
      age: age ?? this.age,
      daysUntil: daysUntil ?? this.daysUntil,
      photo: photo ?? this.photo,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDays: reminderDays ?? this.reminderDays,
      contactId: contactId ?? this.contactId,
      eventType: eventType ?? this.eventType,
    );
  }

  // Get display title based on event type
  String getDisplayTitle() {
    switch (eventType) {
      case EventType.anniversary:
        return 'Wedding Anniversary';
      case EventType.birthday:
        return name;
    }
  }

  // Get reminder count (simplified - can be enhanced)
  int getReminderCount() {
    if (!reminderEnabled) return 0;
    // Count reminders: one for the day before (if reminderDays > 0) and one for the day of
    return reminderDays > 0 ? 2 : 1;
  }
}
