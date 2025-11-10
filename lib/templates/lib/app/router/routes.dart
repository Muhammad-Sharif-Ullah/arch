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

// /// 🔹 Shell route for main layout (e.g. bottom nav)
// @TypedShellRoute<MainShellRoute>(
//   routes: [
//     TypedGoRoute<HomeRoute>(path: '/home'),
//     TypedGoRoute<CartRoute>(path: '/cart'),
//     TypedGoRoute<ProfileRoute>(path: '/profile'),
//   ],
// )
// class MainShellRoute extends ShellRouteData {
//   const MainShellRoute();

//   @override
//   Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
//     return MainLayout(child: navigator);
//   }
// }

// /// 🔹 Individual routes inside the shell
// class HomeRoute extends GoRouteData {
//   const HomeRoute();

//   @override
//   Widget build(BuildContext context, GoRouterState state) => const HomePage();
// }

// class CartRoute extends GoRouteData {
//   const CartRoute();

//   @override
//   Widget build(BuildContext context, GoRouterState state) => const CartPage();
// }

// class ProfileRoute extends GoRouteData {
//   const ProfileRoute();

//   @override
//   Widget build(BuildContext context, GoRouterState state) =>
//       const ProfilePage();
// }
