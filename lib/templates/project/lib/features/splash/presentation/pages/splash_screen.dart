import 'package:{{project_name}}/app/generated/assets.gen.dart';
import 'package:{{project_name}}/app/router/app_router.dart';
import 'package:{{project_name}}/core/extensions/context_extensions.dart';
import 'package:{{project_name}}/core/utils/package_info/package_info_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2), () {}).whenComplete(() {
      if (mounted) {
        const OnboardingRoute().pushReplacement(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: context.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              Assets.images.logoPng.path,
              height: 200,
              width: 200,
            ).animate(
              effects: [
                const SlideEffect(begin: Offset.zero, end: Offset(0, .05)),
                const ScaleEffect(
                  begin: Offset(0.1, 0.1),
                  end: Offset(1.1, 1.1),
                  duration: Duration(milliseconds: 1500),
                  curve: Curves.fastLinearToSlowEaseIn,
                ),
                const ThenEffect(),
                const ShimmerEffect(),
              ],
            ),
            const Spacer(),
            SafeArea(
              child: Column(
                children: [
                  Text(
                    PackageInfoUtils.getAppName(),
                    style: GoogleFonts.dosis(
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                  Text(
                    'Version: ${PackageInfoUtils.getAppVersion()}:${PackageInfoUtils.buildNumber()}',
                    style: GoogleFonts.dosis(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '© ${DateTime.now().year}. All rights reserved.',
                    style: GoogleFonts.dosis(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
