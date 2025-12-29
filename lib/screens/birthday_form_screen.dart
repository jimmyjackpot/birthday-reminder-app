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
import '../widgets/contact_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/minimal_card.dart';

class BirthdayFormScreen extends StatefulWidget {
  final Birthday? birthday;

  const BirthdayFormScreen({super.key, this.birthday});

  @override
  State<BirthdayFormScreen> createState() => _BirthdayFormScreenState();
}

class _BirthdayFormScreenState extends State<BirthdayFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String? _photo;
  File? _photoFile;
  bool _reminderEnabled = true;
  int _reminderDays = 1;
  String? _contactId;
  Contact? _selectedContact;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.birthday != null) {
      _nameController.text = widget.birthday!.name;
      _selectedDate = widget.birthday!.birthdate;
      _photo = widget.birthday!.photo;
      _reminderEnabled = widget.birthday!.reminderEnabled;
      _reminderDays = widget.birthday!.reminderDays;
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
        setState(() {
          _selectedContact = contact;
        });
      }
    } catch (e) {
      // Contact might not exist anymore, ignore
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      // Request storage permission
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

  Future<void> _handlePhotoFromCamera() async {
    try {
      // Request camera permission
      final hasPermission =
          await PermissionService.requestCameraPermission(context);
      if (!hasPermission) {
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
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
            content: Text('Error taking photo: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getSurfaceColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: AppTheme.getTextPrimaryColor(isDark),
              ),
              title: Text(
                'Choose from Gallery',
                style: AppTheme.bodyMedium(isDark),
              ),
              onTap: () {
                Navigator.pop(context);
                _handlePhotoUpload();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: AppTheme.getTextPrimaryColor(isDark),
              ),
              title: Text(
                'Take Photo',
                style: AppTheme.bodyMedium(isDark),
              ),
              onTap: () {
                Navigator.pop(context);
                _handlePhotoFromCamera();
              },
            ),
            if (_photo != null)
              Builder(
                builder: (context) {
                  return ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: AppTheme.errorColor,
                    ),
                    title: Text(
                      'Remove Photo',
                      style: AppTheme.bodyMedium(isDark).copyWith(
                        color: AppTheme.errorColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _photo = null;
                        _photoFile = null;
                      });
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final provider = Provider.of<BirthdayProvider>(context, listen: false);

      try {
        final birthday = Birthday(
          id: widget.birthday?.id ?? '',
          name: _nameController.text.trim(),
          birthdate: _selectedDate!,
          age: Birthday.calculateAge(_selectedDate!),
          daysUntil: Birthday.calculateDaysUntil(_selectedDate!),
          photo: _photo,
          reminderEnabled: _reminderEnabled,
          reminderDays: _reminderDays,
          contactId: _contactId,
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
                  ? 'Birthday updated successfully!'
                  : 'Birthday added successfully!'),
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
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.05),
              AppTheme.secondaryColor.withValues(alpha: 0.05),
              AppTheme.accentColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(isDark),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppTheme.getTextPrimaryColor(isDark),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.birthday == null
                            ? 'Add Birthday'
                            : 'Edit Birthday',
                        style: AppTheme.heading3(isDark),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  child: MinimalCard(
                    elevation: 3,
                    padding: const EdgeInsets.all(AppTheme.spacingLG),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Photo Upload
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _showPhotoOptions,
                                  child: CircleAvatar(
                                    radius: 48,
                                    backgroundColor: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    backgroundImage: _photo != null
                                        ? (_photoFile != null
                                            ? FileImage(_photoFile!)
                                                as ImageProvider
                                            : CachedNetworkImageProvider(
                                                _photo!) as ImageProvider)
                                        : null,
                                    child: _photo == null
                                        ? const Icon(
                                            Icons.camera_alt,
                                            size: 32,
                                            color: AppTheme.primaryColor,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _showPhotoOptions,
                                  icon: const Icon(Icons.camera_alt),
                                  label: Text(_photo == null
                                      ? 'Add Photo'
                                      : 'Change Photo'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Name
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Birthdate
                          Semantics(
                            label: 'Birth Date',
                            hint: 'Tap to select birth date',
                            button: true,
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Birth Date *',
                                  prefixIcon: const Icon(
                                    Icons.calendar_today,
                                    semanticLabel: 'Calendar',
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusMedium),
                                  ),
                                ),
                                child: Text(
                                  _selectedDate == null
                                      ? 'Select date'
                                      : '${_getMonthName(_selectedDate!.month)} ${_selectedDate!.day}, ${_selectedDate!.year}',
                                  style: AppTheme.bodyMedium(isDark).copyWith(
                                    color: _selectedDate == null
                                        ? AppTheme.getTextTertiaryColor(isDark)
                                        : AppTheme.getTextPrimaryColor(isDark),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_selectedDate != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Age: ${Birthday.calculateAge(_selectedDate!)} years old',
                              style: AppTheme.bodySmall(isDark),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Contact Link
                          InkWell(
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (context) => ContactPicker(
                                  selectedContactId: _contactId,
                                  onContactSelected: (contact) {
                                    setState(() {
                                      if (contact != null) {
                                        _selectedContact = contact;
                                        _contactId = contact.id;
                                        // Auto-fill name if empty
                                        if (_nameController.text.isEmpty) {
                                          _nameController.text =
                                              contact.displayName;
                                        }
                                      } else {
                                        _selectedContact = null;
                                        _contactId = null;
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Link Contact (Optional)',
                                prefixIcon: const Icon(Icons.contacts),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMedium),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedContact != null
                                          ? _selectedContact!.displayName
                                          : 'No contact selected',
                                      style:
                                          AppTheme.bodyMedium(isDark).copyWith(
                                        color: _selectedContact != null
                                            ? AppTheme.getTextPrimaryColor(
                                                isDark)
                                            : AppTheme.getTextTertiaryColor(
                                                isDark),
                                      ),
                                    ),
                                  ),
                                  if (_selectedContact != null)
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _selectedContact = null;
                                          _contactId = null;
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          // Reminder Settings
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusSmall),
                                ),
                                child: const Icon(
                                  Icons.notifications,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingSM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Enable Reminder',
                                      style: AppTheme.labelLarge(isDark),
                                    ),
                                    Text(
                                      'Get notified before the birthday',
                                      style: AppTheme.bodySmall(isDark),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _reminderEnabled,
                                onChanged: (value) {
                                  setState(() => _reminderEnabled = value);
                                },
                                activeTrackColor: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                          if (_reminderEnabled) ...[
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              initialValue: _reminderDays,
                              decoration: InputDecoration(
                                labelText: 'Remind me',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMedium),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 1, child: Text('1 day before')),
                                DropdownMenuItem(
                                    value: 2, child: Text('2 days before')),
                                DropdownMenuItem(
                                    value: 3, child: Text('3 days before')),
                                DropdownMenuItem(
                                    value: 7, child: Text('1 week before')),
                                DropdownMenuItem(
                                    value: 14, child: Text('2 weeks before')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _reminderDays = value);
                                }
                              },
                            ),
                          ],
                          const SizedBox(height: 32),
                          // Actions
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: AppTheme.spacingMD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMedium),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: AppTheme.spacingMD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMedium),
                                    ),
                                  ),
                                  child: Text(
                                    widget.birthday == null
                                        ? 'Add Birthday'
                                        : 'Save Changes',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
