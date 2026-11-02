import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

abstract class ThemeStore {
  ThemeMode read();
  Future<void> write(ThemeMode mode);
}

class MemoryThemeStore implements ThemeStore {
  MemoryThemeStore([this.mode = ThemeMode.system]);

  ThemeMode mode;

  @override
  ThemeMode read() => mode;

  @override
  Future<void> write(ThemeMode mode) async {
    this.mode = mode;
  }
}

class PreferencesThemeStore implements ThemeStore {
  PreferencesThemeStore(this._preferences);

  static const _key = "theme_mode";
  final SharedPreferences _preferences;

  @override
  ThemeMode read() {
    return switch (_preferences.getString(_key)) {
      "light" => ThemeMode.light,
      "dark" => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> write(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.light => "light",
      ThemeMode.dark => "dark",
      ThemeMode.system => "system",
    };
    return _preferences.setString(_key, value);
  }
}
