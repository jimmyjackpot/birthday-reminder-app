import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/permission_service.dart';
import '../widgets/minimal_card.dart';

class PermissionsScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const PermissionsScreen({super.key, required this.onComplete});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final Map<String, bool> _permissions = {
    'contacts': false,
    'camera': false,
    'storage': false,
    'notifications': false,
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final statuses = await PermissionService.checkAllPermissions();
    setState(() {
      _permissions['contacts'] = statuses['contacts'] ?? false;
      _permissions['camera'] = statuses['camera'] ?? false;
      _permissions['storage'] = statuses['storage'] ?? false;
      _permissions['notifications'] = statuses['notifications'] ?? false;
    });
  }

  Future<void> _requestPermission(String permission) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    bool granted = false;
    try {
      switch (permission) {
        case 'contacts':
          granted = await PermissionService.requestContactsPermission(context);
          break;
        case 'camera':
          granted = await PermissionService.requestCameraPermission(context);
          break;
        case 'storage':
          granted = await PermissionService.requestStoragePermission(context);
          break;
        case 'notifications':
          granted =
              await PermissionService.requestNotificationPermission(context);
          break;
      }
    } catch (e) {
      debugPrint('Error requesting permission $permission: $e');
    }

    setState(() {
      _permissions[permission] = granted;
      _isLoading = false;
    });

    await _checkPermissions();
  }

  Future<void> _requestAllPermissions() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Request permissions one by one to ensure proper handling
      await PermissionService.requestContactsPermission(context);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      await PermissionService.requestCameraPermission(context);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      await PermissionService.requestStoragePermission(context);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      await PermissionService.requestNotificationPermission(context);
    } catch (e) {
      debugPrint('Error requesting all permissions: $e');
    }

    await _checkPermissions();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _permissions.values.every((granted) => granted);
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
          child: SingleChildScrollView(
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
                    Icons.security_rounded,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLG),
                Text(
                  'App Permissions',
                  style: AppTheme.heading2(isDark),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                Text(
                  'Grant permissions to use all features',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium(isDark).copyWith(
                    color: AppTheme.getTextSecondaryColor(isDark),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                _buildPermissionTile(
                  Icons.people_rounded,
                  'Contacts',
                  'Sync birthdays from your contacts',
                  _permissions['contacts'] ?? false,
                  () => _requestPermission('contacts'),
                  isDark,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                _buildPermissionTile(
                  Icons.camera_alt_rounded,
                  'Camera',
                  'Take photos for birthdays',
                  _permissions['camera'] ?? false,
                  () => _requestPermission('camera'),
                  isDark,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                _buildPermissionTile(
                  Icons.photo_library_rounded,
                  'Storage/Photos',
                  'Select photos from gallery',
                  _permissions['storage'] ?? false,
                  () => _requestPermission('storage'),
                  isDark,
                ),
                const SizedBox(height: AppTheme.spacingSM),
                _buildPermissionTile(
                  Icons.notifications_rounded,
                  'Notifications',
                  'Receive birthday reminders',
                  _permissions['notifications'] ?? false,
                  () => _requestPermission('notifications'),
                  isDark,
                ),
                const SizedBox(height: AppTheme.spacingLG),
                if (!allGranted)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _requestAllPermissions,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMD),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Request All Permissions',
                              style: AppTheme.labelLarge(isDark),
                            ),
                    ),
                  ),
                const SizedBox(height: AppTheme.spacingSM),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMD),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: AppTheme.labelLarge(isDark)
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSM),
                TextButton(
                  onPressed: widget.onComplete,
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

  Widget _buildPermissionTile(
    IconData icon,
    String title,
    String subtitle,
    bool isGranted,
    VoidCallback onTap,
    bool isDark,
  ) {
    return MinimalCard(
      elevation: 2,
      padding: const EdgeInsets.all(AppTheme.spacingSM),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isGranted
                ? AppTheme.successColor.withValues(alpha: 0.1)
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(
            icon,
            color: isGranted ? AppTheme.successColor : AppTheme.primaryColor,
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
        trailing: isGranted
            ? const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
              )
            : Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.getTextTertiaryColor(isDark),
              ),
        onTap: isGranted ? null : onTap,
      ),
    );
  }
}
