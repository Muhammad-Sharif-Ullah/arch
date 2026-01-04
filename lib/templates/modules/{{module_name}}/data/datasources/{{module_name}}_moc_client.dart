import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/models/{{module_name}}_model.dart';
import 'package:{{project_name}}/features/{{module_name}}/data/models/{{module_name}}_payload.dart';

class {{class_name}}MockClient {
  static const _mockPath = 'assets/data/{{module_name}}.json';
  Future<Result<{{class_name}}Model>> {{module_name}}({required {{class_name}}Payload payload}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final raw = await rootBundle.loadString(_mockPath);
      final decoded = json.decode(raw) as Map<String, dynamic>;

      if (decoded['status'] != true) {
        return Result.failure(
          decoded['message'] ?? 'Login failed',
          decoded['statusCode'],
        );
      }

      final userJson = decoded['data'] as Map<String, dynamic>;
      final user = {{class_name}}Model.fromJson(userJson);

      return Result.success(data: user);
    } catch (e) {
      return Result.failure('Mock login error: ${e.toString()}');
    }
  }
}
