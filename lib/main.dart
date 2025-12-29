import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/birthday_provider.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/contact_sync_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/calendar_view_screen.dart';
import 'screens/birthday_detail_screen.dart';
import 'screens/birthday_form_screen.dart';
import 'utils/animations.dart';
import 'widgets/bottom_nav.dart' as bottom_nav;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  
  // Initialize analytics
  AnalyticsService().logAppOpened();
  
  // Request notification permission on app start
  // This will be handled in the permissions screen, but we initialize here
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Listen to brightness changes
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      _updateThemeFromSystem();
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateThemeFromSystem() {
    // This will be handled in the Consumer builder
    // No need to access provider here
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => BirthdayProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // Update theme from system if enabled
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (appProvider.useSystemTheme) {
              final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
              appProvider.updateThemeFromSystem(brightness);
            }
          });
          
          // Set up brightness change listener
          WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
            if (appProvider.useSystemTheme) {
              final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
              appProvider.updateThemeFromSystem(brightness);
            }
          };
          
          return MaterialApp(
            title: 'Birthday Reminder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.useSystemTheme
                ? ThemeMode.system
                : (appProvider.darkMode ? ThemeMode.dark : ThemeMode.light),
            home: const AppNavigator(),
          );
        },
      ),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final Set<String> _loggedScreens = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Splash Screen
        if (appProvider.currentScreen == AppScreen.splash) {
          return SplashScreen(
            onComplete: () {
              // Check if onboarding is needed
              if (!appProvider.hasCompletedOnboarding) {
                appProvider.setScreen(AppScreen.onboarding);
              } else {
                appProvider.setScreen(AppScreen.permissions);
              }
            },
          );
        }

        // Onboarding Screen
        if (appProvider.currentScreen == AppScreen.onboarding) {
          if (!_loggedScreens.contains('onboarding')) {
            _loggedScreens.add('onboarding');
            AnalyticsService().logScreenView('onboarding');
          }
          return OnboardingScreen(
            onComplete: () async {
              await appProvider.completeOnboarding();
              AnalyticsService().logOnboardingCompleted();
              appProvider.setScreen(AppScreen.permissions);
            },
          );
        }

        // Permissions Screen
        if (appProvider.currentScreen == AppScreen.permissions) {
          if (!_loggedScreens.contains('permissions')) {
            _loggedScreens.add('permissions');
            AnalyticsService().logScreenView('permissions');
          }
          return PermissionsScreen(
            onComplete: () {
              appProvider.setScreen(AppScreen.contactSync);
            },
          );
        }

        // Contact Sync Screen
        if (appProvider.currentScreen == AppScreen.contactSync) {
          return ContactSyncScreen(
            onEnable: () {
              // Go directly to main after sync completes
              appProvider.setScreen(AppScreen.main);
            },
            onSkip: () {
              appProvider.setScreen(AppScreen.main);
            },
          );
        }

        // Main App
        return const MainScreen();
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, BirthdayProvider>(
      builder: (context, appProvider, birthdayProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(isDark),
          body: Stack(
            children: [
              // Main Content
              _buildCurrentScreen(context, appProvider, birthdayProvider),
              // Bottom Navigation
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: bottom_nav.BottomNav(
                  activeTab: appProvider.activeTab == AppTab.home
                      ? bottom_nav.Tab.home
                      : appProvider.activeTab == AppTab.calendar
                          ? bottom_nav.Tab.calendar
                          : appProvider.activeTab == AppTab.statistics
                              ? bottom_nav.Tab.statistics
                              : bottom_nav.Tab.profile,
                  onTabChange: (tab) {
                    String tabName = '';
                    if (tab == bottom_nav.Tab.home) {
                      appProvider.setActiveTab(AppTab.home);
                      tabName = 'home';
                    } else if (tab == bottom_nav.Tab.calendar) {
                      appProvider.setActiveTab(AppTab.calendar);
                      tabName = 'calendar';
                    } else if (tab == bottom_nav.Tab.statistics) {
                      appProvider.setActiveTab(AppTab.statistics);
                      tabName = 'statistics';
                    } else {
                      appProvider.setActiveTab(AppTab.profile);
                      tabName = 'profile';
                    }
                    AnalyticsService().logButtonClick('tab_$tabName');
                  },
                  onAddClick: () {
                    AnalyticsService().logButtonClick('add_birthday', screen: 'main');
                    Navigator.push(
                      context,
                      AppAnimations.slideRoute(
                        const BirthdayFormScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen(
    BuildContext context,
    AppProvider appProvider,
    BirthdayProvider birthdayProvider,
  ) {
    switch (appProvider.activeTab) {
      case AppTab.home:
        return HomeScreen(
          onAddBirthday: () {
            Navigator.push(
              context,
              AppAnimations.slideRoute(
                const BirthdayFormScreen(),
              ),
            );
          },
        );
      case AppTab.calendar:
        return CalendarViewScreen(
          birthdays: birthdayProvider.birthdays,
          onBirthdayTap: (birthday) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BirthdayDetailScreen(birthday: birthday),
              ),
            );
          },
        );
      case AppTab.statistics:
        return const StatisticsScreen();
      case AppTab.profile:
        return const ProfileScreen();
    }
  }
}

