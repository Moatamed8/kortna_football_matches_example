import "package:equatable/equatable.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/theme/theme_store.dart";

class SettingsState extends Equatable {
  const SettingsState(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._store) : super(SettingsState(_store.read()));

  final ThemeStore _store;

  Future<void> setTheme(ThemeMode mode) async {
    if (state.themeMode == mode) return;
    emit(SettingsState(mode));
    await _store.write(mode);
  }
}
