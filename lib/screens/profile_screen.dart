import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/birthday_provider.dart';
import '../services/export_import_service.dart';
import '../theme/app_theme.dart';
import '../widgets/minimal_card.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final birthdayProvider = Provider.of<BirthdayProvider>(context);

    final user = {
      'name': 'User',
      'photo': null,
    };

    final totalBirthdays = birthdayProvider.birthdays.length;
    final upcomingCount = birthdayProvider
        .getUpcomingBirthdays()
        .where((b) => b.daysUntil <= 30)
        .length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: AppTheme.surface(isDark),
                boxShadow: AppTheme.cardShadow(isDark),
              ),
              child: Row(
                children: [
                  Text(
                    'Profile',
                    style: AppTheme.heading2(isDark),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: Column(
                  children: [
                    // Profile Card
                    MinimalCard(
                      elevation: 2,
                      padding: const EdgeInsets.all(AppTheme.spacingLG),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                child: Text(
                                  user['name']!
                                      .split(' ')
                                      .map((n) => n[0])
                                      .join('')
                                      .toUpperCase(),
                                  style: AppTheme.heading3(isDark).copyWith(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingMD),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['name']!,
                                      style: AppTheme.heading3(isDark),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppTheme.onSurfaceVariant(isDark),
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingLG),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  totalBirthdays.toString(),
                                  'Total Birthdays',
                                  AppTheme.primaryColor,
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingSM),
                              Expanded(
                                child: _buildStatCard(
                                  upcomingCount.toString(),
                                  'This Month',
                                  AppTheme.secondaryColor,
                                  isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    // Quick Settings
                    MinimalCard(
                      elevation: 2,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingMD),
                            child: Row(
                              children: [
                                Text(
                                  'Quick Settings',
                                  style: AppTheme.heading3(isDark),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: AppTheme.outlineVariant(isDark),
                          ),
                          _buildSettingTile(
                            Icons.notifications,
                            'Notifications',
                            'Birthday reminders',
                            appProvider.notificationsEnabled,
                            (value) =>
                                appProvider.setNotificationsEnabled(value),
                            isDark,
                          ),
                          Divider(
                            height: 1,
                            color: AppTheme.outlineVariant(isDark),
                          ),
                          _buildSettingTile(
                            appProvider.darkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            'Dark Mode',
                            'Change theme appearance',
                            appProvider.darkMode,
                            (value) => appProvider.setDarkMode(value),
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    // Menu Items
                    MinimalCard(
                      elevation: 2,
                      child: Column(
                        children: [
                          _buildMenuTile(
                            Icons.bar_chart,
                            'Statistics',
                            'View birthday analytics',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const StatisticsScreen(),
                                ),
                              );
                            },
                            isDark,
                          ),
                          Divider(
                            height: 1,
                            color: AppTheme.outlineVariant(isDark),
                          ),
                          _buildMenuTile(
                            Icons.settings,
                            'App Settings',
                            'Preferences & more',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            isDark,
                          ),
                          Divider(
                            height: 1,
                            color: AppTheme.outlineVariant(isDark),
                          ),
                          _buildMenuTile(
                            Icons.download,
                            'Export Data',
                            'Backup your birthdays',
                            () async {
                              final exportService = ExportImportService();
                              try {
                                await exportService.exportAndShare(
                                  birthdayProvider.birthdays,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Birthdays exported successfully!'),
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
                            },
                            isDark,
                          ),
                          Divider(
                            height: 1,
                            color: AppTheme.outlineVariant(isDark),
                          ),
                          _buildMenuTile(
                            Icons.security,
                            'Privacy & Security',
                            'Manage your data',
                            () {},
                            isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    // App Info
                    Text(
                      'BirthdayBuddy v1.0.0',
                      style: AppTheme.bodySmall(isDark).copyWith(
                        color: AppTheme.onSurfaceDisabled(isDark),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Privacy Policy',
                            style: AppTheme.bodySmall(isDark),
                          ),
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                              color: AppTheme.onSurfaceDisabled(isDark)),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Terms of Service',
                            style: AppTheme.bodySmall(isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.heading2(isDark).copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            label,
            style: AppTheme.bodySmall(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
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
        activeThumbColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.outline(isDark).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(
          icon,
          color: AppTheme.onSurfaceVariant(isDark),
          size: 20,
        ),
      ),
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
        color: AppTheme.onSurfaceDisabled(isDark),
      ),
      onTap: onTap,
    );
  }
}
