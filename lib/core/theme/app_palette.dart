import "package:flutter/material.dart";

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.onAccent,
    required this.live,
    required this.warning,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color ink;
  final Color muted;
  final Color line;
  final Color accent;
  final Color onAccent;
  final Color live;
  final Color warning;

  static const dark = AppPalette(
    background: Color(0xFF0C0F14),
    surface: Color(0xFF151A21),
    surfaceHigh: Color(0xFF1E2630),
    ink: Color(0xFFF4F7FB),
    muted: Color(0xFF93A0AE),
    line: Color(0xFF2A3340),
    accent: Color(0xFF3DDC97),
    onAccent: Color(0xFF06281A),
    live: Color(0xFFFF4D4D),
    warning: Color(0xFFF0C14A),
  );

  static const light = AppPalette(
    background: Color(0xFFF3F5F7),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFE7EDF2),
    ink: Color(0xFF12161C),
    muted: Color(0xFF5C6B78),
    line: Color(0xFFE1E6EC),
    accent: Color(0xFF0C7A48),
    onAccent: Color(0xFFFFFFFF),
    live: Color(0xFFD31212),
    warning: Color(0xFF9A7209),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? ink,
    Color? muted,
    Color? line,
    Color? accent,
    Color? onAccent,
    Color? live,
    Color? warning,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      live: live ?? this.live,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      live: Color.lerp(live, other.live, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
