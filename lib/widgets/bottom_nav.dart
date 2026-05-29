import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum Tab { home, calendar, statistics, profile }

class BottomNav extends StatelessWidget {
  final Tab activeTab;
  final Function(Tab) onTabChange;

  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(isDark),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: AppTheme.elevatedShadow(isDark),
        border: Border(
          top: BorderSide(
            color: AppTheme.outline(isDark).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Item 1: Home
              Expanded(
                child: _buildNavItem(
                  context,
                  Icons.cake_outlined,
                  'Home',
                  Tab.home,
                ),
              ),
              // Item 2: Calendar
              Expanded(
                child: _buildNavItem(
                  context,
                  Icons.event_outlined,
                  'Calendar',
                  Tab.calendar,
                ),
              ),
              // Item 3: Statistics
              Expanded(
                child: _buildNavItem(
                  context,
                  Icons.insights_outlined,
                  'Stats',
                  Tab.statistics,
                ),
              ),
              // Item 5: Profile
              Expanded(
                child: _buildNavItem(
                  context,
                  Icons.account_circle_outlined,
                  'Profile',
                  Tab.profile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, Tab tab) {
    final isActive = activeTab == tab;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: label,
      selected: isActive,
      button: true,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTabChange(tab);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? AppTheme.primaryColor
                    : AppTheme.onSurfaceDisabled(isDark),
                size: 24,
                semanticLabel: label,
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                label,
                style: AppTheme.labelMedium(isDark).copyWith(
                  color: isActive
                      ? AppTheme.primaryColor
                      : AppTheme.onSurfaceDisabled(isDark),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
