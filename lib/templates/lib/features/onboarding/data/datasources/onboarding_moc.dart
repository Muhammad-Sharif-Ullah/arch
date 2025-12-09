import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/core/clients/network/base_response.dart';
import 'package:{{project_name}}/features/onboarding/data/models/onbading.dart';

class OnboardingMocDataSource {
  Future<Result<BaseResponse<List<OnboadingModel>>>> getOnbadingData({
    required String path,
  }) async {
    try {
      final String response = await rootBundle.loadString(path);
      final data = await json.decode(response);
      final BaseResponse<List<OnboadingModel>> baseResponse =
          BaseResponse.fromJson(
        data as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((e) => OnboadingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      if (!baseResponse.success) {
        return Result.failure(
          baseResponse.error ?? 'Unknown API error',
          baseResponse.statusCode,
          baseResponse.message,
        );
      }
      return Result.success(data: baseResponse);
    } on Exception catch (e) {
      return Result.failure('Error loading mock data: $e');
    }
  }
}
