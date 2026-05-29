import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/birthday.dart';
import '../providers/birthday_provider.dart';
import '../services/permission_service.dart';
import '../services/error_handler.dart';
import '../theme/app_theme.dart';

class BirthdayFormScreen extends StatefulWidget {
  final Birthday? birthday;

  const BirthdayFormScreen({super.key, this.birthday});

  @override
  State<BirthdayFormScreen> createState() => _BirthdayFormScreenState();
}

class _BirthdayFormScreenState extends State<BirthdayFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _photo;
  File? _photoFile;
  bool _reminderEnabled = true;
  Set<int> _selectedReminderDays = {1}; // Multiple selection
  EventType _eventType = EventType.birthday;
  String? _contactId;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.birthday != null) {
      _nameController.text = widget.birthday!.name;
      _selectedDate = widget.birthday!.birthdate;
      _photo = widget.birthday!.photo;
      _reminderEnabled = widget.birthday!.reminderEnabled;
      _selectedReminderDays = {widget.birthday!.reminderDays};
      _eventType = widget.birthday!.eventType;
      _contactId = widget.birthday!.contactId;
      _loadContactIfExists();
    }
  }

  Future<void> _loadContactIfExists() async {
    if (_contactId == null) return;

    try {
      final hasPermission = await FlutterContacts.requestPermission();
      if (!hasPermission) return;

      final contact = await FlutterContacts.getContact(_contactId!);
      if (contact != null) {
        // Contact exists
      }
    } catch (e) {
      // Contact might not exist anymore, ignore
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handlePhotoUpload() async {
    try {
      final hasPermission =
          await PermissionService.requestStoragePermission(context);
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Storage permission is required to select photos. Please enable it in settings.'),
              backgroundColor: AppTheme.warningColor,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photoFile = File(image.path);
          _photo = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final provider = Provider.of<BirthdayProvider>(context, listen: false);

      try {
        // Use the first selected reminder day (or default to 1)
        final reminderDays =
            _selectedReminderDays.isNotEmpty ? _selectedReminderDays.first : 1;

        final birthday = Birthday(
          id: widget.birthday?.id ?? '',
          name: _nameController.text.trim(),
          birthdate: _selectedDate!,
          age: Birthday.calculateAge(_selectedDate!),
          daysUntil: Birthday.calculateDaysUntil(_selectedDate!),
          photo: _photo,
          reminderEnabled: _reminderEnabled,
          reminderDays: reminderDays,
          contactId: _contactId,
          eventType: _eventType,
        );

        if (widget.birthday != null) {
          await provider.updateBirthday(birthday);
        } else {
          await provider.addBirthday(birthday);
        }

        if (mounted) {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.birthday != null
                  ? 'Event updated successfully!'
                  : 'Event added successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e, stackTrace) {
        final error = ErrorHandler.handleError(e, stackTrace);
        error.log();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.userFriendlyMessage),
              backgroundColor: AppTheme.errorColor,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _handleSave,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.beigeContainer(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.onSurface(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.birthday == null ? 'Add Event' : 'Edit Event',
          style: AppTheme.heading3(isDark),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Type Section
            Text(
              'Event Type',
              style: AppTheme.heading3(isDark).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Row(
              children: [
                Expanded(
                  child: _buildEventTypeButton(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Birthday',
                    isSelected: _eventType == EventType.birthday,
                    onTap: () =>
                        setState(() => _eventType = EventType.birthday),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: _buildEventTypeButton(
                    icon: Icons.favorite,
                    label: 'Anniversary',
                    isSelected: _eventType == EventType.anniversary,
                    onTap: () =>
                        setState(() => _eventType = EventType.anniversary),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Photo Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _handlePhotoUpload,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: _photo != null
                          ? ClipOval(
                              child: _photoFile != null
                                  ? Image.file(
                                      _photoFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: _photo!,
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 48,
                              color: AppTheme.primaryColor,
                            ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                  OutlinedButton.icon(
                    onPressed: _handlePhotoUpload,
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: const Text('Add Photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.onSurfaceVariant(isDark),
                      side: BorderSide(color: AppTheme.outline(isDark)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMD,
                        vertical: AppTheme.spacingSM,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Form Fields
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      filled: true,
                      fillColor: AppTheme.beigeContainer(isDark),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.outline(isDark)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.outline(isDark)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryColor, width: 2),
                      ),
                      hintText: 'Enter full name',
                      hintStyle:
                          TextStyle(color: AppTheme.onSurfaceVariant(isDark)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppTheme.spacingMD),

                  // Birth Date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: _eventType == EventType.anniversary
                            ? 'Anniversary Date *'
                            : 'Birth Date *',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F0),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide:
                              BorderSide(color: AppTheme.outline(isDark)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide:
                              BorderSide(color: AppTheme.outline(isDark)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          borderSide: const BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today, size: 20),
                        hintText: 'dd/mm/yyyy',
                        hintStyle:
                            TextStyle(color: AppTheme.onSurfaceVariant(isDark)),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'dd/mm/yyyy'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: AppTheme.bodyMedium(false).copyWith(
                          color: _selectedDate == null
                              ? AppTheme.onSurfaceVariant(isDark)
                              : AppTheme.onSurface(isDark),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingMD),

                  // Phone Number (Optional)
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number (Optional)',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F0),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.outline(isDark)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: BorderSide(color: AppTheme.outline(isDark)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryColor, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.phone, size: 20),
                      hintText: '+1 (555) 000-0000',
                      hintStyle:
                          TextStyle(color: AppTheme.onSurfaceVariant(isDark)),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Enable Reminders Section
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(isDark),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: AppTheme.outline(isDark)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacingSM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enable Reminders',
                                    style: AppTheme.labelLarge(false).copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Get notified before the event',
                                    style: AppTheme.bodySmall(false).copyWith(
                                      color: AppTheme.onSurfaceVariant(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _reminderEnabled,
                              onChanged: (value) {
                                setState(() => _reminderEnabled = value);
                              },
                              activeThumbColor: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                        if (_reminderEnabled) ...[
                          const SizedBox(height: AppTheme.spacingLG),
                          Text(
                            'Remind me (select multiple)',
                            style: AppTheme.labelLarge(false).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMD),
                          Row(
                            children: [
                              Expanded(
                                child: _buildReminderDayButton(1, isDark),
                              ),
                              const SizedBox(width: AppTheme.spacingMD),
                              Expanded(
                                child: _buildReminderDayButton(2, isDark),
                              ),
                              const SizedBox(width: AppTheme.spacingMD),
                              Expanded(
                                child: _buildReminderDayButton(4, isDark),
                              ),
                            ],
                          ),
                          if (_selectedReminderDays.isNotEmpty) ...[
                            const SizedBox(height: AppTheme.spacingSM),
                            Text(
                              'Selected: ${_selectedReminderDays.length} reminder${_selectedReminderDays.length != 1 ? 's' : ''}',
                              style: AppTheme.bodySmall(false).copyWith(
                                color: AppTheme.onSurfaceVariant(isDark),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Notes Section
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: AppTheme.surface(isDark),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: AppTheme.outline(isDark)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note_outlined,
                              color: AppTheme.onSurfaceVariant(isDark),
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacingSM),
                            Text(
                              'Notes (Optional)',
                              style: AppTheme.labelLarge(false).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingMD),
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Add any special notes, gift ideas, or memories...',
                            hintStyle: TextStyle(
                                color: AppTheme.onSurfaceVariant(isDark)),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide:
                                  BorderSide(color: AppTheme.outline(isDark)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide:
                                  BorderSide(color: AppTheme.outline(isDark)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide: const BorderSide(
                                  color: AppTheme.primaryColor, width: 2),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F0),
                            contentPadding:
                                const EdgeInsets.all(AppTheme.spacingMD),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMD + 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            side: BorderSide(color: AppTheme.outline(isDark)),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTheme.labelLarge(false).copyWith(
                              color: AppTheme.onSurface(isDark),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMD),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.contactSyncGradient,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLarge),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacingMD + 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusLarge),
                              ),
                            ),
                            child: Text(
                              widget.birthday == null
                                  ? _eventType == EventType.anniversary
                                      ? 'Add Anniversary'
                                      : 'Add Birthday'
                                  : 'Save Changes',
                              style: AppTheme.labelLarge(false).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingMD,
          horizontal: AppTheme.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.surface(isDark),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color:
                isSelected ? AppTheme.primaryColor : AppTheme.outline(isDark),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.onSurfaceVariant(isDark),
              size: 32,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              label,
              style: AppTheme.labelMedium(false).copyWith(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.onSurfaceVariant(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderDayButton(int days, bool isDark) {
    final isSelected = _selectedReminderDays.contains(days);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedReminderDays.remove(days);
          } else {
            _selectedReminderDays.add(days);
          }
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.surface(isDark),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color:
                isSelected ? AppTheme.primaryColor : AppTheme.outline(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$days',
                  style: AppTheme.heading3(false).copyWith(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.onSurface(isDark),
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                Text(
                  days == 1 ? 'day before' : 'days before',
                  style: AppTheme.bodySmall(false).copyWith(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.onSurfaceVariant(isDark),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
