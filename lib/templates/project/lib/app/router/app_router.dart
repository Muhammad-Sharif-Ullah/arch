import 'barrel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'barrel.dart';
part 'app_router.g.dart';
part 'routes.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: $appRoutes,
  );
}
