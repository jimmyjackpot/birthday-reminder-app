import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/birthday_provider.dart';
import '../models/birthday.dart';
import '../widgets/birthday_card.dart';
import '../widgets/wish_dialog.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_widget.dart';
import '../utils/animations.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import 'birthday_detail_screen.dart';
import 'birthday_form_screen.dart';
import 'calendar_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onAddBirthday;

  const HomeScreen({super.key, required this.onAddBirthday});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _debouncedSearchQuery = '';
  bool _isListView = true;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() => _debouncedSearchQuery = value);
      if (value.isNotEmpty) {
        AnalyticsService().logSearch(query: value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Show loading state
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: AppTheme.surfaceContainer(isDark),
            body: SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                itemCount: 5,
                itemBuilder: (context, index) => const BirthdayCardShimmer(),
              ),
            ),
          );
        }

        // Show error state
        if (provider.error != null && provider.birthdays.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.surfaceContainer(isDark),
            body: SafeArea(
              child: ErrorDisplay(
                title: 'Failed to Load Birthdays',
                message: provider.error!.userFriendlyMessage,
                onRetry: () => provider.retryLoad(),
              ),
            ),
          );
        }

        final birthdays = _debouncedSearchQuery.isEmpty
            ? provider.getUpcomingBirthdays()
            : provider.searchBirthdays(_debouncedSearchQuery);

        return Scaffold(
          backgroundColor: AppTheme.surfaceContainer(isDark),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  decoration: BoxDecoration(
                    color: AppTheme.surface(isDark),
                    boxShadow: AppTheme.cardShadow(isDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Upcoming Birthdays',
                          style: AppTheme.heading2(isDark),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMD),
                      // Search Bar
                      TextField(
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search birthdays...',
                          hintStyle: AppTheme.bodyMedium(isDark).copyWith(
                            color: AppTheme.onSurfaceDisabled(isDark),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppTheme.onSurfaceDisabled(isDark),
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceContainer(isDark),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMD,
                            vertical: AppTheme.spacingMD,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSM),
                      // View Toggle
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingXS),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer(isDark),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildToggleButton(
                                'List',
                                Icons.view_list_rounded,
                                _isListView,
                                () => setState(() => _isListView = true),
                              ),
                            ),
                            Expanded(
                              child: _buildToggleButton(
                                'Calendar',
                                Icons.calendar_today_rounded,
                                !_isListView,
                                () => setState(() => _isListView = false),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _isListView
                      ? RefreshIndicator(
                          onRefresh: () async {
                            await provider.retryLoad();
                          },
                          child: _buildListView(birthdays, provider),
                        )
                      : CalendarViewScreen(
                          birthdays: birthdays,
                          onBirthdayTap: (birthday) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BirthdayDetailScreen(
                                  birthday: birthday,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: widget.onAddBirthday,
            backgroundColor: AppTheme.primaryColor,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildToggleButton(
    String label,
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM + 2),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.surface(isDark) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          boxShadow: isActive ? AppTheme.cardShadow(isDark) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? AppTheme.primaryColor
                  : AppTheme.onSurfaceDisabled(isDark),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Flexible(
              child: Text(
                label,
                style: AppTheme.labelMedium(isDark).copyWith(
                  color: isActive
                      ? AppTheme.primaryColor
                      : AppTheme.onSurfaceDisabled(isDark),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Birthday> birthdays, BirthdayProvider provider) {
    if (birthdays.isEmpty) {
      return EmptyState(
        icon: _searchQuery.isEmpty
            ? Icons.cake_outlined
            : Icons.search_off_outlined,
        title: _searchQuery.isEmpty ? 'No Birthdays Yet' : 'No Results Found',
        message: _searchQuery.isEmpty
            ? 'Start by adding your first birthday to get reminders and never miss a special day!'
            : 'Try adjusting your search terms or add a new birthday.',
        actionLabel: _searchQuery.isEmpty ? 'Add Birthday' : null,
        onAction: _searchQuery.isEmpty ? widget.onAddBirthday : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      itemCount: birthdays.length,
      itemBuilder: (context, index) {
        final birthday = birthdays[index];
        return AppAnimations.fadeIn(
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: BirthdayCard(
            birthday: birthday,
            onTap: () {
              Navigator.push(
                context,
                AppAnimations.slideRoute(
                  BirthdayDetailScreen(birthday: birthday),
                ),
              );
            },
            onEdit: () {
              Navigator.push(
                context,
                AppAnimations.slideRoute(
                  BirthdayFormScreen(birthday: birthday),
                ),
              );
            },
            onDelete: () {
              _showDeleteDialog(context, provider, birthday);
            },
            onWish: () {
              showDialog(
                context: context,
                builder: (context) => WishDialog(birthday: birthday),
              );
            },
            onShare: () {
              AnalyticsService().logBirthdayShared();
              final message =
                  '${birthday.name}\'s birthday is on ${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}! 🎉\n\n${birthday.daysUntil == 0 ? "Today is their birthday!" : birthday.daysUntil == 1 ? "Tomorrow!" : "In ${birthday.daysUntil} days!"}';
              Share.share(
                message,
                subject: '${birthday.name}\'s Birthday',
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    BirthdayProvider provider,
    Birthday birthday,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text('Delete Birthday', style: AppTheme.heading3(isDark)),
        content: Text(
          'Are you sure you want to delete ${birthday.name}?',
          style: AppTheme.bodyMedium(isDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.labelLarge(isDark)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteBirthday(birthday.id);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: AppTheme.labelLarge(isDark)
                  .copyWith(color: AppTheme.errorColor),
            ),
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
