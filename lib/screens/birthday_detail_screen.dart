import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/birthday.dart';
import '../providers/birthday_provider.dart';
import '../widgets/wish_dialog.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';
import '../widgets/minimal_card.dart';
import 'birthday_form_screen.dart';

class BirthdayDetailScreen extends StatelessWidget {
  final Birthday birthday;

  const BirthdayDetailScreen({super.key, required this.birthday});

  String _getDaysText() {
    if (birthday.daysUntil == 0) return "Birthday is today! 🎉";
    if (birthday.daysUntil == 1) return "Birthday is tomorrow!";
    return "${birthday.daysUntil} days until birthday";
  }

  void _showContactDetails(BuildContext context, Contact contact) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(contact.displayName, style: AppTheme.heading3(isDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.phones.isNotEmpty) ...[
              Text('Phone: ${contact.phones.first.number}', style: AppTheme.bodyMedium(isDark)),
              const SizedBox(height: AppTheme.spacingSM),
            ],
            if (contact.emails.isNotEmpty) ...[
              Text('Email: ${contact.emails.first.address}', style: AppTheme.bodyMedium(isDark)),
              const SizedBox(height: AppTheme.spacingSM),
            ],
            Text(
              'To edit this contact, please use your device\'s Contacts app.',
              style: AppTheme.bodySmall(isDark),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: AppTheme.labelLarge(isDark)),
          ),
        ],
      ),
    );
  }

  Future<void> _openContact(BuildContext context, String contactId) async {
    try {
      final hasPermission = await PermissionService.requestContactsPermission(context);
      if (!hasPermission) {
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contacts permission is required to open contact'),
                backgroundColor: AppTheme.warningColor,
              ),
            );
        }
        return;
      }

      final granted = await FlutterContacts.requestPermission();
      if (!granted) {
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contacts permission denied'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
        }
        return;
      }

      final contact = await FlutterContacts.getContact(contactId);
      if (contact != null && context.mounted) {
        // Open contact using platform channel or show contact details
        // Note: openEditForm doesn't exist in flutter_contacts, so we'll show a dialog instead
        _showContactDetails(context, contact);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact not found'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening contact: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BirthdayProvider>(context);
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Birthday Details',
                        style: AppTheme.heading3(isDark),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  child: MinimalCard(
                    elevation: 3,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // Hero Section
                        Container(
                          height: 120,
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppTheme.radiusLarge),
                              topRight: Radius.circular(AppTheme.radiusLarge),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.cake,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        // Profile
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingLG),
                          child: Column(
                            children: [
                              Transform.translate(
                                offset: const Offset(0, -60),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppTheme.getSurfaceColor(isDark),
                                  child: CircleAvatar(
                                    radius: 56,
                                    backgroundImage: birthday.photo != null
                                        ? CachedNetworkImageProvider(birthday.photo!)
                                        : null,
                                    child: birthday.photo == null
                                        ? Text(
                                            birthday.name
                                                .split(' ')
                                                .map((n) => n[0])
                                                .join('')
                                                .toUpperCase()
                                                .substring(0, birthday.name.split(' ').length > 1 ? 2 : 1),
                                            style: AppTheme.heading2(isDark).copyWith(
                                              color: AppTheme.primaryColor,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingSM),
                              Text(
                                birthday.name,
                                style: AppTheme.heading2(isDark),
                              ),
                              const SizedBox(height: AppTheme.spacingXS),
                              Text(
                                _getDaysText(),
                                style: AppTheme.bodyMedium(isDark).copyWith(
                                  color: AppTheme.getTextSecondaryColor(isDark),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingLG),
                              // Info Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoCard(
                                      Icons.calendar_today,
                                      'Birthday',
                                      '${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}',
                                      AppTheme.primaryColor,
                                      isDark,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingSM),
                                  Expanded(
                                    child: _buildInfoCard(
                                      Icons.cake,
                                      'Age',
                                      '${birthday.age} years',
                                      AppTheme.secondaryColor,
                                      isDark,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingSM),
                                  Expanded(
                                    child: _buildInfoCard(
                                      Icons.card_giftcard,
                                      'Days Left',
                                      '${birthday.daysUntil}',
                                      AppTheme.accentColor,
                                      isDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingLG),
                              // Details
                              _buildDetailRow(
                                'Full Birthdate',
                                '${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}, ${birthday.birthdate.year}',
                                isDark,
                              ),
                              Divider(color: AppTheme.getDividerColor(isDark)),
                              if (birthday.contactId != null) ...[
                                _buildDetailRow(
                                  'Linked Contact',
                                  'View in Contacts',
                                  isDark,
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.open_in_new,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onPressed: () => _openContact(context, birthday.contactId!),
                                  ),
                                ),
                                Divider(color: AppTheme.getDividerColor(isDark)),
                              ],
                              _buildDetailRow(
                                'Reminder',
                                birthday.reminderEnabled
                                    ? '${birthday.reminderDays} days before'
                                    : 'Disabled',
                                isDark,
                                trailing: Switch(
                                  value: birthday.reminderEnabled,
                                  onChanged: (value) {
                                    provider.updateBirthday(
                                      birthday.copyWith(reminderEnabled: value),
                                    );
                                  },
                                  activeThumbColor: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingLG),
                              // Action Buttons
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => WishDialog(birthday: birthday),
                                    );
                                  },
                                  icon: const Icon(Icons.message),
                                  label: const Text('Send Birthday Wish'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingSM),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        final message = '${birthday.name}\'s birthday is on ${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}! 🎉\n\n${birthday.daysUntil == 0 ? "Today is their birthday!" : birthday.daysUntil == 1 ? "Tomorrow!" : "In ${birthday.daysUntil} days!"}';
                                        Share.share(
                                          message,
                                          subject: '${birthday.name}\'s Birthday',
                                        );
                                      },
                                      icon: const Icon(Icons.share),
                                      label: const Text('Share'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingSM),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BirthdayFormScreen(birthday: birthday),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingSM),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showDeleteDialog(context, provider);
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete Birthday'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.errorColor,
                                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    ),
                                    side: const BorderSide(color: AppTheme.errorColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildInfoCard(IconData icon, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            label,
            style: AppTheme.bodySmall(isDark),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: AppTheme.labelLarge(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.labelLarge(isDark),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  value,
                  style: AppTheme.bodySmall(isDark),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _showDeleteDialog(BuildContext context, BirthdayProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Birthday', style: AppTheme.heading3(isDark)),
        content: Text(
          'Are you sure you want to delete ${birthday.name}?',
          style: AppTheme.bodyMedium(isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.labelLarge(isDark)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteBirthday(birthday.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: AppTheme.labelLarge(isDark).copyWith(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

