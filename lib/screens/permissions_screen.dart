import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';
import '../services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const PermissionsScreen({super.key, required this.onComplete});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  final Map<String, bool> _permissions = {
    'notifications': false,
    'calendar': false,
    'camera': false,
    'storage': false,
    'contacts': false,
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Re-check permissions when app resumes (user returns from settings)
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _checkPermissions();
        }
      });
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final statuses = await PermissionService.checkAllPermissions();
      setState(() {
        _permissions['notifications'] = statuses['notifications'] ?? false;
        _permissions['calendar'] = statuses['calendar'] ?? false;
        _permissions['camera'] = statuses['camera'] ?? false;
        _permissions['storage'] = statuses['storage'] ?? false;
        _permissions['contacts'] = statuses['contacts'] ?? false;
      });
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      // Re-check calendar permission separately if there's an error
      try {
        final calendarGranted =
            await PermissionService.isCalendarPermissionGranted();
        setState(() {
          _permissions['calendar'] = calendarGranted;
        });
      } catch (e2) {
        debugPrint('Error checking calendar permission: $e2');
      }
    }
  }

  Future<void> _requestPermission(String permission) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    bool granted = false;
    String? errorMessage;

    try {
      switch (permission) {
        case 'notifications':
          granted =
              await PermissionService.requestNotificationPermission(context);
          break;
        case 'calendar':
          granted = await PermissionService.requestCalendarPermission(context);
          if (!granted && context.mounted) {
            // Check if permission is available on this platform
            try {
              final status = await Permission.calendarFullAccess.status;
              if (status.isPermanentlyDenied) {
                errorMessage =
                    'Calendar permission was denied. Please enable it in app settings.';
              }
            } catch (e) {
              errorMessage =
                  'Calendar permission is not available on this device.';
            }
          }
          break;
        case 'camera':
          granted = await PermissionService.requestCameraPermission(context);
          break;
        case 'storage':
          granted = await PermissionService.requestStoragePermission(context);
          break;
        case 'contacts':
          granted = await PermissionService.requestContactsPermission(context);
          break;
      }
    } catch (e) {
      debugPrint('Error requesting permission $permission: $e');
      errorMessage = 'Failed to request permission. Please try again.';
    }

    // Wait a bit for permission status to update
    await Future.delayed(const Duration(milliseconds: 500));

    // Re-check the permission status to ensure it's accurate
    await _checkPermissions();

    // Get the updated status
    final updatedStatus = _permissions[permission] ?? false;

    setState(() {
      _permissions[permission] = updatedStatus;
      _isLoading = false;
    });

    // Show success or error message
    if (!mounted) return;

    if (updatedStatus) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_getPermissionName(permission)} permission granted successfully!',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (errorMessage != null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.warningColor,
          duration: const Duration(seconds: 3),
          action: permission == 'calendar' && errorMessage.contains('settings')
              ? SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: () async {
                    if (context.mounted) {
                      await openAppSettings();
                    }
                  },
                )
              : null,
        ),
      );
    }
  }

  String _getPermissionName(String permission) {
    switch (permission) {
      case 'notifications':
        return 'Notifications';
      case 'calendar':
        return 'Calendar';
      case 'camera':
        return 'Camera';
      case 'storage':
        return 'Storage';
      case 'contacts':
        return 'Contacts';
      default:
        return 'Permission';
    }
  }

  Future<void> _requestAllRequiredPermissions() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    int grantedCount = 0;
    int totalCount = 4;

    try {
      // Request required permissions: Notifications, Calendar, Camera, Storage
      if (await PermissionService.requestNotificationPermission(context)) {
        grantedCount++;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      if (await PermissionService.requestCalendarPermission(context)) {
        grantedCount++;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      if (await PermissionService.requestCameraPermission(context)) {
        grantedCount++;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      if (await PermissionService.requestStoragePermission(context)) {
        grantedCount++;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    } catch (e) {
      debugPrint('Error requesting all permissions: $e');
    }

    // Wait a bit more for all permissions to update
    await Future.delayed(const Duration(milliseconds: 500));

    // Re-check all permissions to get accurate status
    await _checkPermissions();

    if (mounted) {
      setState(() => _isLoading = false);

      // Show summary message
      final allGranted = (_permissions['notifications'] ?? false) &&
          (_permissions['calendar'] ?? false) &&
          (_permissions['camera'] ?? false) &&
          (_permissions['storage'] ?? false);

      if (allGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'All required permissions granted successfully!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$grantedCount of $totalCount permissions granted. Please grant the remaining permissions.',
            ),
            backgroundColor: AppTheme.warningColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final requiredGranted = (_permissions['notifications'] ?? false) &&
        (_permissions['calendar'] ?? false) &&
        (_permissions['camera'] ?? false) &&
        (_permissions['storage'] ?? false);

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLG,
            vertical: AppTheme.spacingXL,
          ),
          child: Column(
            children: [
              // Gradient Shield Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF6B9D), // Pink
                      Color(0xFFFFE66D), // Yellow
                      Color(0xFF4ECDC4), // Teal
                      Color(0xFF4A90E2), // Blue
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  PhosphorIcons.shieldCheck(PhosphorIconsStyle.regular),
                  size: 64,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppTheme.spacingLG),

              // Title
              Text(
                'App Permissions',
                style: AppTheme.heading1(isDark).copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.spacingSM),

              // Subtitle
              Text(
                'Grant permissions to unlock the full BirthdayBuddy experience',
                style: AppTheme.bodyMedium(isDark).copyWith(
                  color: AppTheme.onSurfaceVariant(isDark),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // Notifications Permission Card (REQUIRED)
              _buildPermissionCard(
                icon: PhosphorIcons.bell(PhosphorIconsStyle.regular),
                iconColor: AppTheme.primaryColor,
                iconBgColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                title: 'Notifications',
                description: 'Get reminded before birthdays & anniversaries',
                isRequired: true,
                isGranted: _permissions['notifications'] ?? false,
                onTap: () => _requestPermission('notifications'),
                isDark: isDark,
              ),

              const SizedBox(height: AppTheme.spacingMD),

              // Calendar Access Permission Card (REQUIRED)
              _buildPermissionCard(
                icon: PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                iconColor: AppTheme.blueContainer(isDark),
                iconBgColor:
                    AppTheme.blueContainer(isDark).withValues(alpha: 0.1),
                title: 'Calendar Access',
                description: 'Sync events to your device calendar',
                isRequired: true,
                isGranted: _permissions['calendar'] ?? false,
                onTap: () => _requestPermission('calendar'),
                isDark: isDark,
              ),

              const SizedBox(height: AppTheme.spacingMD),

              // Camera Permission Card (REQUIRED)
              _buildPermissionCard(
                icon: PhosphorIcons.camera(PhosphorIconsStyle.regular),
                iconColor: AppTheme.primaryColor,
                iconBgColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                title: 'Camera',
                description: 'Take photos for birthdays',
                isRequired: true,
                isGranted: _permissions['camera'] ?? false,
                onTap: () => _requestPermission('camera'),
                isDark: isDark,
              ),

              const SizedBox(height: AppTheme.spacingMD),

              // Gallery/Storage Permission Card (REQUIRED)
              _buildPermissionCard(
                icon: PhosphorIcons.images(PhosphorIconsStyle.regular),
                iconColor: AppTheme.blueContainer(isDark),
                iconBgColor:
                    AppTheme.blueContainer(isDark).withValues(alpha: 0.1),
                title: 'Gallery Access',
                description: 'Select photos from gallery',
                isRequired: true,
                isGranted: _permissions['storage'] ?? false,
                onTap: () => _requestPermission('storage'),
                isDark: isDark,
              ),

              const SizedBox(height: AppTheme.spacingMD),

              // Contacts Access Permission Card (Optional)
              _buildPermissionCard(
                icon: PhosphorIcons.users(PhosphorIconsStyle.regular),
                iconColor: AppTheme.orangeContainer(isDark),
                iconBgColor:
                    AppTheme.orangeContainer(isDark).withValues(alpha: 0.1),
                title: 'Contacts Access',
                description: 'Import birthdays from your contacts',
                isRequired: false,
                isGranted: _permissions['contacts'] ?? false,
                onTap: () => _requestPermission('contacts'),
                isDark: isDark,
              ),

              const SizedBox(height: AppTheme.spacingLG),

              // Privacy Statement Card
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                decoration: BoxDecoration(
                  color: AppTheme.pinkContainer(isDark),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PhosphorIcons.info(PhosphorIconsStyle.regular),
                        size: 20,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Privacy Matters',
                            style: AppTheme.labelLarge(isDark).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All data stays on your device. We never share your information with third parties.',
                            style: AppTheme.bodySmall(isDark).copyWith(
                              color: AppTheme.onSurfaceVariant(isDark),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXL),

              // Grant All Required Permissions Button
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
                    onPressed: _isLoading || requiredGranted
                        ? null
                        : _requestAllRequiredPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMD + 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLarge),
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
                            'Grant All Required Permissions',
                            style: AppTheme.labelLarge(isDark).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingMD),

              // Skip Button
              TextButton(
                onPressed: widget.onComplete,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLG,
                    vertical: AppTheme.spacingSM,
                  ),
                ),
                child: Text(
                  'Skip for Now',
                  style: AppTheme.labelLarge(isDark).copyWith(
                    color: AppTheme.onSurface(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required bool isRequired,
    required bool isGranted,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surface(isDark),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.outline(isDark),
          width: 1,
        ),
        boxShadow: AppTheme.cardShadow(isDark),
      ),
      child: Row(
        children: [
          // Icon Circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),

          const SizedBox(width: AppTheme.spacingMD),

          // Title and Description - Use Expanded to prevent overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      title,
                      style: AppTheme.labelLarge(isDark).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'REQUIRED',
                          style: AppTheme.labelSmall(false).copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.bodySmall(isDark).copyWith(
                    color: AppTheme.onSurfaceVariant(isDark),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppTheme.spacingSM),

          // Grant Permission Button or Check Icon
          if (!isGranted)
            Container(
              constraints: const BoxConstraints(
                minWidth: 60,
                maxWidth: 80,
              ),
              decoration: BoxDecoration(
                gradient: isRequired ? AppTheme.contactSyncGradient : null,
                color: isRequired
                    ? null
                    : AppTheme.orangeContainer(isDark).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: AppTheme.spacingSM,
                    ),
                    child: Text(
                      'Grant',
                      style: AppTheme.labelMedium(isDark).copyWith(
                        color: isRequired
                            ? Colors.white
                            : AppTheme.onSurface(isDark),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: AppTheme.successColor,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
