import 'package:{{project_name}}/app/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class PageNotFoundScreen extends StatelessWidget {
  const PageNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.icons.logoPng.path,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ).animate(
                delay: 1.seconds,
                onPlay: (controller) => controller.repeat(),
                effects: [
                  ScaleEffect(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.06, 1.06), // Heart expansion
                    duration: 1000.ms,
                    curve: Curves.easeInOut,
                  ),
                  const ThenEffect(),
                  ScaleEffect(
                    begin: const Offset(1.06, 1.06),
                    end: const Offset(1.0, 1.0), // Heart expansion
                    duration: 1000.ms,
                    curve: Curves.easeInOut,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Oops! \nPage not found",
                textAlign: TextAlign.center,
                style: GoogleFonts.podkova(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  // color: theme.textPrimary,
                  shadows: [
                    BoxShadow(
                      // color: theme.primary.withAlpha(130),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "The page you are looking for might have been removed, had its name changed or is temporarily unavailable.",
                textAlign: TextAlign.center,
                style: GoogleFonts.podkova(
                  fontSize: 14,
                  // color: theme.textPrimary,
                  shadows: [
                    BoxShadow(
                      // color: theme.primary.withAlpha(130),
                      blurRadius: 5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                direction: Axis.horizontal,
                runAlignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // GoRouter.of(context).canPop()
                      //     ? GoRouter.of(context).pop(context)
                      //     : GoRouter.of(
                      //         context,
                      //       ).go(OnboardingAppSetupPage.path);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      "Return Back",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    "/",
                    style: GoogleFonts.podkova(
                      fontSize: 44,
                      // color: theme.textPrimary,
                    ),
                  ).animate(
                    delay: 1.seconds,
                    onPlay: (controller) => controller.repeat(),
                    effects: [
                      RotateEffect(
                        duration: 1.seconds,
                        delay: 0.5.seconds,
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // final user = sl<UserBloc>().state.user;
                      // if (user == null) {
                      //   GoRouter.of(context).go(OnboardingAppSetupPage.path);
                      //   return;
                      // }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      "Go to Home Page",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
