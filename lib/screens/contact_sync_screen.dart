import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/birthday_provider.dart';
import '../services/contact_sync_service.dart';
import '../services/permission_service.dart';
import '../services/error_handler.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';

class ContactSyncScreen extends StatefulWidget {
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  const ContactSyncScreen({
    super.key,
    required this.onEnable,
    required this.onSkip,
  });

  @override
  State<ContactSyncScreen> createState() => _ContactSyncScreenState();
}

class _ContactSyncScreenState extends State<ContactSyncScreen> {
  final ContactSyncService _contactSyncService = ContactSyncService();
  bool _isLoading = false;

  Future<void> _handleSync() async {
    setState(() => _isLoading = true);

    try {
      // Request contacts permission
      final hasPermission =
          await PermissionService.requestContactsPermission(context);
      if (!hasPermission) {
        setState(() => _isLoading = false);
        return;
      }

      if (!mounted) {
        setState(() => _isLoading = false);
        return;
      }

      final provider = Provider.of<BirthdayProvider>(context, listen: false);
      final birthdays = await _contactSyncService.syncContacts();

      if (birthdays.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No birthdays found in your contacts. Make sure your contacts have birthday information set.'),
              backgroundColor: AppTheme.warningColor,
              duration: Duration(seconds: 4),
            ),
          );
          // Still proceed to next screen
          widget.onEnable();
        }
        return;
      }

      // Add birthdays that don't already exist
      int addedCount = 0;
      int skippedCount = 0;

      for (var birthday in birthdays) {
        final exists = provider.birthdays.any((b) =>
            b.name == birthday.name &&
            b.birthdate.day == birthday.birthdate.day &&
            b.birthdate.month == birthday.birthdate.month);
        if (!exists) {
          await provider.addBirthday(birthday);
          addedCount++;
        } else {
          skippedCount++;
        }
      }

      if (mounted) {
        AnalyticsService().logContactSync(count: birthdays.length);

        String message;
        if (addedCount > 0 && skippedCount > 0) {
          message =
              'Added $addedCount new birthday${addedCount != 1 ? 's' : ''}. $skippedCount already existed.';
        } else if (addedCount > 0) {
          message =
              'Synced $addedCount birthday${addedCount != 1 ? 's' : ''} from contacts!';
        } else {
          message = 'All birthdays from contacts already exist.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                addedCount > 0 ? AppTheme.successColor : AppTheme.warningColor,
            duration: const Duration(seconds: 3),
          ),
        );
        widget.onEnable();
      }
    } catch (e, stackTrace) {
      final error = ErrorHandler.handleError(e, stackTrace);
      error.log();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.userFriendlyMessage),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleSync,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer(isDark),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLG,
            vertical: AppTheme.spacingXL,
          ),
          child: Column(
            children: [
              const Spacer(),
              
              // Gradient Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.contactSyncGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.people_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingLG),
              
              // Title
              Text(
                'Sync Your Contacts',
                style: AppTheme.heading1(false).copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingSM),
              
              // Subtitle
              Text(
                'Import birthdays from your device contacts to never miss a celebration',
                style: AppTheme.bodyMedium(false).copyWith(
                  color: AppTheme.onSurfaceVariant(isDark),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Feature Card
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingLG),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(
                    color: AppTheme.outline(isDark),
                    width: 1,
                  ),
                  boxShadow: AppTheme.cardShadow(isDark),
                ),
                child: Column(
                  children: [
                    // Automatic Import
                    _buildFeatureItem(
                      icon: Icons.check_circle_outline,
                      iconColor: AppTheme.primaryColor,
                      title: 'Automatic Import',
                      description: 'Instantly import birthdays from contact list',
                      borderColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                      isDark: isDark,
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMD),
                    Divider(height: 1, color: AppTheme.outlineVariant(isDark)),
                    const SizedBox(height: AppTheme.spacingMD),
                    
                    // Stay Updated
                    _buildFeatureItem(
                      icon: Icons.sync,
                      iconColor: AppTheme.secondaryColor,
                      title: 'Stay Updated',
                      description: 'Sync automatically when contacts change',
                      borderColor: AppTheme.secondaryColor.withValues(alpha: 0.3),
                      isDark: isDark,
                    ),
                    
                    const SizedBox(height: AppTheme.spacingMD),
                    Divider(height: 1, color: AppTheme.outlineVariant(isDark)),
                    const SizedBox(height: AppTheme.spacingMD),
                    
                    // Privacy First
                    _buildFeatureItem(
                      icon: Icons.info_outline,
                      iconColor: AppTheme.accentColor,
                      title: 'Privacy First',
                      description: 'Only birthday information is accessed',
                      borderColor: AppTheme.accentColor.withValues(alpha: 0.3),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Enable Contact Sync Button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.contactSyncGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSync,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMD + 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Enable Contact Sync',
                            style: AppTheme.labelLarge(false).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingMD),
              
              // Skip Button
              TextButton(
                onPressed: _isLoading ? null : widget.onSkip,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLG,
                    vertical: AppTheme.spacingSM,
                  ),
                ),
                child: Text(
                  'Skip for Now',
                  style: AppTheme.labelLarge(false).copyWith(
                    color: AppTheme.onSurface(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingLG),
              
              // Footer Text
              Text(
                'You can enable or disable this feature anytime in settings',
                style: AppTheme.bodySmall(false).copyWith(
                  color: AppTheme.onSurfaceVariant(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required Color borderColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        // Icon Container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.surface(isDark),
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        
        const SizedBox(width: AppTheme.spacingMD),
        
        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.labelLarge(false).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface(isDark),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTheme.bodySmall(false).copyWith(
                  color: AppTheme.onSurfaceVariant(isDark),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

