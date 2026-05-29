import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

enum ThemeMode { light, dark, auto }

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _notificationSound = true;
  bool _vibration = true;
  bool _calendarSync = true;
  bool _autoBackup = false;
  bool _showAge = true;
  ThemeMode _selectedTheme = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      _notificationsEnabled = appProvider.notificationsEnabled;
      _selectedTheme = appProvider.useSystemTheme
          ? ThemeMode.auto
          : (appProvider.darkMode ? ThemeMode.dark : ThemeMode.light);
    });
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
          'App Settings',
          style: AppTheme.heading3(isDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          children: [
            // Appearance Section
            _buildSection(
              icon: PhosphorIcons.sun(PhosphorIconsStyle.regular),
              iconColor: AppTheme.primaryColor,
              title: 'Appearance',
              subtitle: 'Theme Mode',
              isDark: isDark,
              child: _buildThemeModeSelector(isDark),
            ),
            
            const SizedBox(height: AppTheme.spacingMD),
            
            // Notifications Section
            _buildSection(
              icon: PhosphorIcons.bell(PhosphorIconsStyle.regular),
              iconColor: AppTheme.blueContainer(isDark),
              title: 'Notifications',
              isDark: isDark,
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Enable Notifications',
                    subtitle: 'Get reminded about upcoming events',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                      Provider.of<AppProvider>(context, listen: false)
                          .setNotificationsEnabled(value);
                    },
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Notification Sound',
                    subtitle: 'Play sound with notifications',
                    value: _notificationSound,
                    onChanged: (value) => setState(() => _notificationSound = value),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Vibration',
                    subtitle: 'Vibrate on notifications',
                    value: _vibration,
                    onChanged: (value) => setState(() => _vibration = value),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMD),
            
            // Calendar & Sync Section
            _buildSection(
              icon: PhosphorIcons.calendar(PhosphorIconsStyle.regular),
              iconColor: AppTheme.orangeContainer(isDark),
              title: 'Calendar & Sync',
              isDark: isDark,
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Calendar Sync',
                    subtitle: 'Add events to device calendar',
                    value: _calendarSync,
                    onChanged: (value) => setState(() => _calendarSync = value),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Auto Backup',
                    subtitle: 'Automatically backup data weekly',
                    value: _autoBackup,
                    onChanged: (value) => setState(() => _autoBackup = value),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMD),
            
            // Display Section
            _buildSection(
              icon: PhosphorIcons.monitor(PhosphorIconsStyle.regular),
              iconColor: AppTheme.primaryColor,
              title: 'Display',
              isDark: isDark,
              child: _buildSwitchTile(
                title: 'Show Age',
                subtitle: 'Display age on birthday cards',
                value: _showAge,
                onChanged: (value) => setState(() => _showAge = value),
                isDark: isDark,
              ),
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
    String? subtitle,
    required Widget child,
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
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.bodySmall(isDark).copyWith(
                color: AppTheme.onSurfaceVariant(isDark),
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacingMD),
          child,
        ],
      ),
    );
  }

  Widget _buildThemeModeSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildThemeButton(
            icon: PhosphorIcons.sun(PhosphorIconsStyle.fill),
            label: 'Light',
            isSelected: _selectedTheme == ThemeMode.light,
            onTap: () {
              setState(() => _selectedTheme = ThemeMode.light);
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              appProvider.setUseSystemTheme(false);
              appProvider.setDarkMode(false);
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSM),
        Expanded(
          child: _buildThemeButton(
            icon: PhosphorIcons.moon(PhosphorIconsStyle.fill),
            label: 'Dark',
            isSelected: _selectedTheme == ThemeMode.dark,
            onTap: () {
              setState(() => _selectedTheme = ThemeMode.dark);
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              appProvider.setUseSystemTheme(false);
              appProvider.setDarkMode(true);
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSM),
        Expanded(
          child: _buildThemeButton(
            icon: PhosphorIcons.monitor(PhosphorIconsStyle.fill),
            label: 'Auto',
            isSelected: _selectedTheme == ThemeMode.auto,
            onTap: () {
              setState(() => _selectedTheme = ThemeMode.auto);
              Provider.of<AppProvider>(context, listen: false)
                  .setUseSystemTheme(true);
            },
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeButton({
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
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.outline(isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.onSurfaceVariant(isDark),
              size: 24,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              label,
              style: AppTheme.labelMedium(isDark).copyWith(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.onSurface(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  PhosphorIcons.check(PhosphorIconsStyle.fill),
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.labelLarge(isDark).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall(isDark).copyWith(
                    color: AppTheme.onSurfaceVariant(isDark),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),
            inactiveThumbColor: AppTheme.onSurfaceDisabled(isDark),
            inactiveTrackColor: AppTheme.outline(isDark),
          ),
        ],
      ),
    );
  }
}


