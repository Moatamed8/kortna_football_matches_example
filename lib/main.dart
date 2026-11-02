import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:soccer/app/app.dart";
import "package:soccer/app/dependencies.dart";
import "package:soccer/core/theme/theme_store.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    KortnaApp(
      dependencies: AppDependencies.production(
        PreferencesThemeStore(preferences),
      ),
    ),
  );
}
