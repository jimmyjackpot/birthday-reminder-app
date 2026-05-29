import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ContactSyncProgressScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const ContactSyncProgressScreen({super.key, required this.onComplete});

  @override
  State<ContactSyncProgressScreen> createState() =>
      _ContactSyncProgressScreenState();
}

class _ContactSyncProgressScreenState extends State<ContactSyncProgressScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _simulateSync();
  }

  void _simulateSync() async {
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() => _progress = i / 100);
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer(isDark),
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
          child: Center(
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
                      Icons.sync_rounded,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLG),
                  Text(
                    'Syncing Contacts...',
                    style: AppTheme.heading2(isDark),
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppTheme.outline(isDark),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: AppTheme.heading3(isDark).copyWith(
                      color: AppTheme.onSurfaceVariant(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
