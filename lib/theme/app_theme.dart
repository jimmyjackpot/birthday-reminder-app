import 'package:flutter/material.dart';

class AppTheme {
  // Primary Brand Colors
  static const Color primaryColor = Color(0xFFFF6B9D); // Coral Pink
  static const Color secondaryColor = Color(0xFF4ECDC4); // Teal Green
  static const Color accentColor = Color(0xFFFFE66D); // Yellow/Amber

  // Semantic Color Tokens - Light Mode
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLight = Color(0xFFFAFAFA);
  static const Color _surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color _onSurfaceLight = Color(0xFF1F2937);
  static const Color _onSurfaceVariantLight = Color(0xFF6B7280);
  static const Color _onSurfaceDisabledLight = Color(0xFF9CA3AF);
  static const Color _outlineLight = Color(0xFFE5E7EB);
  static const Color _outlineVariantLight = Color(0xFFF3F4F6);

  // Semantic Color Tokens - Dark Mode
  static const Color _surfaceDark = Color(0xFF1A1A1A);
  static const Color _surfaceContainerDark = Color(0xFF0F0F0F);
  static const Color _surfaceElevatedDark = Color(0xFF252525);
  static const Color _onSurfaceDark = Color(0xFFFFFFFF);
  static const Color _onSurfaceVariantDark = Color(0xFFE0E0E0);
  static const Color _onSurfaceDisabledDark = Color(0xFFB0B0B0);
  static const Color _outlineDark = Color(0xFF3A3A3A);
  static const Color _outlineVariantDark = Color(0xFF2A2A2A);

  // Status Colors (consistent across themes)
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF4A90E2);

  // Extended Color Palette
  static const Color _pinkLight = Color(0xFFFFF0F5);
  static const Color _pinkDark = Color(0xFF2A1F1F);
  static const Color _tealLight = Color(0xFFE0F7F4);
  static const Color _tealDark = Color(0xFF1F2A2A);
  static const Color _beigeLight = Color(0xFFF5F5F0);
  static const Color _beigeDark = Color(0xFF1A1A1A);
  static const Color _blueLight = Color(0xFF4A90E2);
  static const Color _blueDark = Color(0xFF3A5A8A);
  static const Color _orangeLight = Color(0xFFFF9800);
  static const Color _orangeDark = Color(0xFFFFB84D);

  // Color Token Getters - Surface
  static Color surface([bool isDark = false]) =>
      isDark ? _surfaceDark : _surfaceLight;

  static Color surfaceContainer([bool isDark = false]) =>
      isDark ? _surfaceContainerDark : _surfaceContainerLight;

  static Color surfaceElevated([bool isDark = false]) =>
      isDark ? _surfaceElevatedDark : _surfaceElevatedLight;

  // Color Token Getters - On Surface (Text)
  static Color onSurface([bool isDark = false]) =>
      isDark ? _onSurfaceDark : _onSurfaceLight;

  static Color onSurfaceVariant([bool isDark = false]) =>
      isDark ? _onSurfaceVariantDark : _onSurfaceVariantLight;

  static Color onSurfaceDisabled([bool isDark = false]) =>
      isDark ? _onSurfaceDisabledDark : _onSurfaceDisabledLight;

  // Color Token Getters - Outline (Borders)
  static Color outline([bool isDark = false]) =>
      isDark ? _outlineDark : _outlineLight;

  static Color outlineVariant([bool isDark = false]) =>
      isDark ? _outlineVariantDark : _outlineVariantLight;

  // Color Token Getters - Extended Colors
  static Color pinkContainer([bool isDark = false]) =>
      isDark ? _pinkDark : _pinkLight;

  static Color tealContainer([bool isDark = false]) =>
      isDark ? _tealDark : _tealLight;

  static Color beigeContainer([bool isDark = false]) =>
      isDark ? _beigeDark : _beigeLight;

  static Color blueContainer([bool isDark = false]) =>
      isDark ? _blueDark : _blueLight;

  static Color orangeContainer([bool isDark = false]) =>
      isDark ? _orangeDark : _orangeLight;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, accentColor],
  );

  static const LinearGradient contactSyncGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryColor, secondaryColor],
  );

  // Shadows
  static List<BoxShadow> cardShadow([bool isDark = false]) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> elevatedShadow([bool isDark = false]) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> subtleShadow([bool isDark = false]) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> floatingShadow([bool isDark = false]) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  // Typography - Using Geist Font
  static TextStyle _geistTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Geist',
      fontFamilyFallback: const ['SF Pro Display', 'Roboto', 'sans-serif'],
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle heading1([bool isDark = false]) => _geistTextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: onSurface(isDark),
      );

  static TextStyle heading2([bool isDark = false]) => _geistTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
        color: onSurface(isDark),
      );

  static TextStyle heading3([bool isDark = false]) => _geistTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.4,
        color: onSurface(isDark),
      );

  static TextStyle bodyLarge([bool isDark = false]) => _geistTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
        color: onSurface(isDark),
      );

  static TextStyle bodyMedium([bool isDark = false]) => _geistTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: onSurface(isDark),
      );

  static TextStyle bodySmall([bool isDark = false]) => _geistTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
        color: onSurfaceVariant(isDark),
      );

  static TextStyle labelLarge([bool isDark = false]) => _geistTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface(isDark),
      );

  static TextStyle labelMedium([bool isDark = false]) => _geistTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: onSurface(isDark),
      );

  static TextStyle labelSmall([bool isDark = false]) => _geistTextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: onSurfaceVariant(isDark),
      );

  // Legacy compatibility helpers (deprecated - use tokens instead)
  @Deprecated('Use AppTheme.surfaceContainer() instead')
  static Color getBackgroundColor([bool isDark = false]) =>
      surfaceContainer(isDark);

  @Deprecated('Use AppTheme.surface() instead')
  static Color getSurfaceColor([bool isDark = false]) => surface(isDark);

  @Deprecated('Use AppTheme.surfaceElevated() instead')
  static Color getSurfaceElevatedColor([bool isDark = false]) =>
      surfaceElevated(isDark);

  @Deprecated('Use AppTheme.onSurface() instead')
  static Color getTextPrimaryColor([bool isDark = false]) => onSurface(isDark);

  @Deprecated('Use AppTheme.onSurfaceVariant() instead')
  static Color getTextSecondaryColor([bool isDark = false]) =>
      onSurfaceVariant(isDark);

  @Deprecated('Use AppTheme.onSurfaceDisabled() instead')
  static Color getTextTertiaryColor([bool isDark = false]) =>
      onSurfaceDisabled(isDark);

  @Deprecated('Use AppTheme.outline() instead')
  static Color getBorderColor([bool isDark = false]) => outline(isDark);

  @Deprecated('Use AppTheme.outlineVariant() instead')
  static Color getDividerColor([bool isDark = false]) => outlineVariant(isDark);

  @Deprecated('Use AppTheme.pinkContainer() instead')
  static Color getLightPink([bool isDark = false]) => pinkContainer(isDark);

  @Deprecated('Use AppTheme.tealContainer() instead')
  static Color getLightTeal([bool isDark = false]) => tealContainer(isDark);

  @Deprecated('Use AppTheme.beigeContainer() instead')
  static Color getLightBeige([bool isDark = false]) => beigeContainer(isDark);

  @Deprecated('Use AppTheme.blueContainer() instead')
  static Color getLightBlue([bool isDark = false]) => blueContainer(isDark);

  @Deprecated('Use AppTheme.orangeContainer() instead')
  static Color getOrange([bool isDark = false]) => orangeContainer(isDark);

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: _surfaceLight,
        surfaceContainer: _surfaceContainerLight,
        surfaceContainerHighest: _surfaceElevatedLight,
        onSurface: _onSurfaceLight,
        onSurfaceVariant: _onSurfaceVariantLight,
        outline: _outlineLight,
        outlineVariant: _outlineVariantLight,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: _surfaceContainerLight,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        color: _surfaceLight,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _surfaceLight,
        foregroundColor: _onSurfaceLight,
        titleTextStyle: heading3(false),
        iconTheme: const IconThemeData(color: _onSurfaceLight),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _outlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _outlineLight),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMD,
          vertical: spacingMD,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: labelLarge(false).copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          side: const BorderSide(color: _outlineLight),
          foregroundColor: _onSurfaceLight,
          textStyle: labelLarge(false),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: labelLarge(false).copyWith(color: primaryColor),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _outlineVariantLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Dark Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: _surfaceDark,
        surfaceContainer: _surfaceContainerDark,
        surfaceContainerHighest: _surfaceElevatedDark,
        onSurface: _onSurfaceDark,
        onSurfaceVariant: _onSurfaceVariantDark,
        outline: _outlineDark,
        outlineVariant: _outlineVariantDark,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: _surfaceContainerDark,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        color: _surfaceDark,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _surfaceDark,
        foregroundColor: _onSurfaceDark,
        titleTextStyle: heading3(true),
        iconTheme: const IconThemeData(color: _onSurfaceDark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _outlineDark),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMD,
          vertical: spacingMD,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: labelLarge(true).copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          side: const BorderSide(color: _outlineDark),
          foregroundColor: _onSurfaceDark,
          textStyle: labelLarge(true),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: labelLarge(true).copyWith(color: primaryColor),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _outlineVariantDark,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        displayLarge: heading1(true),
        displayMedium: heading2(true),
        displaySmall: heading3(true),
        bodyLarge: bodyLarge(true),
        bodyMedium: bodyMedium(true),
        bodySmall: bodySmall(true),
        labelLarge: labelLarge(true),
        labelMedium: labelMedium(true),
      ).apply(
        bodyColor: _onSurfaceDark,
        displayColor: _onSurfaceDark,
      ),
    );
  }
}
