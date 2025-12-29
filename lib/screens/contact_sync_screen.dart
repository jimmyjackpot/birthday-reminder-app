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
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people_rounded,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLG),
                Text(
                  'Sync Your Contacts',
                  style: AppTheme.heading2(isDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                Text(
                  'Import birthdays from your contacts automatically',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium(isDark).copyWith(
                    color: AppTheme.getTextSecondaryColor(isDark),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSync,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMD,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
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
                            'Enable Sync',
                            style: AppTheme.labelLarge(isDark).copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                TextButton(
                  onPressed: _isLoading ? null : widget.onSkip,
                  child: Text(
                    'Skip for now',
                    style: AppTheme.labelLarge(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
