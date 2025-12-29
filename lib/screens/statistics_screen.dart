import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/birthday_provider.dart';

import '../theme/app_theme.dart';
import '../widgets/minimal_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayProvider>(
      builder: (context, provider, child) {
        final birthdays = provider.birthdays;
        final upcoming = provider.getUpcomingBirthdays();
        final thisMonth = birthdays.where((b) {
          final now = DateTime.now();
          return b.birthdate.month == now.month;
        }).length;
        final thisWeek = birthdays.where((b) {
          return b.daysUntil >= 0 && b.daysUntil <= 7;
        }).length;
        final today = birthdays.where((b) => b.daysUntil == 0).length;

        // Group by month
        final byMonth = <int, int>{};
        for (var birthday in birthdays) {
          byMonth[birthday.birthdate.month] =
              (byMonth[birthday.birthdate.month] ?? 0) + 1;
        }

        // Find most common month
        int? mostCommonMonth;
        int maxCount = 0;
        byMonth.forEach((month, count) {
          if (count > maxCount) {
            maxCount = count;
            mostCommonMonth = month;
          }
        });

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(isDark),
          appBar: AppBar(
            backgroundColor: AppTheme.getSurfaceColor(isDark),
            elevation: 0,
            title: Text(
              'Statistics',
              style: AppTheme.heading3(isDark),
            ),
          ),
          body: SafeArea(
            child: birthdays.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 64,
                          color: AppTheme.getTextTertiaryColor(isDark),
                        ),
                        const SizedBox(height: AppTheme.spacingMD),
                        Text(
                          'No Statistics Yet',
                          style: AppTheme.heading3(isDark),
                        ),
                        const SizedBox(height: AppTheme.spacingSM),
                        Text(
                          'Add birthdays to see statistics',
                          style: AppTheme.bodyMedium(isDark).copyWith(
                            color: AppTheme.getTextSecondaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total',
                                birthdays.length.toString(),
                                AppTheme.primaryColor,
                                Icons.cake,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingSM),
                            Expanded(
                              child: _buildStatCard(
                                'Upcoming',
                                upcoming.length.toString(),
                                AppTheme.secondaryColor,
                                Icons.upcoming,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingSM),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'This Month',
                                thisMonth.toString(),
                                AppTheme.accentColor,
                                Icons.calendar_month,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingSM),
                            Expanded(
                              child: _buildStatCard(
                                'This Week',
                                thisWeek.toString(),
                                AppTheme.warningColor,
                                Icons.date_range,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                        if (today > 0) ...[
                          const SizedBox(height: AppTheme.spacingSM),
                          _buildStatCard(
                            'Today',
                            today.toString(),
                            AppTheme.errorColor,
                            Icons.celebration,
                            isDark,
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacingXL),
                        // Birthdays by Month
                        Text(
                          'Birthdays by Month',
                          style: AppTheme.heading3(isDark),
                        ),
                        const SizedBox(height: AppTheme.spacingMD),
                        MinimalCard(
                          elevation: 1,
                          child: Column(
                            children: List.generate(12, (index) {
                              final month = index + 1;
                              final count = byMonth[month] ?? 0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppTheme.spacingSM),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getMonthName(month),
                                        style: AppTheme.labelLarge(isDark),
                                      ),
                                    ),
                                    Text(
                                      count.toString(),
                                      style: AppTheme.heading3(isDark).copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spacingMD),
                                    Expanded(
                                      flex: 2,
                                      child: LinearProgressIndicator(
                                        value: birthdays.isEmpty
                                            ? 0
                                            : count / birthdays.length,
                                        backgroundColor:
                                            AppTheme.getBorderColor(isDark),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        if (mostCommonMonth != null) ...[
                          const SizedBox(height: AppTheme.spacingLG),
                          MinimalCard(
                            elevation: 1,
                            backgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingMD),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppTheme.primaryColor,
                                    size: 32,
                                  ),
                                  const SizedBox(width: AppTheme.spacingMD),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Most Common Month',
                                          style: AppTheme.bodySmall(isDark),
                                        ),
                                        Text(
                                          _getMonthName(mostCommonMonth!),
                                          style: AppTheme.heading3(isDark),
                                        ),
                                        Text(
                                          '$maxCount birthdays',
                                          style: AppTheme.bodyMedium(isDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon, bool isDark) {
    return MinimalCard(
      elevation: 2,
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      backgroundColor: color.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            value,
            style: AppTheme.heading2(isDark).copyWith(
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodySmall(isDark),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
