import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppTheme.errorColor : AppTheme.errorColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 48,
                color: iconColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            if (title != null) ...[
              Text(
                title!,
                style: AppTheme.heading3(isDark).copyWith(
                  color: AppTheme.onSurface(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSM),
            ],
            Text(
              message,
              style: AppTheme.bodyMedium(isDark).copyWith(
                color: AppTheme.onSurfaceVariant(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacingLG),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLG,
                    vertical: AppTheme.spacingMD,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

