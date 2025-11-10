import 'package:flutter/material.dart';
import 'package:{{project_name}}/app/constants/string_constants.dart';
import 'package:{{project_name}}/app/l10n/arb/app_localizations.dart';
import 'package:{{project_name}}/app/router/app_router.dart';
import 'package:{{project_name}}/app/theme/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            // App Name
            title: StringConstants.appName,

            // Theme
            theme: state.lightTheme,
            darkTheme: state.darkTheme,
            themeMode: state.mode,

            // Localization
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            // Routing
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
