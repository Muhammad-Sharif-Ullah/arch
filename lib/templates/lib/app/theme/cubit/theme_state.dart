part of 'theme_cubit.dart';

enum AppScheme {
  amber,
  arch,
  crimson,
  forest,
  lavender,
  midnight,
  mint,
  neon,
  ocean,
  sakura,
  sunset,
}

class ThemeState extends Equatable {
  const ThemeState({
    required this.lightTheme,
    required this.darkTheme,
    required this.scheme,
    required this.mode,
  });

  factory ThemeState.initial() {
    return ThemeState(
      lightTheme: oceanLightTheme,
      darkTheme: oceanDarkTheme,
      scheme: AppScheme.arch,
      mode: ThemeMode.system,
    );
  }
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final AppScheme scheme;
  final ThemeMode mode;

  ThemeState copyWith({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    AppScheme? scheme,
    ThemeMode? mode,
  }) {
    return ThemeState(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      scheme: scheme ?? this.scheme,
      mode: mode ?? this.mode,
    );
  }

  @override
  List<Object?> get props => [scheme, mode];
}
