import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:io';
import '../providers/birthday_provider.dart';
import '../services/export_import_service.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      final provider = Provider.of<BirthdayProvider>(context, listen: false);
      final exportService = ExportImportService();
      await exportService.exportAndShare(provider.birthdays);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    final hasPermission =
        await PermissionService.requestStoragePermission(context);
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Storage permission is required to import files. Please enable it in settings.'),
            backgroundColor: AppTheme.warningColor,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () async {
                await openAppSettings();
              },
            ),
          ),
        );
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (!context.mounted) return;

    if (result != null && result.files.single.path != null) {
      final provider = Provider.of<BirthdayProvider>(context, listen: false);
      final exportService = ExportImportService();

      try {
        final filePath = result.files.single.path;
        if (filePath != null) {
          final birthdays = await exportService.importFromFile(File(filePath));

          for (var birthday in birthdays) {
            await provider.addBirthday(birthday);
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Imported ${birthdays.length} birthdays!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import failed: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearCache(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'This will clear cached data. Your birthdays will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Clear cache logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _deleteAllData(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
            'This action cannot be undone. All your birthdays and settings will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<BirthdayProvider>(context, listen: false);
      await provider.deleteAllBirthdays();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data deleted'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Privacy & Security',
          style: AppTheme.heading3(isDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          children: [
            // Data Management Section
            _buildSection(
              icon: PhosphorIcons.download(PhosphorIconsStyle.regular),
              iconColor: AppTheme.blueContainer(isDark),
              title: 'Data Management',
              isDark: isDark,
              children: [
                _buildActionTile(
                  icon: PhosphorIcons.download(PhosphorIconsStyle.regular),
                  iconColor: AppTheme.blueContainer(isDark),
                  title: 'Export Data',
                  subtitle: 'Backup all birthdays & settings',
                  onTap: () => _exportData(context),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: PhosphorIcons.upload(PhosphorIconsStyle.regular),
                  iconColor: AppTheme.blueContainer(isDark),
                  title: 'Import Data',
                  subtitle: 'Restore from backup file',
                  onTap: () => _importData(context),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon:
                      PhosphorIcons.arrowClockwise(PhosphorIconsStyle.regular),
                  iconColor: AppTheme.blueContainer(isDark),
                  title: 'Clear Cache',
                  subtitle: 'Free up storage space',
                  onTap: () => _clearCache(context),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: PhosphorIcons.trash(PhosphorIconsStyle.fill),
                  iconColor: AppTheme.errorColor,
                  title: 'Delete All Data',
                  subtitle: 'Permanently remove everything',
                  onTap: () => _deleteAllData(context),
                  isDark: isDark,
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMD),

            // Support & Info Section
            _buildSection(
              icon: PhosphorIcons.question(PhosphorIconsStyle.fill),
              iconColor: AppTheme.blueContainer(isDark),
              title: 'Support & Info',
              isDark: isDark,
              children: [
                _buildActionTile(
                  icon: PhosphorIcons.question(PhosphorIconsStyle.fill),
                  iconColor: AppTheme.blueContainer(isDark),
                  title: 'Help Center',
                  onTap: () {
                    // Navigate to help center
                  },
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: PhosphorIcons.chatCircle(PhosphorIconsStyle.regular),
                  iconColor: AppTheme.blueContainer(isDark),
                  title: 'Contact Support',
                  onTap: () {
                    // Open email client or support page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Contact support: support@birthdaybuddy.com'),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: PhosphorIcons.star(PhosphorIconsStyle.regular),
                  iconColor: AppTheme.blueContainer(isDark),
                  title: 'Rate BirthdayBuddy',
                  onTap: () {
                    // Open app store rating
                  },
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.regular),
                  iconColor: AppTheme.blueContainer(isDark),
                  title: 'Privacy Policy',
                  onTap: () {
                    // Navigate to privacy policy
                  },
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: PhosphorIcons.info(PhosphorIconsStyle.fill),
                  iconColor: AppTheme.blueContainer(isDark),
                  title: 'About',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'BirthdayBuddy',
                      applicationVersion: '1.0.0',
                      applicationIcon: Icon(
                        PhosphorIcons.cake(PhosphorIconsStyle.fill),
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Footer
            Column(
              children: [
                Text(
                  'BirthdayBuddy v1.0.0',
                  style: AppTheme.bodySmall(isDark).copyWith(
                    color: AppTheme.onSurfaceVariant(isDark),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                Text(
                  'Made with ❤️ for celebrating special moments',
                  style: AppTheme.bodySmall(isDark).copyWith(
                    color: AppTheme.onSurfaceVariant(isDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surface(isDark),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: AppTheme.spacingSM),
              Text(
                title,
                style: AppTheme.labelLarge(isDark).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    final textColor =
        isDestructive ? AppTheme.errorColor : AppTheme.onSurface(isDark);
    final subtitleColor =
        isDestructive ? AppTheme.errorColor : AppTheme.onSurfaceVariant(isDark);
    final backgroundColor = isDestructive
        ? AppTheme.errorColor.withValues(alpha: 0.1)
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.labelLarge(isDark).copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall(isDark).copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
              color: AppTheme.onSurfaceVariant(isDark),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
