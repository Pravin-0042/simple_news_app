import 'package:material_ui/material_ui.dart';

import '../utils/app_spacing.dart';

abstract final class AppTheme {
  static const _editorialBlue = Colors.blue;
  static const _background = Colors.white;
  static const _cornerRadius = 12.0;

  static final ThemeData light = _buildTheme(
    brightness: Brightness.light,
    background: _background,

    surface: const Color.fromARGB(255, 243, 240, 240),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _editorialBlue,
      brightness: brightness,
      primary: _editorialBlue,
      surface: surface,
    );
    final baseTextTheme = Typography.material2021(
      platform: TargetPlatform.android,
    ).black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: _editorialBlue,

      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: const EdgeInsets.all(AppSpacing.small),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
