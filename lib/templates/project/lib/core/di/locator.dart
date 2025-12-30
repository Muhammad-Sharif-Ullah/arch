import 'package:get_it/get_it.dart';
import 'package:{{project_name}}/app/environment/app_environment.dart';
import 'package:{{project_name}}/core/di/core_di.dart';
import 'package:{{project_name}}/features/onboarding/di/onboarding_di.dart';

abstract final class Locator {
  static final instance = GetIt.instance;

  static Future<void> setup({required AppEnvironment environment}) async {
    CoreDi.register(environment: environment, instance: instance);
    OnboardingDi.register(instance);
  }
}
