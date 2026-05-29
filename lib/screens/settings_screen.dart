import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';
import 'app_settings_screen.dart';
import 'data_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Settings',
          style: AppTheme.heading3(isDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Column(
              children: [
            // Navigation Settings Card
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
                  _buildNavigationTile(
                    icon: PhosphorIcons.gear(PhosphorIconsStyle.regular),
                    iconColor: AppTheme.beigeContainer(isDark),
                    iconBgColor: AppTheme.beigeContainer(isDark).withValues(alpha: 0.1),
                    title: 'App Settings',
                    subtitle: 'Preferences & more',
                    onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) => const AppSettingsScreen(),
                          ),
                        );
                      },
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: AppTheme.spacingMD),
                  Divider(height: 1, color: AppTheme.outline(isDark)),
                const SizedBox(height: AppTheme.spacingMD),
                  
                  _buildNavigationTile(
                    icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.regular),
                    iconColor: AppTheme.orangeContainer(isDark),
                    iconBgColor: AppTheme.orangeContainer(isDark).withValues(alpha: 0.1),
                    title: 'Privacy & Security',
                    subtitle: 'Manage your data',
                    onTap: () {
                      Navigator.push(
                              context,
                        MaterialPageRoute(
                          builder: (context) => const DataManagementScreen(),
                        ),
                      );
                    },
                    isDark: isDark,
                  ),
                ],
              ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Navigate to Privacy Policy
                      },
                      child: Text(
                        'Privacy Policy',
                        style: AppTheme.bodySmall(isDark).copyWith(
                          color: AppTheme.onSurfaceVariant(isDark),
                        ),
                      ),
                    ),
                    Text(
                      ' • ',
                      style: AppTheme.bodySmall(isDark).copyWith(
                        color: AppTheme.onSurfaceVariant(isDark),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Terms of Service
                      },
                      child: Text(
                        'Terms of Service',
                        style: AppTheme.bodySmall(isDark).copyWith(
                          color: AppTheme.onSurfaceVariant(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppTheme.spacingMD),
          
          // Title and Subtitle
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
          
          // Chevron Icon
          Icon(
            PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
            color: AppTheme.onSurfaceVariant(isDark),
            size: 20,
          ),
        ],
      ),
    );
  }
}
