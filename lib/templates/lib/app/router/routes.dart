part of 'app_router.dart';

@TypedGoRoute<SplashRoute>(path: '/', name: 'SplashScreen')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding', name: 'OnboardingScreen')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingScreen();
}

/// Shell route for main layout (e.g. bottom nav)
/*
/// ------------------------------------------------------
/// MAIN SHELL (Bottom Navigation Layout)
/// ------------------------------------------------------
@TypedShellRoute<MainShellRoute>(
  routes: [
    TypedGoRoute<DashboardRoute>(
      path: DashboardScreen.path,
      name: DashboardScreen.name,
    ),
    TypedGoRoute<CategoriesRoute>(
      path: CategoriesScreen.path,
      name: CategoriesScreen.name,
    ),
    TypedGoRoute<CartRoute>(path: CartScreen.path, name: CartScreen.name),
    TypedGoRoute<ProfileRoute>(
      path: ProfileScreen.path,
      name: ProfileScreen.name,
      routes: [],
    ),
  ],
)
class MainShellRoute extends ShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MainLayout(child: navigator);
  }
}

/// ------------------------------------------------------
/// SHELL INNER ROUTES
/// ------------------------------------------------------

class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (context) => Locator.instance<HomeBuilderCubit>()
        ..fetchInitialData(payload: HomePaginationPayload(page: 1, limit: 20)),
      child: const DashboardScreen(),
    );
  }
}

class CategoriesRoute extends GoRouteData with $CategoriesRoute {
  const CategoriesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CategoriesScreen();
}

class CartRoute extends GoRouteData with $CartRoute {
  const CartRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const CartScreen();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}


*/
