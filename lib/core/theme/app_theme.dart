import "package:flutter/material.dart";
import "package:soccer/core/theme/app_palette.dart";

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final palette = dark ? AppPalette.dark : AppPalette.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: palette.accent,
    onPrimary: palette.onAccent,
    secondary: palette.accent,
    onSecondary: palette.onAccent,
    error: palette.live,
    onError: Colors.white,
    surface: palette.surface,
    onSurface: palette.ink,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.background,
    dividerColor: palette.line,
    splashFactory: InkRipple.splashFactory,
    extensions: [palette],
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: palette.ink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.surface,
      height: 68,
      indicatorColor: palette.accent.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: selected ? palette.ink : palette.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? palette.accent : palette.muted,
          size: 22,
        );
      }),
    ),
    textTheme: ThemeData(brightness: brightness).textTheme.apply(
      bodyColor: palette.ink,
      displayColor: palette.ink,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.surfaceHigh,
      contentTextStyle: TextStyle(color: palette.ink),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
