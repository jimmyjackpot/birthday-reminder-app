import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:io';
import '../models/birthday.dart';
import '../providers/birthday_provider.dart';
import '../widgets/wish_dialog.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';
import 'birthday_form_screen.dart';

class BirthdayDetailScreen extends StatelessWidget {
  final Birthday birthday;

  const BirthdayDetailScreen({super.key, required this.birthday});

  String _getDaysText() {
    if (birthday.daysUntil == 0) {
      return birthday.eventType == EventType.anniversary
          ? "Anniversary is today! 🎉"
          : "Birthday is today! 🎉";
    }
    if (birthday.daysUntil == 1) {
      return birthday.eventType == EventType.anniversary
          ? "Anniversary is tomorrow!"
          : "Birthday is tomorrow!";
    }
    return birthday.eventType == EventType.anniversary
        ? "${birthday.daysUntil} days until anniversary"
        : "${birthday.daysUntil} days until birthday";
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
              Text('Phone: ${contact.phones.first.number}',
                  style: AppTheme.bodyMedium(isDark)),
              const SizedBox(height: AppTheme.spacingSM),
            ],
            if (contact.emails.isNotEmpty) ...[
              Text('Email: ${contact.emails.first.address}',
                  style: AppTheme.bodyMedium(isDark)),
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
      final hasPermission =
          await PermissionService.requestContactsPermission(context);
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
    final isAnniversary = birthday.eventType == EventType.anniversary;

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer(isDark),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.surface(isDark),
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
            color: AppTheme.onSurface(isDark),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAnniversary ? 'Anniversary Details' : 'Birthday Details',
          style: AppTheme.heading3(isDark),
        ),
        actions: [
          IconButton(
            icon: Icon(
              PhosphorIcons.pencil(PhosphorIconsStyle.regular),
              color: AppTheme.onSurface(isDark),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BirthdayFormScreen(birthday: birthday),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLG),
              decoration: BoxDecoration(
                color: AppTheme.surface(isDark),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: AppTheme.cardShadow(isDark),
              ),
              child: Column(
                children: [
                  // Avatar
                  _buildAvatar(isDark),
                  const SizedBox(height: AppTheme.spacingMD),
                  // Name
                  Text(
                    birthday.name,
                    style: AppTheme.heading2(isDark).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  // Days Text
                  Text(
                    _getDaysText(),
                    style: AppTheme.bodyMedium(isDark).copyWith(
                      color: AppTheme.onSurfaceVariant(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMD),
            
            // Info Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                    label: isAnniversary ? 'Anniversary' : 'Birthday',
                    value: '${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}',
                    color: AppTheme.primaryColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: _buildInfoCard(
                    icon: isAnniversary
                        ? PhosphorIcons.heart(PhosphorIconsStyle.regular)
                        : PhosphorIcons.cake(PhosphorIconsStyle.regular),
                    label: isAnniversary ? 'Years Together' : 'Age',
                    value: isAnniversary
                        ? '${birthday.age} years'
                        : '${birthday.age} years',
                    color: AppTheme.secondaryColor,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: _buildInfoCard(
                    icon: PhosphorIcons.gift(PhosphorIconsStyle.regular),
                    label: 'Days Left',
                    value: '${birthday.daysUntil}',
                    color: AppTheme.accentColor,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingMD),
            
            // Details Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: AppTheme.surface(isDark),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: AppTheme.cardShadow(isDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: AppTheme.heading3(isDark).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                  _buildDetailRow(
                    icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular),
                    label: 'Full Date',
                    value: '${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}, ${birthday.birthdate.year}',
                    isDark: isDark,
                  ),
                  if (birthday.contactId != null) ...[
                    Divider(height: 1, color: AppTheme.outline(isDark)),
                    const SizedBox(height: AppTheme.spacingSM),
                    _buildDetailRow(
                      icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                      label: 'Linked Contact',
                      value: 'View in Contacts',
                      isDark: isDark,
                      trailing: IconButton(
                        icon: Icon(
                          PhosphorIcons.arrowRight(PhosphorIconsStyle.regular),
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: () => _openContact(context, birthday.contactId!),
                      ),
                    ),
                  ],
                  Divider(height: 1, color: AppTheme.outline(isDark)),
                  const SizedBox(height: AppTheme.spacingSM),
                  _buildDetailRow(
                    icon: PhosphorIcons.bell(PhosphorIconsStyle.regular),
                    label: 'Reminder',
                    value: birthday.reminderEnabled
                        ? '${birthday.reminderDays} days before'
                        : 'Disabled',
                    isDark: isDark,
                    trailing: Switch(
                      value: birthday.reminderEnabled,
                      onChanged: (value) {
                        provider.updateBirthday(
                          birthday.copyWith(reminderEnabled: value),
                        );
                      },
                      activeThumbColor: AppTheme.primaryColor,
                      activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMD),
            
            // Action Buttons Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: AppTheme.surface(isDark),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: AppTheme.cardShadow(isDark),
              ),
              child: Column(
                children: [
                  // Send Wish Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => WishDialog(birthday: birthday),
                        );
                      },
                      icon: Icon(
                        PhosphorIcons.chatCircle(PhosphorIconsStyle.regular),
                        color: Colors.white,
                      ),
                      label: Text(
                        isAnniversary ? 'Send Anniversary Wish' : 'Send Birthday Wish',
                        style: AppTheme.labelLarge(isDark).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                  // Share and Edit Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final message =
                                '${birthday.name}\'s ${isAnniversary ? "anniversary" : "birthday"} is on ${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}! 🎉\n\n${birthday.daysUntil == 0 ? "Today is their ${isAnniversary ? "anniversary" : "birthday"}!" : birthday.daysUntil == 1 ? "Tomorrow!" : "In ${birthday.daysUntil} days!"}';
                            Share.share(
                              message,
                              subject: '${birthday.name}\'s ${isAnniversary ? "Anniversary" : "Birthday"}',
                            );
                          },
                          icon: Icon(
                            PhosphorIcons.share(PhosphorIconsStyle.regular),
                            color: AppTheme.secondaryColor,
                          ),
                          label: Text(
                            'Share',
                            style: AppTheme.labelLarge(isDark).copyWith(
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.secondaryColor),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMD,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMD),
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
                          icon: Icon(
                            PhosphorIcons.pencil(PhosphorIconsStyle.regular),
                            color: AppTheme.onSurface(isDark),
                          ),
                          label: Text(
                            'Edit',
                            style: AppTheme.labelLarge(isDark),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.outline(isDark)),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingMD,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDeleteDialog(context, provider);
                      },
                      icon: Icon(
                        PhosphorIcons.trash(PhosphorIconsStyle.regular),
                        color: AppTheme.errorColor,
                      ),
                      label: Text(
                        'Delete',
                        style: AppTheme.labelLarge(isDark).copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.errorColor),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    Widget avatarWidget;
    
    if (birthday.photo != null) {
      if (birthday.photo!.startsWith('http')) {
        avatarWidget = CachedNetworkImage(
          imageUrl: birthday.photo!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 120,
            height: 120,
            color: AppTheme.surfaceContainer(isDark),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => _buildAvatarFallback(isDark),
        );
      } else {
        avatarWidget = Image.file(
          File(birthday.photo!),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(isDark),
        );
      }
    } else {
      avatarWidget = _buildAvatarFallback(isDark);
    }
    
    return ClipOval(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.outline(isDark),
            width: 3,
          ),
        ),
        child: avatarWidget,
      ),
    );
  }

  Widget _buildAvatarFallback(bool isDark) {
    final initials = birthday.name
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .join('')
        .toUpperCase();
    
    final displayInitials = initials.length > 2 
        ? initials.substring(0, 2) 
        : (initials.isEmpty ? '?' : initials);
    
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          displayInitials,
          style: AppTheme.heading2(isDark).copyWith(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            label,
            style: AppTheme.bodySmall(isDark).copyWith(
              color: AppTheme.onSurfaceVariant(isDark),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: AppTheme.labelLarge(isDark).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.onSurfaceVariant(isDark),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.labelLarge(isDark).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.bodySmall(isDark).copyWith(
                    color: AppTheme.onSurfaceVariant(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
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

  void _showDeleteDialog(BuildContext context, BirthdayProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete ${birthday.eventType == EventType.anniversary ? "Anniversary" : "Birthday"}',
          style: AppTheme.heading3(isDark),
        ),
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
              style: AppTheme.labelLarge(isDark)
                  .copyWith(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
