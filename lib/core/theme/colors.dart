import "package:flutter/material.dart";

import "../../constant.dart";

abstract class AppColors {
  static const Color primary = Color(0xFF0287F4);
  static const Color secondary = Colors.grey;
  static const Color error = Color(0xFFE9152D);
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color foregroundLight = Color(0xFFFFFFFF);
  static const Color textLight = Colors.black;
  static const Color shadowLight = Color(0x1F414141);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF161618);
  static const Color foregroundDark = Color(0xFF212124);
  static const Color textDark = AppColors.foregroundLight;
  static const Color shadowDark = Color(0x66000000);
}

extension ThemeContext on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  Color get primary => colorScheme.primary;
  Color get text => colorScheme.onBackground;
  Color get secondary => colorScheme.secondary;
  Color get third => colorScheme.surface;
  Color get border => colorScheme.outline;
  Color get shadow => colorScheme.shadow;
  Color get background => colorScheme.background;
  Color get foreground => colorScheme.surface;
  Color get error => AppColors.error;
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
}

abstract class AppThemes {
  static ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme:
          dynamicColorScheme ??
          ColorScheme.fromSeed(
            brightness: Brightness.light,
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.textLight.withOpacity(0.5),
            surface: AppColors.foregroundLight,
            background: AppColors.backgroundLight,
            onBackground: AppColors.textLight,
            outline: AppColors.backgroundLight,
            shadow: AppColors.shadowLight,
            error: AppColors.error,
            tertiary: AppColors.success,
          ),
      scaffoldBackgroundColor:
          dynamicColorScheme?.background ?? AppColors.backgroundLight,
      visualDensity: VisualDensity.compact,
      platform: TargetPlatform.android,
      fontFamily: kMainFont,
    );
  }

  static ThemeData darkTheme(ColorScheme? dynamicColorScheme) {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme:
          dynamicColorScheme ??
          ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.foregroundDark,
            background: AppColors.backgroundDark,
            onBackground: AppColors.textDark,
            outline: AppColors.secondary.withOpacity(0.3),
            shadow: AppColors.shadowDark,
            error: AppColors.error,
            tertiary: AppColors.success,
          ),
      scaffoldBackgroundColor:
          dynamicColorScheme?.background ?? AppColors.backgroundDark,
      visualDensity: VisualDensity.compact,
      platform: TargetPlatform.android,
      fontFamily: kMainFont,
    );
  }
}
