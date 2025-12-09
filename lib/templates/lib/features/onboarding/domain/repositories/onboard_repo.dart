import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/features/onboarding/domain/entities/onboading.dart';

abstract class OnboardingRepository {
  Future<Result<List<OnboadingEntity>>> getOnboardingPages();
}
