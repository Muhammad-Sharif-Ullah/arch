import 'package:{{project_name}}/app/theme/schemes/schemes.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_state.dart';

class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(ThemeState.initial());

  void changeScheme(AppScheme newScheme) {
    final (light, dark) = _themesFor(newScheme);
    emit(state.copyWith(lightTheme: light, darkTheme: dark, scheme: newScheme));
  }

  void changeMode(ThemeMode newMode) {
    emit(state.copyWith(mode: newMode));
  }

  (ThemeData light, ThemeData dark) _themesFor(AppScheme scheme) {
    return switch (scheme) {
      AppScheme.arch => (archLightTheme, archDarkTheme),
      AppScheme.amber => (amberLightTheme, amberDarkTheme),
      AppScheme.crimson => (crimsonLightTheme, crimsonDarkTheme),
      AppScheme.forest => (forestLightTheme, forestDarkTheme),
      AppScheme.lavender => (lavenderLightTheme, lavenderDarkTheme),
      AppScheme.midnight => (midnightLightTheme, midnightDarkTheme),
      AppScheme.mint => (mintLightTheme, mintDarkTheme),
      AppScheme.neon => (neonLightTheme, neonDarkTheme),
      AppScheme.ocean => (oceanLightTheme, oceanDarkTheme),
      AppScheme.sakura => (sakuraLightTheme, sakuraDarkTheme),
      AppScheme.sunset => (sunsetLightTheme, sunsetDarkTheme),
    };
  }

  /* ---------- HydratedBloc ---------- */
  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    try {
      final scheme = AppScheme.values[json['scheme'] as int];
      final mode = ThemeMode.values[json['mode'] as int];
      final (light, dark) = _themesFor(scheme);
      return ThemeState(
        lightTheme: light,
        darkTheme: dark,
        scheme: scheme,
        mode: mode,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return {'scheme': state.scheme.index, 'mode': state.mode.index};
  }
}
