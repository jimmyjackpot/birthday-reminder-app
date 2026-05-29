import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MinimalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? shadow;
  final double? elevation; // 0 = subtle, 1 = card, 2 = elevated, 3 = floating

  const MinimalCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.shadow,
    this.elevation,
  });

  List<BoxShadow> _getShadow(BuildContext context) {
    if (shadow != null) return shadow!;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elevationLevel = elevation ?? 1.0;

    if (elevationLevel == 0) {
      return AppTheme.subtleShadow(isDark);
    } else if (elevationLevel == 1) {
      return AppTheme.cardShadow(isDark);
    } else if (elevationLevel == 2) {
      return AppTheme.elevatedShadow(isDark);
    } else {
      return AppTheme.floatingShadow(isDark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surface(isDark),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: _getShadow(context),
        border: Border.all(
          color: AppTheme.outline(isDark).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingMD),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: card,
        ),
      );
    }

    return card;
  }
}
