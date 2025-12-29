import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../providers/birthday_provider.dart';
import '../services/export_import_service.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';
import '../widgets/minimal_card.dart';
import 'permissions_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDark),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTheme.heading3(isDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              children: [
                _buildSection(
                  Icons.people,
                  'Contact Sync',
                  [
                    _buildSwitchTile(
                      'Enable Contact Sync',
                      'Automatically import birthdays from your contacts',
                      false,
                      (value) {},
                      isDark,
                    ),
                  ],
                  isDark,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                _buildSection(
                  Icons.security,
                  'Permissions',
                  [
                    _buildActionTile(
                      Icons.settings,
                      'Manage Permissions',
                      'View and update app permissions',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PermissionsScreen(
                              onComplete: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                      isDark,
                    ),
                  ],
                  isDark,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                _buildSection(
                  Icons.backup,
                  'Data Management',
                  [
                    _buildActionTile(
                      Icons.download,
                      'Import Birthdays',
                      'Import from JSON file',
                      () async {
                        // Request storage permission before file picker
                        final hasPermission =
                            await PermissionService.requestStoragePermission(
                                context);
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
                          return; // Don't proceed without permission
                        }

                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['json'],
                        );

                        if (!context.mounted) return;

                        if (result != null &&
                            result.files.single.path != null) {
                          final provider = Provider.of<BirthdayProvider>(
                              context,
                              listen: false);
                          final exportService = ExportImportService();

                          try {
                            final filePath = result.files.single.path;
                            if (filePath != null) {
                              final birthdays = await exportService
                                  .importFromFile(File(filePath));

                              for (var birthday in birthdays) {
                                await provider.addBirthday(birthday);
                              }

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Imported ${birthdays.length} birthdays!'),
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
                      },
                      isDark,
                    ),
                  ],
                  isDark,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                _buildSection(
                  Icons.notifications,
                  'Notifications',
                  [
                    _buildSwitchTile(
                      'Push Notifications',
                      'Receive birthday reminders',
                      true,
                      (value) {},
                      isDark,
                    ),
                    _buildSwitchTile(
                      'Email Notifications',
                      'Get reminders via email',
                      false,
                      (value) {},
                      isDark,
                    ),
                  ],
                  isDark,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                _buildSection(
                  Icons.volume_up,
                  'Sound & Vibration',
                  [
                    _buildSwitchTile(
                      'Sound',
                      'Play sound for notifications',
                      true,
                      (value) {},
                      isDark,
                    ),
                    _buildSwitchTile(
                      'Vibration',
                      'Vibrate for reminders',
                      true,
                      (value) {},
                      isDark,
                    ),
                  ],
                  isDark,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                _buildSection(
                  Icons.language,
                  'General',
                  [
                    Consumer<AppProvider>(
                      builder: (context, appProvider, child) {
                        return _buildSwitchTile(
                          'Dark Mode',
                          appProvider.useSystemTheme
                              ? 'Following system theme'
                              : (appProvider.darkMode ? 'Enabled' : 'Disabled'),
                          appProvider.darkMode,
                          (value) {
                            appProvider.setDarkMode(value);
                          },
                          isDark,
                        );
                      },
                    ),
                    Consumer<AppProvider>(
                      builder: (context, appProvider, child) {
                        return _buildSwitchTile(
                          'Use System Theme',
                          'Follow device theme settings',
                          appProvider.useSystemTheme,
                          (value) {
                            appProvider.setUseSystemTheme(value);
                          },
                          isDark,
                        );
                      },
                    ),
                    _buildDropdownTile(
                      'Week Starts On',
                      'Calendar week preference',
                      'Sunday',
                      ['Sunday', 'Monday'],
                      (value) {},
                      isDark,
                    ),
                    _buildSwitchTile(
                      'Auto Sync',
                      'Sync data automatically',
                      true,
                      (value) {},
                      isDark,
                    ),
                  ],
                  isDark,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
      IconData icon, String title, List<Widget> children, bool isDark) {
    return MinimalCard(
      elevation: 2,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 18),
                ),
                const SizedBox(width: AppTheme.spacingSM),
                Text(
                  title,
                  style: AppTheme.heading3(isDark),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.getDividerColor(isDark)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return ListTile(
      title: Text(
        title,
        style: AppTheme.labelLarge(isDark),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall(isDark),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    Function(String) onChanged,
    bool isDark,
  ) {
    return ListTile(
      title: Text(
        title,
        style: AppTheme.labelLarge(isDark),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall(isDark),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option, style: AppTheme.bodyMedium(isDark)),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: AppTheme.labelLarge(isDark),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall(isDark),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.getTextTertiaryColor(isDark),
      ),
      onTap: onTap,
    );
  }
}
