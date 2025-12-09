import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:{{project_name}}/app/environment/app_environment.dart';
import 'package:{{project_name}}/features/onboarding/data/datasources/onboading_client.dart';
import 'package:{{project_name}}/features/onboarding/data/datasources/onboarding_moc.dart';
import 'package:{{project_name}}/features/onboarding/data/repositories/onboard_repo_impl.dart';
import 'package:{{project_name}}/features/onboarding/domain/repositories/onboard_repo.dart';
import 'package:{{project_name}}/features/onboarding/domain/usecases/get_onboard.dart';
import 'package:{{project_name}}/features/onboarding/presentation/bloc/onboarding_bloc.dart';

class OnboardingDi {
  static void register(GetIt instance) {
    instance.registerFactory(() => OnboardingBloc(useCase: instance()));
    instance.registerFactory(() => GetOnboardUseCase(instance()));
    instance.registerFactory<OnboardingRepository>(
      () => OnboardRepositoryImpl(
        remote: instance<OnboadingClient>(),
        moc: instance<OnboardingMocDataSource>(),
        environment: instance<AppEnvironment>(),
      ),
    );
    instance.registerFactory(() => OnboardingMocDataSource());

    instance.registerLazySingleton<OnboadingClient>(
      () => OnboadingClient(instance<Dio>()),
    );
  }
}
