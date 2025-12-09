import 'package:{{project_name}}/app/environment/app_environment.dart';
import 'package:{{project_name}}/app/environment/production_environment.dart';
import 'package:{{project_name}}/app/generated/assets.gen.dart';
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/features/onboarding/data/datasources/onboading_client.dart';
import 'package:{{project_name}}/features/onboarding/data/datasources/onboarding_moc.dart';
import 'package:{{project_name}}/features/onboarding/domain/entities/onboading.dart';
import 'package:{{project_name}}/features/onboarding/domain/repositories/onboard_repo.dart';

class OnboardRepositoryImpl implements OnboardingRepository {
  final OnboardingMocDataSource moc;
  final OnboadingClient remote;
  final AppEnvironment environment;

  OnboardRepositoryImpl({
    required this.remote,
    required this.moc,
    required this.environment,
  });

  @override
  Future<Result<List<OnboadingEntity>>> getOnboardingPages() async {
    if (environment is ProductionEnvironment) {
      return await remote.getOnboadingData();
    } else {
      final response = await moc.getOnbadingData(path: Assets.data.onboading);
      return response.fold(
        (onFailure) {
          return Result.failure(
            onFailure.error,
            onFailure.statusCode,
            onFailure.message,
          );
        },
        (onSuccess) {
          return Result.success(data: onSuccess.data!);
        },
      );
    }
  }
}
