import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum Tab { home, calendar, statistics, profile }

class BottomNav extends StatelessWidget {
  final Tab activeTab;
  final Function(Tab) onTabChange;
  final VoidCallback onAddClick;

  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
    required this.onAddClick,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(isDark),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: AppTheme.elevatedShadow,
        border: Border(
          top: BorderSide(
            color: AppTheme.getBorderColor(isDark).withValues(alpha: 0.1),
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
              // Center: Add Button (FAB) - Highlighted with blue background
              Semantics(
                label: 'Add new birthday',
                button: true,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onAddClick();
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 28,
                        semanticLabel: 'Add new birthday',
                      ),
                    ),
                  ),
                ),
              ),
              // Item 4: Statistics
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

  Widget _buildNavItem(BuildContext context, IconData icon, String label, Tab tab) {
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
                color: isActive ? AppTheme.primaryColor : AppTheme.textTertiary,
                size: 24,
                semanticLabel: label,
              ),
              const SizedBox(height: AppTheme.spacingXS),
            Text(
              label,
              style: AppTheme.labelMedium(isDark).copyWith(
                color: isActive ? AppTheme.primaryColor : (isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary),
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
