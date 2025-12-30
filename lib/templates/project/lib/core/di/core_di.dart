import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:{{project_name}}/app/environment/app_environment.dart';
import 'package:{{project_name}}/app/router/app_router.dart';
import 'package:{{project_name}}/core/clients/network/endpoints.dart';
import 'package:{{project_name}}/core/clients/network/network_client.dart';
import 'package:{{project_name}}/core/clients/network/result_call_executor.dart';

class CoreDi {
  static void register({
    required AppEnvironment environment,
    required GetIt instance,
  }) {
    //  environment
    instance.registerLazySingleton<AppEnvironment>(() => environment);

    // 🔹 Dio
    instance.registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: RemoteEndpoints.baseEndpoint, // ✅ REAL runtime base URL
        ),
      );
      if (kDebugMode) {
        dio.interceptors.add(
          LogInterceptor(
            requestBody: true,
            responseBody: true,
            requestHeader: true,
            responseHeader: false,
          ),
        );
      }

      return dio;
    });

    // 🔹 NetworkClient
    instance.registerLazySingleton<NetworkClient>(
      () =>
          NetworkClient(dio: instance.get<Dio>(), baseUrl: environment.baseUrl),
    );

    // Result adapter (Retrofit replacement)
    instance.registerLazySingleton(() => const ResultCallExecutor());

    instance.registerLazySingleton(() => AppRouter());
    // Future: Add SharedPreferences, SecureStorage, etc. here
  }
}
