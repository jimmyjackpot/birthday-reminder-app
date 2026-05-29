import 'package:flutter/material.dart';
import '../widgets/onboarding_page.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.cake_outlined,
      'title': 'Never Miss a Birthday',
      'description': 'Keep track of all your loved ones\' birthdays and get timely reminders so you never forget to celebrate.',
      'color': AppTheme.primaryColor,
    },
    {
      'icon': Icons.notifications_outlined,
      'title': 'Smart Reminders',
      'description': 'Get notified before birthdays so you have time to prepare. Customize when and how you want to be reminded.',
      'color': AppTheme.secondaryColor,
    },
    {
      'icon': Icons.people_outline,
      'title': 'Sync with Contacts',
      'description': 'Automatically import birthdays from your contacts or add them manually. Your data stays private and secure.',
      'color': AppTheme.accentColor,
    },
    {
      'icon': Icons.calendar_today_outlined,
      'title': 'Beautiful Calendar View',
      'description': 'View all birthdays in a beautiful calendar format. See what\'s coming up this month at a glance.',
      'color': AppTheme.primaryColor,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: AppTheme.labelLarge(isDark).copyWith(
                      color: AppTheme.onSurfaceVariant(isDark),
                    ),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingPage(
                    icon: page['icon'] as IconData,
                    title: page['title'] as String,
                    description: page['description'] as String,
                    iconColor: page['color'] as Color,
                  );
                },
              ),
            ),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? AppTheme.primaryColor
                        : AppTheme.onSurfaceDisabled(isDark),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLG),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'Back',
                        style: AppTheme.labelLarge(isDark),
                      ),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLG,
                        vertical: AppTheme.spacingMD,
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: AppTheme.labelLarge(isDark).copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

