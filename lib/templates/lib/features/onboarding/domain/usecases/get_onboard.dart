import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/features/onboarding/domain/entities/onboading.dart';
import 'package:{{project_name}}/features/onboarding/domain/repositories/onboard_repo.dart';

class GetOnboardUseCase {
  final OnboardingRepository repository;
  GetOnboardUseCase(this.repository);

  Future<Result<List<OnboadingEntity>>> call() async {
    return await repository.getOnboardingPages();
  }
}
